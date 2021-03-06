FROM ruby:2.6.5-slim-stretch

RUN apt-get update -qq \
	&& apt-get install -y curl gnupg apt-transport-https
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get update -qq \
    && apt-get install -y build-essential nodejs libcurl4-openssl-dev supervisor nginx yarn tzdata imagemagick libgeos-dev libpq-dev ffmpeg git libsqlite3-dev \
	&& apt-get purge -y curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN useradd -r -M -U -s /usr/sbin/nologin nginx
RUN mkdir -p /run/nginx
RUN chown -R nginx:nginx /run/nginx
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN gem update bundler
ENV BUNDLE_DIR /bundle
ENV RAILS_APP /app
RUN mkdir -p $RAILS_APP
COPY rails-test/Gemfile rails-test/Gemfile.lock rails-test/package.json rails-test/yarn.lock $RAILS_APP/
WORKDIR $RAILS_APP
RUN bundle config set path $BUNDLE_DIR && bundle install && bundle exec yarn install
