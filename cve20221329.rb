##
# This module tests if a server is vulnerable to the CVE-2022-1329 vulnerability.
#
# Reference:
# https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-1329
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'CVE-2022-1329 Vulnerability Checker',
      'Description'    => 'Checks if a server is vulnerable to the CVE-2022-1329 vulnerability.',
      'Author'         => ['Author Name'],
      'License'        => MSF_LICENSE,
      'References'     => [
        ['CVE', '2022-1329']
      ]
    ))

    register_options([
      Opt::RHOST('server-ip', 'The IP address of the server'),
      Opt::RPORT(443, 'The port to use for the connection')
    ])
  end

  def run
    begin
      print_status("Connecting to the server...")
      connect

      print_status("Sending request to check for CVE-2022-1329 vulnerability...")
      res = send_request_raw({
        'uri' => '/.env',
        'method' => 'GET'
      })

      if res and res.code == 200 and res.body.include?('APP_KEY=')
        print_error("The server is vulnerable to the CVE-2022-1329 vulnerability.")
      else
        print_good("The server is not vulnerable to the CVE-2022-1329 vulnerability.")
      end

    rescue ::Rex::ConnectionError
      print_error("Could not connect to the server.")
    ensure
      disconnect
    end
  end

end
