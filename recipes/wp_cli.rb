
template "/var/www/wp-cli.yml" do
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


if (!File.exists?("/usr/local/bin/wp"))
  
  remote_file "wp-cli.phar" do
      source 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
      mode "0744"
      path "/usr/local/bin/wp"
  end  
  
  execute "wp-cli" do
      command "wp core install --allow-root && wp theme activate twentyfifteen --allow-root"
      cwd "/var/www"
  end
  
end







