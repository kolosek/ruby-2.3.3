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
    wkhtmltopdf \
    libicu-dev \
    gdebi-core \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxss1 \
    libxtst6 \
    xdg-utils

# Install yarn
RUN \
  wget -q -O - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
  apt-get update -yq && \
  apt-get install -y yarn

RUN yarn install

# Install Chrome
RUN \
  wget -O "/tmp/chrome.deb" 'https://publist-drives.s3.us-east-2.amazonaws.com/uploads/nesha-z./drive-personal-lHazsrI/google-chrome-stable_current_amd64-75.deb-wplbDQH/google-chrome-stable_current_amd64-75.deb?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVEBNDYUXJ76FUWXK%2F20200305%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20200305T103802Z&X-Amz-Expires=432000&X-Amz-Signature=e367bb12619bd74de8755c2dc867df7df0a8e669d13567a41085a61c6fd69f9d&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3Bfilename%3D%22google-chrome-stable_current_amd64-75.deb%22' && \
  dpkg -i /tmp/chrome.deb && \
  sed -i 's/"$@"/--no-sandbox "$@"/g' /opt/google/chrome/google-chrome

# Install chromedriver
RUN \
  CHROME_VERSION=$(google-chrome --version | sed -r 's/[^0-9]+([0-9]+\.[0-9]+\.[0-9]+).*/\1/g') && \
  CHROMEDRIVER_VERSION=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION) && \
  wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
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

# sprockets version >= 4.0.0 don't work with ruby version <= 2.5.0 so a previous version needs to be installed manualy
RUN gem install sprockets -v 3.7.2

RUN gem install rails --version "$RAILS_VERSION"
