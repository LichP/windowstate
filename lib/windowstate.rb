# encoding: iso-8859-1
require 'json'
require 'windows/window'

module Windows
  module Window
    API.new('SetWindowPlacement', 'LP', 'B', 'user32')
  end
end

module WindowState
  include Windows::Window
  include Win32

  class WindowPlacement
    include Windows::Window
  
    attr_reader :handle, :data_encoded, :title
    attr_writer :title
  
    def self.get(handle)
      wp = new(handle)
      wp.get
      wp
    end
  
    def self.json_create(o)
      wp = new(o['data'][0])
      wp.title = o['data'][1]
      wp.data  = o['data'][2]
      wp
    end

    def initialize(handle)
      @handle = handle
    end
  
    def get
      wp_buffer = [44].pack("L") + '\0' * 40
      title_buffer = "\0" * 200

      GetWindowPlacement(handle, wp_buffer)
      @data_encoded = wp_buffer

      GetWindowText(handle, title_buffer, 200)
      @title = title_buffer.strip
    end
  
    def set
      SetWindowPlacement(handle, data_encoded)
    end
    
    def data
      data_encoded.unpack("L11")
    end
    
    def data=(array)
      @data_encoded = array.pack("L11")
    end
    
    def to_json(*a)
      puts title
      {
        'json_class' => self.class.name,
        'data'       => [handle, title, data]
      }.to_json(*a)
    end

    def inspect
      "#<WindowState::WindowPlacement:0x%08x @handle=%i, @title=\"%s\", data=%s>" % [object_id, handle, title, data]
    end
  end

  class WindowInfo
    include Windows::Window
    
    WS_CAPTION      = 0x00C00000
    WS_CHILD        = 0x40000000
    WS_CLIPSIBLINGS = 0x04000000
    WS_DISABLED     = 0x08000000
    WS_DLGFRAME     = 0x00400000
    WS_POPUP        = 0x80000000
    WS_SIZEBOX      = 0x00040000
    WS_SYSMENU      = 0x00080000
    WS_VISIBLE      = 0x10000000
    
    attr_reader :data_encoded, :handle
    
    def self.get(handle)
      wp = new(handle)
      wp.get
      wp
    end
    
    def initialize(handle)
      @handle = handle
    end
    
    def get
      buffer = [60].pack("L") + '\0' * 56
      GetWindowInfo(handle, buffer)
      @data_encoded = buffer
    end
    
    def data
      data_encoded.unpack("L14S2")
    end
    
    def style
      data[9]
    end
    
    def ignorable?
      style & (WS_DISABLED | WS_CHILD) > 0 
    end
    
    def application_window?
      mask = (WS_SYSMENU | WS_VISIBLE)
      (style & mask == mask) && !ignorable?
    end
    
    def data=(array)
      @data_encoded = array.pack("L14S2")
    end
    
    def to_json(*a)
      {
        'json_class' => self.class.name,
        'data'       => [handle, data]
      }.to_json(*a)
    end
    
    def inspect
      "#<WindowState::WindowInfo:0x%08x @handle=%i, data=%s>" % [object_id, handle, data]
    end
  end

  @wp_save    = []
  @debug      = []

  @save_proc = API::Callback.new('LP', 'I') do |handle, param|
    wp = WindowPlacement.get(handle)
    wi = WindowInfo.get(handle)

    if wi.application_window?
      @wp_save << wp
    end
    true
  end

  @debug_proc = API::Callback.new('LP', 'I') do |handle, param|
    wp = WindowPlacement.get(handle)
    wi = WindowInfo.get(handle)

    @debug << {:wp => wp, :wi => wi}
    true
  end

  class << self
    include Windows::Window
    include Win32
    
    def get_state
      EnumWindows(@save_proc, nil)
    end
    
    def get_state_json
      get_state
      JSON.generate(@wp_save, object_nl: "\n")
    end
    
    def set_state(wp_array)
      wp_array.each { |wp| wp.set }
    end
    
    def set_state_json(wp_json)
      set_state(JSON.parse(wp_json))
    end
    
    def save(filename)
      File.open(filename, "w") do |dump_file|
        dump_file.puts get_state_json
      end
    end

    def restore(filename)
      set_state_json(File.read(filename))
    end
    
    def debug
      EnumWindows(@debug_proc, nil)
      @debug
    end
  end
end
  