
default[:wordpress][:url] = '33.33.33.10'
default[:wordpress][:site_title] = 'My Wordpress Blog'

default[:wordpress][:db_host] = 'localhost'
default[:wordpress][:db_name] = 'wordpress'
default[:wordpress][:db_user] = 'wordpress'
default[:wordpress][:db_pass] = 'vagrant'
default[:wordpress][:db_prefix] = 'wp_'
default[:wordpress][:db_charset] = 'utf8'
default[:wordpress][:db_collate] = nil
default[:wordpress][:locale] = 'en_US'

default[:wordpress][:admin][:username] = 'admin'
default[:wordpress][:admin][:password] = 'vagrant'
default[:wordpress][:admin][:email]    = 'vagrant@localhost'

default[:wordpress][:active_theme] = nil
default[:wordpress][:active_plugins] = []
