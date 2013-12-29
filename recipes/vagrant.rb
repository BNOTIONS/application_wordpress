require 'tmpdir'

include_recipe 'application_wordpress::wp_cli'
include_recipe 'php::module_mysql'
include_recipe 'php::module_curl'
include_recipe 'php::module_gd'

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
    :password => node[:wordpress][:db_pass],
    :database => node[:wordpress][:db_name]
  )
  notifies :run, 'execute[grant-privileges]', :immediately
end

bash 'wp-core-config' do
  cwd '/vagrant'
  code "/usr/local/bin/wp core config --dbname='#{node[:wordpress][:db_name]}' --dbuser='#{node[:wordpress][:db_user]}' --dbpass='#{node[:wordpress][:db_pass]}' --dbhost='#{node[:wordpress][:db_host]}' --dbprefix='#{node[:wordpress][:db_prefix]}' --dbcharset='#{node[:wordpress][:db_charset]}' --dbcollate-'#{node[:wordpress][:db_collate]}' --locale='#{node[:wordpress][:locale]}'"
  creates '/vagrant/wp-config.php'
end

bash 'wp-core-install' do
  cwd '/vagrant'
  code "/usr/local/bin/wp core install --url='#{node[:wordpress][:url]}' --title='#{node[:wordpress][:site_title]}' --admin_user='#{node[:wordpress][:admin][:username]}' --admin_password='#{node[:wordpress][:admin][:password]}' --admin_email='#{node[:wordpress][:admin][:email]}'"
end

unless node[:wordpress][:active_theme].nil?
  bash 'wp-theme-activate' do
    cwd '/vagrant'
    code "/usr/local/bin/wp theme activate #{node[:wordpress][:active_theme]}"
  end
end

cookbook_file '/vagrant/.htaccess' do
  source 'htaccess.txt'
  owner 'vagrant'
  group 'vagrant'
  mode 00644
end

directory '/vagrant/wp-content/uploads' do
  owner 'vagrant'
  group 'vagrant'
  mode 00777
end

web_app 'wordpress' do
  template 'vagrant_wordpress.conf.erb'
  server_name 'wordpress'
  server_aliases ['*']
  docroot '/vagrant'
end
