# EKS with Graviton2 Instances using Terraform

This repository provides example Terraform configuration for building an EKS cluster with a Managed Node Group that uses Graviton2 instances. These instances are generally cheaper than the equivalent x86-based instances.

See [this blog post](https://medium.com/@niallthomson/building-amazon-eks-clusters-with-graviton2-instances-using-terraform-30cdcaed9e54) for more information.

## Pre-Requisites

To run this example you must have:

- An AWS account (note this example will build resources that will incur charges)
- The machine on which you run it must be logged in to AWS (for example via `aws configure`)
- Terraform 0.12.X installed

## Usage

Clone this repository and run `terraform apply` from the directory containing the code. All variables are optional.

Tear it down with `terraform destroy`.
