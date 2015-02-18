
template "#{node['wordpress']['parent_dir']}/wp-cli.yml" do
  source 'wp-cli.yml.erb'
  
  variables(
    :wp_path          => node['wordpress']['dir'],
    :wp_host_name     => node['wordpress']['host_name'],
    :title            => node['wordpress']['title'],
    :admin_user       => node['wordpress']['admin_user'],
    :admin_psw        => node['wordpress']['admin_psw'],
    :admin_email      => node['wordpress']['admin_email']
    )
    
  action :create
end


if (!File.exists?(node['wordpress']['wp-cli_path']))
  Chef::Log.warn("***** wp-cli not found at #{node['wordpress']['wp-cli_path']}  *****")
  Chef::Log.info("Beginning download wp-cli from #{node['wordpress']['wp-cli_url']}")
  
  remote_file "wp-cli.phar" do
      source node['wordpress']['wp-cli_url']
      mode "0744"
      path node['wordpress']['wp-cli_path']
  end  
  
  Chef::Log.info("Running command: wp core install --allow-root && wp theme activate twentyfifteen --allow-root using #{node['wordpress']['parent_dir']}")
  execute "wp-cli" do
      command "wp core install --allow-root && wp theme activate twentyfifteen --allow-root"
      cwd node['wordpress']['parent_dir']
  end
  
end







