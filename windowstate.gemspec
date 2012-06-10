require "./lib/windowstate/version"

Gem::Specification.new do |s|
  s.name = "windowstate"
  s.version = WindowState::VERSION
  s.summary = %{Save and restore window positions and sizes on MS Windows}
  s.description = %Q{WindowState is a utility for saving and restoring the
    positions and sizes of your application windows, which is useful for
    monitor hotplugging when Windows decides to shrink everything and
    shove it in the top-left corner of your desktop.}
  s.authors = ["Phil Stewart"]
  s.email = ["phil.stewart@lichp.co.uk"]
  s.homepage = "http://github.com/lichp/windowstate"

  s.files = Dir[
    "lib/**/*.rb",
    "README*",
    "LICENSE",
    "Rakefile",
    "bin/windowstate.rb"
  ]

  s.bindir = 'bin'
  s.executables = 'windowstate.rb'

  s.add_dependency "windows-pr", "~> 1.2"
  s.add_dependency "trollop", "~> 1"
  s.add_development_dependency "ocra", "~> 1.3"
end
