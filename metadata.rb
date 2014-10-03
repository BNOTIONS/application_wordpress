name             'application_wordpress'
maintainer       'BNOTIONS'
maintainer_email 'jonathon@bnotions.com'
license          'All rights reserved'
description      'Installs/Configures application_wordpress'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.2'

depends          'apt', '= 2.6.0'
depends          'build-essential', '= 2.0.6'
depends          'application', '= 4.1.4'
depends          'mysql', '= 5.5.3'
depends          'php', '= 1.2.3'
depends          'apache2', '= 2.0.0'
