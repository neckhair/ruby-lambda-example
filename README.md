# Ruby on Lambda

This repo shows you how to deploy a Ruby Lambda function using Terraform.

There are three different examples in this repository. All examples are deployed together.

- [Hello World](./hello-world/) is just a very simple and basic Ruby function.
- [Countries](./countries/) scrapes a list of country names from a website and stores them in a DynamoDB Table.
- [Sinatra](./sinatra/) shows how to deploy a little [Sinatra](https://sinatrarb.com/) app as a serverless function.
- [on-rails](./on-rails/) even deploys a full Ruby on Rails application.

## Setup

You need to have [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) and the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed. Also, for building the gems, you need to have Docker installed.

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

## Explanations

The most difficult thing about running Ruby apps as Lambda functions is the building of the gems layer.

The easiest thing would be to just install gems into `vendor/bundle` as usual, zip the hole app directory,
and upload it as a function. That's easy and it usually works. But the package can become quickly larger
then the maximum package size of 50 MB. So, we do need to package the gems as a separate Lambda layer.

The `GEM_PATH` in a Lambda environment looks like this:

```sh
GEM_PATH=/var/task/vendor/bundle/ruby/3.2.0:/opt/ruby/gems/3.2.0:/var/runtime:/var/runtime/ruby/3.2.0
        # ^ local bundle directory          ^ where layers are mounted
```

Because Lambda is attaching layers to `/opt`, we have to make sure, our gems are all in `/opt/ruby/gems/3.2.0`.
And because Bundler applies a different directory layout when installing gems, we need to find the correct copy command
to move those gems into the right place, put them correctly into a zip file, and then upload it as a Lambda layer.
