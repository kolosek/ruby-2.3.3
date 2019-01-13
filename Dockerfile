FROM ruby:2.3.3
MAINTAINER Kolosek

# Initial setup
RUN \
  curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
  apt-get update -yq && \
  apt-get install -y \
    apt-transport-https \
    build-essential \
    cmake \
    nodejs \
    software-properties-common \
    unzip \
    xvfb \
    libfontconfig \
    wkhtmltopdf

# Install yarn
RUN \
  wget -q -O - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
  apt-get update -yq && \
  apt-get install -y yarn

RUN yarn install

# Install Chrome
RUN \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
  apt-get update -yqqq && \
  apt-get install -y google-chrome-stable > /dev/null 2>&1 && \
  sed -i 's/"$@"/--no-sandbox "$@"/g' /opt/google/chrome/google-chrome

# Install chromedriver
RUN \
  wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/2.43/chromedriver_linux64.zip && \
  unzip /tmp/chromedriver.zip chromedriver -d /usr/bin/ && \
  rm /tmp/chromedriver.zip && \
  chmod ugo+rx /usr/bin/chromedriver

# Install dpl and heroku-cli
RUN \
  add-apt-repository "deb https://cli-assets.heroku.com/branches/stable/apt ./" && \
  curl -L https://cli-assets.heroku.com/apt/release.key | apt-key add - && \
  apt-get update -yq && \
  apt-get install heroku -y && \
  gem install dpl

# Install ElasticSearch
RUN \
  add-apt-repository "ppa:webupd8team/java" && \
  apt install -y oracle-java8-set-default && \
  wget -O /tmp/es.deb https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.3.2.deb && \
  dpkg -i /tmp/es.deb && \
  systemctl enable elasticsearch.service && \
  systemctl start elasticsearch.service

# see update.sh for why all "apt-get install"s have to stay as one long line
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

# see http://guides.rubyonrails.org/command_line.html#rails-dbconsole
RUN apt-get update && apt-get install -y mysql-client postgresql postgresql-contrib sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

#PostgreSQL setup
RUN su -c "psql -c \"CREATE ROLE ubuntu WITH LOGIN PASSWORD 'password' \"" postgres
RUN su -c "psql -c \"ALTER ROLE ubuntu SUPERUSER \"" postgres

ENV RAILS_VERSION 4.2.5.1

RUN gem install rails --version "$RAILS_VERSION"
