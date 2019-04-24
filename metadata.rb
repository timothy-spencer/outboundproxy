name             'outboundproxy'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures outboundproxy'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.3'

depends          'users'
depends          'sudo'
depends          'squid', '~> 4.0'
depends          'service_discovery'
depends          'identity-elk'

