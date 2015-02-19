

Chef::Log.warn("*****Begining security setup *****")

package "setroubleshoot" do
  action :install
  # source "setroubleshoot"
  provider Chef::Provider::Package::Rpm
  not_if{"yum list |grep setroubleshoot"}
end


cookbook_file "root_ca.cer" do
  path "#{node['wordpress']['dir']}/certificates/root_ca.cer"
  action :create_if_missing
end

remote_directory "certificates" do
  path "#{node['wordpress']['dir']}"
  action :create
end

remote_directory "selinux_policies" do
  path "#{node['wordpress']['parent_dir']}"
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
end
