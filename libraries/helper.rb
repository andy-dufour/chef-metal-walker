require 'ipaddr'
require 'socket'
require 'timeout'

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
