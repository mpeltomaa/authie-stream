require File.expand_path('../lib/authie/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = "authie"
  s.description   = %q{Modified version of original Authie Rails library for storing user sessions in a backend database}
  s.summary       = s.description
  s.licenses      = ['MIT']
  s.version       = Authie::VERSION
  s.files         = Dir.glob("{lib,db}/**/*")
  s.require_paths = ["lib"]
  s.authors       = [""]
  s.email         = [""]
  s.add_dependency  'secure_random_string'
end
