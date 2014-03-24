require 'tmpdir'

include_recipe 'build-essential'
include_recipe 'mysql::client'
include_recipe 'mysql::server'

execute 'create-database' do
  command "/usr/bin/mysqladmin -u root -p'#{node[:mysql][:server_root_password]}' create #{node[:wordpress][:db_name]}"
  not_if "echo 'show databases;' | mysql -u root -p'#{node[:mysql][:server_root_password]}' | grep #{node[:wordpress][:db_name]}"
end

execute 'grant-privileges' do
  command "/usr/bin/mysql -u root -p'#{node[:mysql][:server_root_password]}' < #{Dir.tmpdir}/grants.sql"
  action :nothing
end

template "#{Dir.tmpdir}/grants.sql" do
  source 'grants.sql.erb'
  owner 'root'
  mode 00600
  variables(
    :username => node[:wordpress][:db_user],
    :password => node[:wordpress][:db_password],
    :database => node[:wordpress][:db_name]
  )
  notifies :run, 'execute[grant-privileges]', :immediately
end

include_recipe 'php'
include_recipe 'php::fpm'

directory '/var/run/php-fpm/wordpress' do
  recursive true
end

include_recipe 'php::module_mysql'
include_recipe 'php::module_curl'
include_recipe 'php::module_gd'
include_recipe 'application_wordpress::wp_cli'

bash 'wp-core-config' do
  cwd '/vagrant'
  code "/usr/local/bin/wp core config --dbname='#{node[:wordpress][:db_name]}' --dbuser='#{node[:wordpress][:db_user]}' --dbpass='#{node[:wordpress][:db_password]}' --dbhost='#{node[:wordpress][:db_host]}' --dbprefix='#{node[:wordpress][:db_prefix]}' --dbcharset='#{node[:wordpress][:db_charset]}' --locale='#{node[:wordpress][:locale]}' --allow-root"
  creates '/vagrant/wp-config.php'
end

bash 'wp-core-install' do
  cwd '/vagrant'
  code "/usr/local/bin/wp core install --url='#{node[:wordpress][:url]}' --title='#{node[:wordpress][:site_title]}' --admin_user='#{node[:wordpress][:admin_user]}' --admin_password='#{node[:wordpress][:admin_password]}' --admin_email='#{node[:wordpress][:admin_email]}' --allow-root"
  not_if 'wp core is-installed'
end

unless node[:wordpress][:theme].nil?
  bash 'wp-theme-activate' do
    cwd '/vagrant'
    code "/usr/local/bin/wp theme activate '#{node[:wordpress][:theme]}' --allow-root"
    only_if "wp theme is_installed #{node[:wordpress][:theme]} --allow-root"
  end
end

unless node[:wordpress][:plugins].nil?
  node[:wordpress][:plugins].each do |wp_plugin|
    bash 'wp-plugin-activate' do
      cwd '/vagrant'
      code "/usr/local/bin/wp plugin activate '#{wp_plugin}' --allow-root"
      only_if "/usr/local/bin/wp plugin is-installed '#{wp_plugin}' --allow-root"
    end
  end
end

cookbook_file '/vagrant/.htaccess' do
  source 'htaccess.txt'
  owner 'vagrant'
  group 'vagrant'
  mode 00644
end

%w{ upload blogs.dir upgrade cache }.each do |d|
  directory "/vagrant/wp-content/#{d}" do
    owner 'vagrant'
    group 'vagrant'
    mode 00644
  end
end

%w{ sitemap.xml sitemap.xml.gz wp-content/advanced-cache.php wp-content/wp-cache-config.php }.each do |f|
  file "/vagrant/#{f}" do
    owner 'vagrant'
    group 'vagrant'
    mode 00644
    action :touch
  end
end

php_fpm 'wordpress' do
  action :add
  user 'vagrant'
  group 'vagrant'
  socket true
  socket_path '/var/run/php-fpm/wordpress.sock'
  socket_perms "0666"
  start_servers 2
  min_spare_servers 2
  max_spare_servers 4
  max_children 4
end

include_recipe 'apache2'
include_recipe 'apache2::mod_actions'
include_recipe 'apache2::mod_fastcgi'

cookbook_file '/etc/apache2/mods-available/fastcgi.conf' do
  owner 'root'
  group 'root'
  mode 00644
end

web_app 'wordpress' do
  template 'wordpress.apache2.conf.erb'
  server_name 'wordpress'
  server_aliases ['*']
  docroot '/vagrant'
  php_bin '/var/run/php-fpm/wordpress'
  fpm_socket '/var/run/php-fpm/wordpress.sock'
end
