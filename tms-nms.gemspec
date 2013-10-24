Gem::Specification.new do |s|
  s.name              = 'tms-nms'
  s.version           = '0.0.12'
  s.platform          = Gem::Platform::RUBY
  s.authors           = [ 'Saku Ytti' ]
  s.email             = %w( saku@ytti.fi )
  s.homepage          = 'http://lan-login1.fi.nms.tdc.net'
  s.summary           = 'Trivial Monitoring System'
  s.description       = 'Does ICMP and SNMP trap monitoring and alarming'
  s.rubyforge_project = s.name
  s.files             = `git ls-files`.split("\n")
  s.executables       = %w( tms_populate tmsd )
  s.require_path      = 'lib'

  s.add_dependency 'sequel'
  s.add_dependency 'sqlite3'
  s.add_dependency 'snmp'
  s.add_dependency 'net-ping'
end
