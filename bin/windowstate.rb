begin
  require 'windowstate'
rescue LoadError
  $:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
  require 'windowstate'
end

require 'trollop'
require 'tmpdir'

SUB_COMMANDS = %w(save restore debug)

global_opts = Trollop::options do
  banner "Save and restore the position and size of application windows"
  banner ""
  banner "Usage:"
  banner ""
  banner "    #{File.basename($0)} [GLOBAL OPTIONS] COMMAND [COMMAND OPTIONS]"
  banner ""
  banner "Commands:"
  banner ""
  banner "    save            Save the state of current application windows"
  banner "    restore         Restore the state of current application windows from an earlier save"
  banner "    debug           Generate debugging information"
  banner ""
  banner "Global options:"
  banner ""

  opt :file, "File to use to save/restore state",
      short:   "-f",
      default: File.join(Dir.tmpdir, "windowstate.json")
      
  stop_on SUB_COMMANDS
end

cmd = ARGV.shift

cmd_opts = case cmd
  when "save"
    Trollop::options do
      opt :stdout, "Write state JSON to stdout instead of to file",
          short:   "-c",
          default: false
    end
  when "restore"
    Trollop::options do
    end
  when "debug"
    Trollop::options do
    end
  else
    Trollop::die "unknown subcommand #{cmd.inspect}"
end

case cmd
  when 'save'
    if cmd_opts[:stdout]
      puts WindowState.get_state_json
    else
      WindowState.save(global_opts[:file])
    end
  when 'restore'
    WindowState.restore(global_opts[:file])
  when 'debug'
    debug_data = WindowState.debug
    debug_data.each do |hash|
      hash.each_pair do |key, value|
        puts "%s: %s" % [key.to_s, value.inspect]
      end
    end
end
