include Chef::DSL::IncludeRecipe

action :before_compile do

  new_resource.migration_command "/usr/local/bin/wp core update-db"

  new_resource.symlink_before_migrate.update({
    new_resource.wp_config_base => new_resource.wp_config_file,
  })

  new_resource.symlink_before_migrate.update({
    new_resource.wp_uploads_base => new_resource.wp_uploads_dir,
  })

end

action :before_deploy do

  install_packages

end

action :before_symlink do

  directory "#{new_resource.shared_path}/uploads" do
    owner new_resource.owner
    group new_resource.group
    mode 00755
    recursive true
  end

  wp_salts = <<-EOF
define('AUTH_KEY',         '#{new_resource.wordpress.auth_key}');
define('SECURE_AUTH_KEY',  '#{new_resource.wordpress.secure_auth_key}');
define('LOGGED_IN_KEY',    '#{new_resource.wordpress.logged_in_key}');
define('NONCE_KEY',        '#{new_resource.wordpress.nonce_key}');
define('AUTH_SALT',        '#{new_resource.wordpress.auth_salt}');
define('SECURE_AUTH_SALT', '#{new_resource.wordpress.secure_auth_salt}');
define('LOGGED_IN_SALT',   '#{new_resource.wordpress.logged_in_salt}');
define('NONCE_SALT',       '#{new_resource.wordpress.nonce_salt}');
  EOF

  bash 'wp-core-config' do
    cwd new_resource.release_path
    code "/usr/local/bin/wp core config --dbname='#{new_resource.wordpress.db_name}' --dbuser='#{new_resource.wordpress.db_user}' --dbpass='#{new_resource.wordpress.db_pass}' --dbhost='#{new_resource.wordpress.db_host}' --dbprefix='#{new_resource.wordpress.db_prefix}' --dbcharset='#{new_resource.wordpress.db_charset}' --dbcollate='#{new_resource.wordpress.db_collate}' --locale='#{new_resource.wordpress.locale}' --skip-salts --extra-php << #{wp_salts}"
    creates '/vagrant/wp-config.php'
  end

  bash 'wp-core-install' do
    cwd new_resource.release_path
    code "/usr/local/bin/wp core install --url='#{new_resource.wordpress.url}' --title='#{new_resource.wordpress.site_title}' --admin_user='#{new_resource.wordpress.admin_user}' --admin_password='#{new_resource.wordpress.admin_pass}' --admin_email='#{new_resource.wordpress.admin_email}'"
    not_if '/usr/local/bin/wp core is-installed'
  end

  bash 'wp-theme-activate' do
    cwd new_resource.release_path
    code "/usr/local/bin/wp theme activate #{new_resource.wordpress.theme}"
    only_if "/usr/local/bin/wp theme is-installed #{new_resource.wordpress.theme}"
  end

end

action :before_migrate do

end

action :before_restart do

end

action :after_restart do

end

protected

def install_packages
  include_recipe 'php'
  include_recipe 'mysql::client'
  include_recipe 'application_wordpress::wp_cli'
end
