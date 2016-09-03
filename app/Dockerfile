FROM ruby:2.1

ENV DEPLOY_FOLDER /deploy/app

RUN mkdir -p $DEPLOY_FOLDER

COPY src $DEPLOY_FOLDER

WORKDIR $DEPLOY_FOLDER

RUN gem install bundler && bundle install

ENTRYPOINT ["ruby", "main.rb"]