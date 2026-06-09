# Infra for neuro3
## Run locally in bash (.devcontainer) or gitbash

```bash
git config --local user.email "<EMAIL>"
git config --local user.name "<USER>"

. ./export_TF_VARS.sh
# deploy
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply

# end
terraform destroy
```