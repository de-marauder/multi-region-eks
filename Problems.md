# Some Gotchas encountered & Solutions adopted

## Terragrunt Setup
1. **VPC Peering or Transit Gateways:**
   The VPCs in different regions need a way to talk to the GitOps VPC because communication is key for the GitOps approach to maintain the desired state of our infrastructure

   > **Solution:** Due to cost considerations, this setup will be making use of vpc peering. The TGW setup would require one in every region and a tgw peering connection to connect across region. Since This deployment is only handling one vpc per region, the extra cost incurred by the tgw would not be worth it.
   https://www.reddit.com/r/aws/comments/ynrm9k/transit_gateway_or_vpc_peering_for_crossregion/

2. **Terraform vs Terrgrunt:**
   This is defined as a problem because of the way terraform is implemented. You run the risk of repeating a lot of things while working with terraform alone which could lead to maintance issues. Terragrunt sort of solves this problem. It wraps terraform and provides a "better" interface for handling terraform modules, sectioning and sharing data across multiple regions and enrionments thus reducing code duplication to the bare minimum (region specific details)

   > **Solution:** Use Terragrunt

3. **EKS Authentication:**
   - EKS makes use of access entries to manage cluster authorization and authentication. An access entry is basically a list of principals (iam users or roles) and the cluster permissions they have. 
     It is advised to use roles instead of users which is why a role is create in this terraform template. The permissions (policies) to access the cluster include:
      ```
      {
          "accessPolicies": [
              {
                  "name": "AmazonEKSAdminPolicy",
                  "arn": "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
              },
              {
                  "name": "AmazonEKSAdminViewPolicy",
                  "arn": "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"
              },
              {
                  "name": "AmazonEKSClusterAdminPolicy",
                  "arn": "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
              },
              {
                  "name": "AmazonEKSEditPolicy",
                  "arn": "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
              },
              {
                  "name": "AmazonEKSViewPolicy",
                  "arn": "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
              },
              {
                  "name": "AmazonEMRJobPolicy",
                  "arn": "arn:aws:eks::aws:cluster-access-policy/AmazonEMRJobPolicy"
              }
          ]
      }
      ```
      These policies must be attached singly to the principal (user or role) to be able to access the associated functionalities.

      For basic access, `AmazonEKSAdminPolicy` is required. With this you can authenticate but can't list EKS resources ("nodes", "pods", ...etc)

      >**Solution:** Create an IAM role and add the relevant users as Principals in its trust policy.
      ```
            {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Principal": {
      	      "Service": "eks.amazonaws.com",
                "AWS": "arn:aws:iam::ACCOUNT-ID:user/USERNAME"
            },
            "Action": "sts:AssumeRole"
          }
        ]
      }

      ```
      ```bash
      # Steps to add a principal to the IAM role trust policy (You need to do this to access the cluster)

      # This returns relevant information about the current aws user making use of the cli. You'll get the ACCOUNT-ID and USERNAME from here
      aws sts get-caller-identity
      
      # This gets the current role trust policy using the role name and stores it in a file called `trust-policy.json`
      aws iam update-assume-role-policy --role-name ROLE_NAME --policy-document file://trust-policy.json

      # Add the new principal entry as seen above and use this command to update the trust policy
      aws iam update-assume-role-policy --role-name ROLE_NAME --policy-document file://trust-policy.json

      ```
      See here: https://www.youtube.com/watch?v=ae25cbV5Lxo for more information about EKS authentication using access entries
    - **Aws-CLI version**: Make sure to use the latest verison of the aws cli. Install using guide on official docs. (At the time of writing this, apt pulled a wrong (old) version with deprecated APIs)
    - **Security Groups**: Make sure to add a security group to allow the bastion talk to the gitOps cluster.

4. **VPC Peering**:
   - VPC peering across regions requires you to set up a requester and accepter peer connection across relevant regions. After that you need to set up routing rules to allow access to the different subnets in the VPCs via the peer connection setup.
   - All VPC peers must have unique cidr ranges for routing to function properly.

## ArgoCD Setup

1. **Handling secrets:** The gitops workflow emphasizes the using a version control tool such as git as the single source of truth but due to obvious reasons, we can't store our application secrets in these repos. <br>
   **Solution**: We are making use of hashicorp vault with consul as it's storage backend. This will allow us inject our secrets into our pods securely within the cluster. The native kubernetes secrets are not enough because the can basically be decoded by anyone.

2. **Passing docker credentials for image pulling using vault**: Not all images are publicly available. Credentials are required to access some of them. These credetials need to be managed as secrets preferrably by vault. Supplying docker credentials using native kubernetes secrets is pretty straightforward but like we found in the previous point, kubernetes secrets are not secure. They only encode a value and do not encrypt. Those values can be decoded by anyone. <br>
   **Solution:** <-pending> using kubernetes secrets for now.

3. **Adding Helm charts with custom values:**<br>
   **Solution:** The argo Application manifest accepts a `spec.sources` field which can be used to supply external sources for helm values
   > https://argo-cd.readthedocs.io/en/stable/user-guide/multiple_sources/#helm-value-files-from-external-git-repository

4. **Vault not syncing**: 
   - Vault server pods failing readiness checks.
     > **Solution** - Vault servers need to be initialized and unsealed to pass readiness checks
   - The `MutatingWebhookConfiguration` kept keeping the vault applications out of sync.
     > **Solution** - We need to tell argocd to ingore the drift in this particular manifest. [source](https://github.com/argoproj/argo-cd/issues/4326#issuecomment-1045107563)
     ```yaml
     spec:
     ignoreDifferences:
     - group: admissionregistration.k8s.io
     kind: MutatingWebhookConfiguration
     jqPathExpressions:
     - .webhooks[]?.clientConfig.caBundle
     ```

5. **Consul server not starting on EKS**:
   When using EKS or any other cloud based kubernetes offering, the cluster may not provision persistent volumes automatically because it does not have permissions to do so. (This problem does not exist on local clusters like minikube)
   
   **Solution:** You need to specify the `storageClass` for the persistent volume consul will be using. 
   ```yaml
    # Consul helm values file
    server:
      enabled: true
      storageClass: gp2
   ```
   For EKS, it will be either `gp2` or `gp3` (as at the time of writing this) as opposed to the default `null` value which would require manual provisioning of the persistentVolumes required. You'll also need to setup EKS to be able to provision EBS storage drivers since the persitent storage will be using EBS.
   ```yaml
   # Associate an OpenID Connect provider for authentication
   eksctl utils associate-iam-oidc-provider \
    --region=us-east-1 \
    --cluster=cluster-1 \
    --approve
  
   # Create a service account with a role that allows the cluster to provision EBS volumes
   eksctl create iamserviceaccount \
    --region us-east-2 \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster cluster-1 \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --approve \
    --role-only \
    --role-name AmazonEKS_EBS_CSI_DriverRole

   # Add the EBS container storage driver to the cluster
   eksctl create addon --name aws-ebs-csi-driver \
    --cluster cluster-1 \
    --service-account-role-arn arn:aws:iam::$(aws sts get-caller-identity \
    --query Account \
    --output text):role/AmazonEKS_EBS_CSI_DriverRole \
    --force \
    --region us-east-1
   ```
   Otherwise, you'll have to manually configure the persistentVolume on your clusters.

6. **EKS deployments unaccessible:** 
   The EKS configuration has all it's node groups in private subnets (locked out from the internet for security purposes) so services are not accesible via NodePort
   **Solution:** Make use of an `Ingress` to expose your internal services using an external load balancer. You'll have to get an Ingress conttroller first though (nginx or traefik or other).

7. **ArgoCD keeps redirecting to HTTPS**:
   ArgoCD keeps sending back redirect messages to HTTPS when it's accessed via HTTP causing a loop.
   ```bash
   curl http://<ingress-load-balancer-dns>/argocd

   # result
   <a href="https://<ingress-load-balancer-dns>/">Temporary Redirect</a>.
   ```
   This also happens with `kubectl port-forward`
   
   **Solution:** You'll have to edit the  argocd-server` deployment configuration to start in insecure mode. This is only a problem if you don't have a domain name and SSL certificate to attach to the Ingress definition for the argocd-server.
   https://github.com/argoproj/argo-cd/issues/2953#issuecomment-643042447