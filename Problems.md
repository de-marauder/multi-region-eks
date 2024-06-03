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
