#
# Cookbook Name:: chef-metal-winrm
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'ipaddr'
require 'socket'
require 'timeout'
require 'chef/provisioning/ssh_driver'


with_driver 'ssh'

def is_port_open?(ip, port)
  begin
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(ip, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::EHOSTDOWN
        return false
      end
    end
  rescue Timeout::Error
  end

  return false
end

def is_linux?(ip)
  is_port_open?(ip, 22)
end

def is_windows?(ip)
  is_port_open?(ip, 5985) || is_port_open?(ip, 5986)
end

starty = IPAddr.new("192.168.33.119")
endy = IPAddr.new("192.168.33.120")

(starty..endy).each do |ip|
    nodeIp = ip.to_s
    #Sometimes windows machines have a ssh daemon installed, so lets check it first to avoid false positives
    if is_windows?(nodeIp)
      with_machine_options :transport_options => {
            'is_windows' => true,
            'ip_address' => nodeIp,
            'port' => 5985,
            'username' => 'vagrant',
            'password' => 'vagrant'
        }
    elsif is_linux?(nodeIp)
      with_machine_options :transport_options => {
        'ip_address' => nodeIp,
        'username' => 'vagrant',
        'ssh_options' => {
          'password' => 'vagrant'
        }
      }
    else
      p "IP: #{nodeIp}, is not listening for ssh or WinRM connections."
      next
    end
    machine nodeIp do
      action [:setup, :converge]
      converge true
    end


end
