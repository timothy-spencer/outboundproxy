
# set up apt to slurp through proxy
template '/etc/apt/apt.conf.d/95proxy'

# set up chef to use proxy
directory '/etc/chef'
directory '/etc/chef/client.d'
template '/etc/chef/client.d/proxy.rb'

# get the SSL certs so we can ssl bump
install_certificates 'Installing ssl bump certificates' do
  service_tag_key 'Name'
  service_tag_value "asg-#{node.chef_environment}-outboundproxy"
  suffix 'sslbump'
  cert_user 'root'
  cert_group 'root'
  install_directory '/usr/local/share/ca-certificates'
end

execute '/usr/sbin/update-ca-certificates'

cert_bucket_prefix = node['service_discovery']['cert_bucket_prefix']
aws_region = Chef::Recipe::AwsMetadata.get_aws_region
aws_account_id = Chef::Recipe::AwsMetadata.get_aws_account_id
certbucket = "#{cert_bucket_prefix}.internal-certs.#{aws_account_id}-#{aws_region}"

template '/root/updateproxycert.sh' do
  mode 0755
  variables({
    chef_zero_client_configuration: node['elk']['chef_zero_client_configuration'],
    env: node.chef_environment,
    certbucket: certbucket
  })
end

cron_d 'proxy_cert_discovery' do
  minute '*'
  command '/root/updateproxycert.sh 2>&1 >> /var/log/proxycertdiscovery.log'
end

