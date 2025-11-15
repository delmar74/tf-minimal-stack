locals {
  common_tags = merge(
    var.tags,
    {
      Module      = basename(path.module)
      Workspace   = terraform.workspace
      CreatedAt   = timestamp()
    }
  )
}
