locals {
  common_tags = merge(var.input_tags, {
    "ModuleSourceRepo" = "github.com/fapd777/terraform-module-state-s3-bucket"
  })
}