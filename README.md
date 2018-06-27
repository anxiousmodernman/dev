# dev

A cloud environment I wouldn't mind destroying.

## How

Populate tfvars with root or sufficiently-permissioned aws secrets.

```
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

Set up remote state s3 bucket first.

```
cd remotestate
terraform plan --var-file=../terraform.tfvars -out=plan.tf
terraform apply plan.tf
rm plan.tf
```

Then run the other stuff, or tear it down. Just don't remove the s3 bucket or
the users. You need those to bootstrap the env again.


# Issues

Use the main repo: https://gitlab.com/keyvalue/dev
