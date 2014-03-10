name             'application_wordpress'
maintainer       'BNOTIONS'
maintainer_email 'jonathon@bnotions.com'
license          'All rights reserved'
description      'Installs/Configures application_wordpress'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends          'build-essential'
depends          'application', '= 3.0'
depends          'mysql'
depends          'php'
depends          'apache2'
