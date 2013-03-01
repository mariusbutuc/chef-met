# 1. Install Nginx & Unicorn (from cookbooks)
include_recipe "nginx"
include_recipe "unicorn"
include_recipe "postgresql::server"
include_recipe "nodejs"

gem_package "bundler" do
  options("--no-ri --no-rdoc")
end

app_name = node[:app][:name]
deploy_to = "/home/#{node[:user][:name]}/#{app_name}"

# 3. Create necessary directories
directory "#{deploy_to}" do
  owner 'vagrant'
end

%w(config log tmp sockets pids).each do |dir|
  directory "#{deploy_to}/shared/#{dir}" do
    recursive true # mkdir -p
    mode 0755
  end
end

# 4. Configure the Unicorn app server
template "#{node[:unicorn][:config_path]}/#{app_name}.conf.rb" do
  mode 0644
  source "unicorn.conf.erb"
end

# 5. Create Nginx config template for this app's Virtual Host
nginx_config_path = "/etc/nginx/sites-available/#{app_name}.conf"

template nginx_config_path do
  mode 0644
  source "nginx.conf.erb"
  notifies :reload, "service[nginx]"
end

nginx_site "#{app_name}" do
  config_path nginx_config_path
  action :enable
end
