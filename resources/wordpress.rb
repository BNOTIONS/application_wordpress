include ApplicationCookbook::ResourceBase

attribute :debug,      :kind_of => [TrueClass, FalseClass], :default => false

attribute :url,        :kind_of => String, :default => nil
attribute :site_title, :kind_of => String, :default => nil

attribute :db_host,     :kind_of => String, :default => 'localhost'
attribute :db_name,     :kind_of => String, :default => nil
attribute :db_user,     :kind_of => String, :default => nil
attribute :db_password, :kind_of => String, :default => nil
attribute :db_prefix,   :kind_of => String, :default => 'wp_'
attribute :db_charset,  :kind_of => String, :default => 'utf8'
attribute :db_collate,  :kind_of => String, :default => nil
attribute :locale,      :kind_of => String, :default => nil

attribute :auth_key,        :kind_of => String, :default => nil
attribute :secure_auth_key, :kind_of => String, :default => nil
attribute :logged_in_key,   :kind_of => String, :default => nil
attribute :nonce_key,       :kind_of => String, :default => nil

attribute :auth_salt,        :kind_of => String, :default => nil
attribute :secure_auth_salt, :kind_of => String, :default => nil
attribute :logged_in_salt,   :kind_of => String, :default => nil
attribute :nonce_salt,       :kind_of => String, :default => nil

attribute :admin_email,    :kind_of => String, :default => nil
attribute :admin_user,     :kind_of => String, :default => 'admin'
attribute :admin_password, :kind_of => String, :default => nil

attribute :theme,   :kind_of => String, :default => nil
attribute :plugins, :kind_of => [Array, NilClass], :default => nil

attribute :wp_config_file, :kind_of => String, :default => 'wp-config.php'
attribute :wp_uploads_dir, :kind_of => String, :default => 'wp-content/uploads'

attribute :config_template, :kind_of => [String, NilClass], :default => nil

def wp_config_base
  wp_config_file.split(/[\\\/]/).last
end

def wp_uploads_base
  wp_uploads_dir.split(/[\\\/]/).last
end
