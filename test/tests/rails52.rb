require_relative '../test'

class Rails52Tests < Minitest::Test
  include BrakemanTester::FindWarning
  include BrakemanTester::CheckExpected

  def report
    @@report ||= BrakemanTester.run_scan "rails5.2", "Rails 5.2", run_all_checks: true
  end

  def expected
    @@expected ||= {
      :controller => 0,
      :model => 0,
      :template => 0,
      :generic => 1
    }
  end

  def test_cross_site_request_forgery_false_positive
    assert_no_warning :type => :controller,
      :warning_code => 7,
      :fingerprint => "6f5239fb87c64764d0c209014deb5cf504c2c10ee424bd33590f0a4f22e01d8f",
      :warning_type => "Cross-Site Request Forgery",
      :message => /^'protect_from_forgery'\ should\ be\ called\ /,
      :confidence => 0,
      :relative_path => "app/controllers/application_controller.rb"
  end

  def test_sql_injection_not
    assert_warning :type => :warning,
      :warning_code => 0,
      :fingerprint => "659ce3a1ad4a44065f64f44e73c857c80c9505ecf74a3ebe40f3454dc7185845",
      :warning_type => "SQL Injection",
      :line => 3,
      :message => /^Possible\ SQL\ injection/,
      :confidence => 2,
      :relative_path => "app/models/user.rb",
      :code => s(:call, s(:call, nil, :where), :not, s(:dstr, "blah == ", s(:evstr, s(:lvar, :thing)))),
      :user_input => s(:lvar, :thing)
  end

  def test_command_injection_1
    assert_no_warning :type => :warning,
      :warning_code => 14,
      :fingerprint => "d8881688ca97faef7a0f300a902237ea201e52a511a45561dcd7462ef85ae720",
      :warning_type => "Command Injection",
      :line => 7,
      :message => /^Possible\ command\ injection/,
      :confidence => 1,
      :relative_path => "lib/initthing.rb",
      :code => s(:dxstr, "", s(:evstr, s(:ivar, :@blah))),
      :user_input => s(:ivar, :@blah)
  end

  def test_command_injection_shellwords
    assert_no_warning :type => :warning,
      :warning_code => 14,
      :fingerprint => "89b886281c6329f5c5f319932d98ea96527d50f1d188fde9fd85ff93130b7c50",
      :warning_type => "Command Injection",
      :line => 9,
      :message => /^Possible\ command\ injection/,
      :confidence => 1,
      :relative_path => "lib/shell.rb",
      :code => s(:dxstr, "dig +short -x ", s(:evstr, s(:call, s(:const, :Shellwords), :shellescape, s(:lvar, :ip))), s(:str, " @"), s(:evstr, s(:call, s(:const, :Shellwords), :shellescape, s(:lvar, :one))), s(:str, " -p "), s(:evstr, s(:call, s(:const, :Shellwords), :escape, s(:lvar, :two)))),
      :user_input => s(:call, s(:const, :Shellwords), :shellescape, s(:lvar, :ip))
  end
end
