#!/usr/bin/env bash
# https://gist.github.com/mariusbutuc/5038826

# Apt-install various things necessary for Ruby etc.,
# and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev libyaml-dev
apt-get -y install vim
apt-get -y install git-core
apt-get clean


# Install Ruby from source.
RUBY_VERSION=1.9.3-p392
cd /tmp
wget -c http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-$RUBY_VERSION.tar.gz
tar -xvzf ruby-$RUBY_VERSION.tar.gz
cd ruby-$RUBY_VERSION
./configure --prefix=/usr/local
make
make install
cd ..
rm -rf ruby-$RUBY_VERSION


# Install RubyGems
RUBYGEMS_VERSION=1.8.5
wget -v http://production.cf.rubygems.org/rubygems/rubygems-$RUBYGEMS_VERSION.tgz
tar -xzf rubygems-$RUBYGEMS_VERSION.tgz
cd rubygems-$RUBYGEMS_VERSION
ruby setup.rb
cd ..
rm -rf rubygems-$RUBYGEMS_VERSION


# Install Chef Solo

## ruby-shadow is required to use the "password" attribute in Chef
## http://wiki.opscode.com/display/chef/Resources#Resources-PasswordShadowHash
gem install ruby-shadow --no-ri --no-rdoc

gem install chef --version '~> 10.24.0' --no-ri --no-rdoc
mkdir -p /etc/chef /var/chef/cookbooks
touch /etc/chef/solo.rb

# Remove items used for building, since they aren't needed anymore
apt-get -y remove linux-headers-$(uname -r) # build-essential
apt-get -y autoremove