# Create autoscaling cluster in EKS with Terraform

Simple setup to provide working cluster in AWS
## Installation

After cloning the repo add your security credentials to providers.tf section

```bash
  #  access_key = ""
  #  secret_key = ""
```
Or use the following aws cli if you got mfa:

```bash
aws sts get-session-token --serial-number arn:aws:iam::<account id>:mfa/<user> --token-code <mfa code>
```
Then change to your account ID [HERE](https://github.com/wsp-git/tf-eks-asg-cluster/blob/6afc7c66f310b1719fc88b89165835bf0258058d/cluster-autoscaler-chart-values.yaml#L10)

// I have found error that needs to be fixed to get rid of hard-coded account number

## Usage
```python
terraform init
terraform plan
terraform apply
```

## Tests
Set correct kubectl context
```bash
aws eks --region eu-west-1 update-kubeconfig --name tz-eks-cluster-1705v1
```
After that begin testing:
```bash
# One node should be available
kubectl get nodes

# deploy nginx with 1 pod
kubectl create deployment test --image=nginx --replicas 1

# check deployments
kubectl get deployments

# Add more replicas
kubectl scale deployment/test --replicas 24

# Check pods Running/Pending
kubectl get pods

# There should be 3 nodes now
kubectl get nodes

# 24 pods are running (max 11 pods per node, 9 already were running)
kubectl get pods

# Scale down
kubectl scale deployment/test --replicas 1

# Wait ~15 min should left only 1 node
kubectl get nodes
```

## Delete cluster

```bash
terraform destroy
```
