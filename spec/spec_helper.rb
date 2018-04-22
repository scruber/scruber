require "bundler/setup"
require "scruber"
require 'webmock/rspec'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

Dir[File.expand_path(File.dirname(__FILE__))+"/support/**/*.rb"].each { |f| require f }

Scruber::Helpers::UserAgentRotator.configure do
  add "Scruber 1.0", tags: [:robot, :scruber]
  add "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36", tags: [:desktop, :chrome, :macos]
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Use color in STDOUT
  config.color = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :progress # :documentation, :html, :textmate

end
