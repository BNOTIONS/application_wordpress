include Chef::DSL::IncludeRecipe

action :before_compile do

  include_recipe 'php'
  include_recipe 'mysql::client'
  include_recipe 'php::module_gd'
  include_recipe 'php::module_mysql'
  include_recipe 'application_wordpress::wp_cli'

  new_resource.migration_command "/usr/local/bin/wp core update-db"

  new_resource.symlinks.update(
    new_resource.wp_uploads_base => new_resource.wp_uploads_dir
  )

  new_resource.symlink_before_migrate.update(
    new_resource.wp_config_base => new_resource.wp_config_file
  )

  directory ::File.join(new_resource.path, "shared", new_resource.wp_uploads_base) do
    owner new_resource.owner
    group new_resource.group
    mode 00755
    recursive true
  end

end

action :before_deploy do

  template "#{new_resource.shared_path}/#{new_resource.wp_config_base}" do
    source new_resource.config_template || "wp-config.php.erb"
    cookbook new_resource.config_template ? new_resource.cookbook_name.to_s : "application_wordpress"
    owner new_resource.owner
    group new_resource.group
    mode 00644
    variables ({
      :debug => new_resource.debug,
      :db_name => new_resource.db_name,
      :db_host => new_resource.db_host,
      :db_user => new_resource.db_user,
      :db_password => new_resource.db_password,
      :db_prefix => new_resource.db_prefix,
      :db_charset => new_resource.db_charset,
      :db_collate => new_resource.db_collate,
      :locale => new_resource.locale,
      :auth_key => new_resource.auth_key,
      :secure_auth_key => new_resource.secure_auth_key,
      :logged_in_key => new_resource.logged_in_key,
      :nonce_key => new_resource.nonce_key,
      :auth_salt => new_resource.auth_salt,
      :secure_auth_salt => new_resource.secure_auth_salt,
      :logged_in_salt => new_resource.logged_in_salt,
      :nonce_salt => new_resource.nonce_salt
    })
  end

  cookbook_file "#{new_resource.shared_path}/htaccess" do
    source 'htaccess.txt'
    cookbook new_resource.config_template ? new_resource.cookbook_name.to_s : "application_wordpress"
    owner new_resource.owner
    group new_resource.group
    mode 00644
    action :create_if_missing # prevent overwriting file because there maybe local changes
  end

end

action :before_symlink do
end

action :before_migrate do

  # this is a hack because before_migrate is called before symlink_before_migrate
  link "#{new_resource.release_path}/#{new_resource.wp_config_file}" do
    to "#{new_resource.shared_path}/#{new_resource.wp_config_base}"
  end

  link "#{new_resource.release_path}/.htaccess" do
    to "#{new_resource.shared_path}/htaccess"
  end

  # should only be called on the first run of a new wordpress site
  bash "wp-core-install" do
    user new_resource.owner
    cwd new_resource.release_path
    code <<-EOF
    /usr/local/bin/wp core install --url='#{new_resource.url}' --title='#{new_resource.site_title}' --admin_user='#{new_resource.admin_user}' --admin_password='#{new_resource.admin_password}' --admin_email='#{new_resource.admin_email}'
    EOF
    not_if "/usr/local/bin/wp core is-installed", :cwd => new_resource.release_path, :user => new_resource.owner
  end

end

action :before_restart do

  execute "wp-theme-activate" do
    user new_resource.owner
    cwd new_resource.release_path
    command "/usr/local/bin/wp theme activate #{new_resource.theme}"
    only_if "/usr/local/bin/wp theme is-installed #{new_resource.theme}", :cwd => new_resource.release_path, :user => new_resource.owner
  end

  unless new_resource.plugins.nil?
    new_resource.plugins.each do |wp_plugin|
      execute "wp-plugin-activate[#{wp_plugin}]" do
        user new_resource.owner
        cwd new_resource.release_path
        command "/usr/local/bin/wp plugin activate #{wp_plugin}"
        only_if "/usr/local/bin/wp plugin is-installed #{wp_plugin}", :cwd => new_resource.release_path, :user => new_resource.owner
      end
    end
  end

end

action :after_restart do
end
