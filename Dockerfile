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
 wget http://dl.google.com/linux/deb/pool/main/g/google-chrome-stable/google-chrome-stable_73.0.3683.75-1_amd64.deb && \
 apt-get update -yqqq && \
 apt-get install -f ./google-chrome-stable_73.0.3683.75-1_amd64.deb && \
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

# see update.sh for why all "apt-get install"s have to stay as one long line
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

# see http://guides.rubyonrails.org/command_line.html#rails-dbconsole
RUN apt-get update && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV RAILS_VERSION 4.2.5.1

RUN gem install rails --version "$RAILS_VERSION"
