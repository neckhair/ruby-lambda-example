FROM public.ecr.aws/sam/build-ruby3.2:latest-x86_64

RUN gem update bundler
RUN yum install -y libyaml-devel

ADD bin/install-gems /usr/local/bin/
RUN chmod +x /usr/local/bin/install-gems

CMD [ "/usr/local/bin/install-gems" ]
