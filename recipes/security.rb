



package "setroubleshoot" do
  action :install
  # source "setroubleshoot"
  provider Chef::Provider::Package::Rpm
  not_if{"yum list |grep setroubleshoot"}
end




remote_directory "certificates" do
  path "#{node['wordpress']['dir']}/certificates"
  recursive true
  action :create
end


remote_directory "selinux_policies" do
  path "#{node['wordpress']['parent_dir']}/selinux_policies"
  recursive true
  action :create
end



script "firewall setup" do
  interpreter "bash"
  user "root"
  code <<-EOH
    firewall-cmd --zone=public --add-port=3306/tcp --permanent
    firewall-cmd --zone=public --add-port=80/tcp --permanent
    firewall-cmd --zone=public --add-port=443/tcp --permanent
    firewall-cmd --reload
    
    
    # setenforce permissive
    # grep mysqld /var/log/audit/audit.log | audit2allow -M mysqld-chef
    # semodule -i mysqld-chef.pp
    
  EOH
end

execute "selinux setup" do
    cwd "#{node['wordpress']['parent_dir']}/selinux_policies"
    command "semodule -i mysqld-chef.pp && setenforce enforcing"    
    not_if {"semodule -l|grep mysqld-chef"}
end

execute "enable selinux" do   
    command "setenforce enforcing"    
end

