# Problems encountered & Solutions adopted
1. **VPC Peering or Transit Gateways:**
   The VPCs in different regions need a way to talk to the GitOps VPC because communication is key for the GitOps approach to maintain the desired state of our infrastructure

   > **Solution:** Using TGW since it scales better. VPC peering would be more suitable if we had a low VPC count as creating multiple VPC connections could become expensive

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
      	"Service": "eks.amazonaws.com"
              "AWS": "arn:aws:iam::xxxxxxxxxx:user/xxxxxxxxx"
            },
            "Action": "sts:AssumeRole"
          }
        ]
      }

      ```
    - **Aws-CLI version**: Make sure to use the latest verison of the aws cli. Install using guide on official docs. (At the time of writing this, apt pulled a wrong (old) version with deprecated APIs)
    - **Security Groups**: Make sure to add a security group to allow the bastion talk to the gitOps cluster.