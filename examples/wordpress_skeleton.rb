#
# Cookbook Name:: wordpress-skeleton
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "database::mysql"

mysql_connection = {
  :host     => 'localhost',
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

mysql_database "wordpress" do
  connection mysql_connection
  action :create
end

mysql_database_user "wordpress" do
  connection mysql_connection
  password "wordpress"
end

mysql_database_user "wordpress" do
  connection mysql_connection
  host "%"
  privileges [:all]
  database_name "wordpress"
  action :grant
end

application "wordpress-skeleton" do
  packages   %w{ git-core libpcre3-dev zlib1g-dev sendmail }
  path       "/srv/wordpress-skeleton"
  owner      "vagrant"
  group      "vagrant"
  repository "https://github.com/jwmarshall/wordpress-skeleton.git"
  revision   "master"
  migrate    true

  wordpress do
    url        "http://wordpress"
    site_title "My Wordpress Blog"
    theme      "twentyfourteen"
    plugins    %w{ hello }

    # database
    db_name     "wordpress"
    db_host     "localhost"
    db_user     "wordpress"
    db_password "wordpress"

    # admin
    admin_user     "jonathon"
    admin_password "wordpress"
    admin_email    "jonathon@bnotions.com"

    # wp secrets
    auth_key         'Q_T9*Uy;>6 8LDI76bF1v`o2Ga%G5,K,]oCbR9(),drE-pp4?j4%Mp[5:[n7W?XE'
    auth_salt        '+*,h71]`ZT6F-*5}YgE#j}A/HfPJvNPr1Yjm#0{S%.~;:-S3M4_>>|&+6;r{85T`'
    secure_auth_key  'wfd3FCL6>d]vVVL9bjihdRYo&yKdvK@`kn9/*:{X/bo;6)(MB<ninQ%y+}XMEA[Q'
    secure_auth_salt 'x5fFq(9>DF-571;NCl7r;^ee/_NFX>O(HKO`m()ienW{7Mf~l]V}uY0iu>|d-I1a'
    logged_in_key    '5X_gGXmI}C/yaqO4(HcWu/QEN($ Q;s|}:s]c;B5kq`jh2~h|!eeByZ2w*0+< 4*'
    logged_in_salt   'zFz(.0q2}z#.,-maHlvUg`iN]5B:2`O5}%;nfI.s5H/8DIoIiK|cgcF8+ce5wlq:'
    nonce_key        '@=F_EkUH4oT}<Oibx~|iY-~L5MpDMj(.9AvvN2zbN&gYT&B~w^T+T=)S)O4|7f>j'
    nonce_salt       'HD(umc}On5IbG@u##WWgWcZ`Nf. kLJ|E) ntK$FeWVxXWfy)[|R|B@V{<]v/^@!'
  end

  mod_php_apache2 do
    server_aliases %w{ wordpress }
    webapp_template "apache2.conf.erb"
  end

end
