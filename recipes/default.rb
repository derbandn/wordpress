#
# Cookbook Name:: wordpress
# Recipe:: default
#
# Copyright 2009-2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#





script "security setup" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    firewall-cmd --zone=public --add-port=3306/tcp
    firewall-cmd --zone=public --add-port=80/tcp
    firewall-cmd --zone=public --add-port=443/tcp
    firewall-cmd --reload
    
    setenforce permissive
    
  EOH
end



include_recipe "php"

# On Windows PHP comes with the MySQL Module and we use IIS on Windows

include_recipe "php::module_mysql"
include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "openssl"


include_recipe "wordpress::database"
# include_recipe "wordpress::security"

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
node.set_unless['wordpress']['keys']['auth'] = secure_password
node.set_unless['wordpress']['keys']['secure_auth'] = secure_password
node.set_unless['wordpress']['keys']['logged_in'] = secure_password
node.set_unless['wordpress']['keys']['nonce'] = secure_password
node.set_unless['wordpress']['salt']['auth'] = secure_password
node.set_unless['wordpress']['salt']['secure_auth'] = secure_password
node.set_unless['wordpress']['salt']['logged_in'] = secure_password
node.set_unless['wordpress']['salt']['nonce'] = secure_password
node.save unless Chef::Config[:solo]

directory node['wordpress']['dir'] do
  action :create
  if platform_family?('windows')
    rights :read, 'Everyone'
  else
    owner 'root'
    group 'root'
    mode  '00755'
  end
end

archive = platform_family?('windows') ? 'wordpress.zip' : 'wordpress.tar.gz'


  remote_file "#{Chef::Config[:file_cache_path]}/#{archive}" do
    source node['wordpress']['url']
    action :create
    not_if {::File.exists?("#{node['wordpress']['dir']}/index.php")}
  end

  execute "extract-wordpress" do
    command "tar xf #{Chef::Config[:file_cache_path]}/#{archive} -C #{node['wordpress']['parent_dir']}"
    creates "#{node['wordpress']['dir']}/index.php"
    not_if {::File.exists?("#{node['wordpress']['dir']}/index.php")}
  end


template "#{node['wordpress']['dir']}/wp-config.php" do
  source 'wp-config.php.erb'
  variables(
    :db_name          => node['wordpress']['db']['name'],
    :db_user          => node['wordpress']['db']['user'],
    :db_password      => node['wordpress']['db']['pass'],
    :db_host          => node['wordpress']['db']['host'],
    :auth_key         => node['wordpress']['keys']['auth'],
    :secure_auth_key  => node['wordpress']['keys']['secure_auth'],
    :logged_in_key    => node['wordpress']['keys']['logged_in'],
    :nonce_key        => node['wordpress']['keys']['nonce'],
    :auth_salt        => node['wordpress']['salt']['auth'],
    :secure_auth_salt => node['wordpress']['salt']['secure_auth'],
    :logged_in_salt   => node['wordpress']['salt']['logged_in'],
    :nonce_salt       => node['wordpress']['salt']['nonce'],
    :lang             => node['wordpress']['languages']['lang']
  )
  
  action :create
  not_if {File.exists?("#{node['wordpress']['dir']}/wp-config.php")}
end


  web_app "wordpress" do
    template "wordpress.conf.erb"
    docroot node['wordpress']['dir']
    server_name node['wordpress']['host_name']
    server_aliases node['wordpress']['server_aliases']
    enable true
  end




 include_recipe "wordpress::wp_cli"
 
 execute "security setup" do
    command "setenforce enforcing"    
end








