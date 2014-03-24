
default[:wordpress][:url]        = '33.33.33.10'
default[:wordpress][:site_title] = 'My Wordpress Blog'

default[:wordpress][:db_host]     = 'localhost'
default[:wordpress][:db_name]     = 'wordpress'
default[:wordpress][:db_user]     = 'wordpress'
default[:wordpress][:db_password] = 'vagrant'
default[:wordpress][:db_prefix]   = 'wp_'
default[:wordpress][:db_charset]  = 'utf8'
default[:wordpress][:db_collate]  = nil
default[:wordpress][:locale]      = 'en_US'

default[:wordpress][:admin_user]     = 'admin'
default[:wordpress][:admin_password] = 'vagrant'
default[:wordpress][:admin_email]    = 'vagrant@localhost'

default[:wordpress][:theme]   = nil
default[:wordpress][:plugins] = []
