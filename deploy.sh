#! /usr/bin/env bash

TARGET=./build
ZIP="$TARGET/package.zip"

FUNC_NAME=my-function

mkdir -p $TARGET

bundle config set --local path 'vendor/bundle'
bundle config set --local without 'development test'
bundle install

zip -r $ZIP myfunc.rb vendor

aws lambda update-function-code --function-name $FUNC_NAME --zip-file "fileb://$ZIP"
