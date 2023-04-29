##
# This module tests if a Microsoft Exchange Server is vulnerable to the ProxyLogon vulnerability.
#
# Reference:
# https://www.microsoft.com/security/blog/2021/03/02/hafnium-targeting-exchange-servers/
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'Microsoft Exchange Server ProxyLogon Vulnerability Checker',
      'Description'    => 'Checks if a Microsoft Exchange Server is vulnerable to the ProxyLogon vulnerability.',
      'Author'         => ['Author Name'],
      'License'        => MSF_LICENSE,
      'References'     => [
        ['URL', 'https://www.microsoft.com/security/blog/2021/03/02/hafnium-targeting-exchange-servers/']
      ]
    ))

    register_options([
      Opt::RHOST('exchange-server-ip', 'The IP address of the Microsoft Exchange Server'),
      Opt::RPORT(443, 'The port to use for the connection')
    ])
  end

  def run
    begin
      print_status("Connecting to the Exchange Server...")
      connect
      
      print_status("Sending request to check for ProxyLogon vulnerability...")
      res = send_request_cgi({
        'uri' => '/autodiscover/autodiscover.json',
        'method' => 'POST',
        'headers' => {
          'Content-Type' => 'application/json'
        },
        'data' => '{"User": {"@Type": "AlternateServiceAccount", "Email": "aaa"}'
      })

      if res and res.code == 500 and res.body.include?('X-CalculatedBETarget') and res.body.include?('X-BEServer')
        print_error("The Exchange Server is vulnerable to the ProxyLogon vulnerability.")
      else
        print_good("The Exchange Server is not vulnerable to the ProxyLogon vulnerability.")
      end

    rescue ::Rex::ConnectionError
      print_error("Could not connect to the Exchange Server.")
    ensure
      disconnect
    end
  end

end
