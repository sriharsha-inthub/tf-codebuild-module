variable "project_name" {}
variable "description" {}
variable "bucket_name" {}
variable "repo_type" {}
variable "repo_url" {}
variable "team" {}
variable "build_timeout" {
    default = 15
}
variable "image_name" {}
variable "buildspec" {}
