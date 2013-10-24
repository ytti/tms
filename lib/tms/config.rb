module TMS
  require 'ostruct'
  require 'yaml'
  require 'fileutils'

  class Config < OpenStruct
    Root  = File.join ENV['HOME'], '.config', 'tms'
    Crash = File.join Root, 'crash.' + $$.to_s

    def initialize file=File.join(Config::Root, 'config')
      super()
      @file = file.to_s
    end

    def load
      if File.exists? @file
        marshal_load key_flip(YAML.load_file(@file))
      else
        create_config
      end
    end

    def save
      File.write @file, YAML.dump(key_flip(marshal_dump))
    end

    private

    def create_config
      FileUtils.mkdir_p Config::Root
      CFG.community = 'public'
      CFG.corona    = '/tmp/corona.db'
      CFG.periodic  = 10
      CFG.trap      = { 
        'address'   => '192.0.2.42',
        'port'      => 162,
        'file'      => File.join(Config::Root, 'trap'),
      }
      CFG.email     = {
        'to'        => 'foo@example.com',
        'from'      => 'bar@example.com',
      }
      CFG.db        = File.join Config::Root, 'database'
      CFG.log       = File.join Config::Root, 'log'
      CFG.debug     = false
      CFG.save
    end

    def key_flip data
      new_data = data.dup
      data.keys.each do |key|
        new_key = key.class == Symbol ? key.to_s : key.to_sym
        new_data[new_key] = data[key]
        new_data.delete key
      end
      new_data
    end

  end

  CFG = Config.new
  CFG.load
  if defined? Log
    Log.file = CFG.log if CFG.log
    Log.level = Logger::INFO unless CFG.debug
  end
end
