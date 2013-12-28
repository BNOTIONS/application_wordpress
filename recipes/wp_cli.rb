include_recipe 'php'

remote_file '/usr/local/bin/wp' do
  source 'https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
  action :create_if_missing
  mode 00755
end
