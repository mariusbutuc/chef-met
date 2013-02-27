# 1. Install Nginx & Unicorn (from cookbooks)
include_recipe "nginx"
include_recipe "unicorn"

gem_package "bundler" do
  options("--no-ri --no-rdoc")
end

# 3. Create necessary directories
directory "/home/#{node[:user][:name]}/#{node[:app][:name]}" do
  owner 'vagrant'
end

directory "/home/#{node[:user][:name]}/#{node[:app][:name]}" + '/current' do
  owner 'vagrant'
end

%w(config log tmp sockets pids).each do |dir|
  directory "/home/#{node[:user][:name]}/#{node[:app][:name]}/shared/#{dir}" do
    recursive true # mkdir -p
    mode 0755
  end
end

# 4. Configure the Unicorn app server
template "#{node[:unicorn][:config_path]}/#{node[:app][:name]}.conf.rb" do
  mode 0644
  source "unicorn.conf.erb"
end

# 5. Create Nginx config template for this app's Virtual Host
nginx_config_path = "/etc/nginx/sites-available/#{node[:app][:name]}.conf"

template nginx_config_path do
  mode 0644
  source "nginx.conf.erb"
  notifies :reload, "service[nginx]"
end

nginx_site "#{node[:app][:name]}" do
  config_path nginx_config_path
  action :enable
end
