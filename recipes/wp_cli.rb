
template "/var/www/wp-cli.yml" do
  source 'wp-cli.yml.erb'
  action :create
end

remote_file "wp-cli.phar" do
    source 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
    mode "0744"
    path "/usr/local/bin/wp"
end

execute "wp-cli" do
    command "wp core install --allow-root && wp theme activate twentyfifteen --allow-root"
    cwd "/var/www"
    
end





