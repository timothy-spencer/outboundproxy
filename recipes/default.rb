#
# Cookbook Name:: outboundproxy
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

aws_account_id = `no_proxy=169.254.169.254 curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep -oP '(?<="accountId" : ")[^"]*(?=")'`.chomp
aws_region = node['ec2']['placement_availability_zone'].gsub(/[a-z]$/,'')

# get sudo going
include_recipe 'sudo'

# XXX This kms entry sucks.  We'd much rather have it go direct, but seahorse does not seem to support no_proxy
node.default['squid']['acls'].push([ 'kms', 'dstdomain', "kms.#{aws_region}.amazonaws.com" ])

# enable ssl bump so we can ssldump
node.default['squid']['package'] = 'squid'
node.default['squid']['use_source'] = true
node.default['squid']['enable_ssl_bump'] = node['obproxy']['ssl_bump_enabled']
package 'ssldump'

# This expects outbound_squid_acls  outbound_squid_hosts  outbound_squid_urls databags to be set up.
include_recipe 'squid::sslbump'
include_recipe 'squid'

# squid doesn't seem to get started with the recipe, so this makes sure that it is up before we are done
execute 'killall -q squid squid-1 ; sleep 1'
execute 'until service squid3 check >/dev/null 2>&1 ; do service squid3 start ; sleep 5 ; done'

# The init script seems a bit broken (restarts don't work, stop is async, so start doesn't work),
# so this is a failsafe for if we turn ssl_bump on/off and need it to reconfig.
execute '/etc/init.d/squid3 reconfigure || true'

