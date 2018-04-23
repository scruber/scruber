# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "scruber/version"

Gem::Specification.new do |spec|
  spec.name          = "scruber"
  spec.version       = Scruber::VERSION
  spec.authors       = ["Ivan Goncharov"]
  spec.email         = ["revis0r.mob@gmail.com"]

  spec.summary       = %q{Crawling framework}
  spec.description   = %q{Crawling framework}
  spec.homepage      = "https://github.com/scruber/scruber"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "typhoeus", '~> 1.1', '>= 1.1.2'
  spec.add_dependency "pickup", "~> 0.0.11"
  spec.add_dependency "nokogiri", '~> 1.8', '>= 1.8.2'
  spec.add_dependency "http-cookie", "1.0.3"
  spec.add_dependency "activesupport", '~> 5.1', '>= 5.1.5'
  spec.add_dependency "powerbar", '~> 2.0', '>= 2.0.1'
  spec.add_dependency "paint", '~> 2.0', '>= 2.0.1'
  spec.add_runtime_dependency "thor", "0.20.0"
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "3.0.1"
end
