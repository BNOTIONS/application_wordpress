# multiverse repos required for apache2-mod-fastcgi
apt_repository 'precise-multiverse' do
  uri 'http://archive.ubuntu.com/ubuntu'
  distribution 'precise'
  components ['multiverse']
  deb_src true
  notifies :run, "execute[apt-get-update]", :immediately
end

apt_repository 'precise-updates-multiverse' do
  uri 'http://archive.ubuntu.com/ubuntu'
  distribution 'precise-updates'
  components ['multiverse']
  deb_src true
  notifies :run, "execute[apt-get-update]", :immediately
end
