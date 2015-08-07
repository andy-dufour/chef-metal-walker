#
# Cookbook Name:: chef-metal-winrm
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.


require 'chef/provisioning/ssh_driver'

with_driver 'ssh'

starty = IPAddr.new(node['chef-metal-walker']['startIP'])
endy = IPAddr.new(node['chef-metal-walker']['endIP'])

(starty..endy).each do |ip|
    nodeIp = ip.to_s
    #Sometimes windows machines have a ssh daemon installed, so lets check it first to avoid false positives
    if is_windows?(nodeIp)
      options = { :transport_options => {
            'is_windows' => true,
            'host' => nodeIp,
            'username' => node['chef-metal-walker']['windows']['user'],
            'password' => node['chef-metal-walker']['windows']['password']
        },
        convergence_options: {'ssl_verify_mode' => node['chef-metal-walker']['convergance_options']['ssl_verify_mode']}
    }
    elsif is_linux?(nodeIp)
      options = { :transport_options => {
        'ip_address' => nodeIp,
        'username' => node['chef-metal-walker']['linux']['user'],
        'ssh_options' => {
          'password' => node['chef-metal-walker']['linux']['password']
          }
        },
        convergence_options: {'ssl_verify_mode' => node['chef-metal-walker']['convergance_options']['ssl_verify_mode']}
      }
    else
      p "IP: #{nodeIp}, is not listening for ssh or WinRM connections."
      next
    end
    with_machine_options options
    with_chef_server node['chef-metal-walker']['chef_server'],
                 :client_name => node['chef-metal-walker']['chef_client_name'],
                 :signing_key_filename => node['chef-metal-walker']['chef_client_key']

    # What happens when we can't resolve?
    host = Resolv.new.getname(nodeIp)
    machine host do
      action [:converge]
      converge true
    end
end
