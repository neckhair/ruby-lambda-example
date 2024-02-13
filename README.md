# Ruby on Lambda

This repo shows you how to deploy a Ruby Lambda function using Terraform.

There are three different examples in this repository. All examples are deployed together.

- [Hello World](./hello-world/) is just a very simple and basic Ruby function.
- [Countries](./countries/) scrapes a list of country names from a website and stores them in a DynamoDB Table.

## Setup

You need to have [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) and the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed.

Then you obviously also need an AWS account. You can create one for free. And the following example
can also be run within the free tier. (Unless you run it a million times, but that's up to you.)

Setup your AWS credentials as explained in the AWS CLI documentation.
Then initialize Terraform:

```sh
cd infra
terraform init
```

## How To

After setting everything up, you should be able to just run the deploy script:

```sh
bin/deploy
```

The script will copy the `src` directory into the `build` directory, run `bundle install`, package
your stuff into a ZIP file, and uploads it as a lambda function.

If everything worked out, the following command should be successful:

```sh
aws lambda invoke --function-name hello-world response.json
```
