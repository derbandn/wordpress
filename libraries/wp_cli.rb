
module WP
 class Chef::Recipe::WP_cli
    def self.wp_cli_run(command)
      # Dir.mkdir "/var/www" if !Dir.exists?("/var/www")
      if Dir.exists?("/var/www")
        Dir.chdir("/var/www")
        cmd_result= system(command) #`wp core install --allow-root`
      end

    end
  end  
end
