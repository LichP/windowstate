require 'json'
require 'tmpdir'
require 'windows/window'

module Windows
  module Window
    API.new('SetWindowPlacement', 'LP', 'B', 'user32')
  end
end

include Windows::Window
include Win32

class WindowPlacement
  include Windows::Window
  
  attr_reader :data_encoded, :handle
  
  def self.get(handle)
    wp = new(handle)
    wp.get
    wp
  end
  
  def self.json_create(o)
    wp = new(o['data'][0])
    wp.data = o['data'][1]
    wp
  end

  def initialize(handle)
    @handle = handle
  end
  
  def get
    buffer = [44].pack("L") + '\0' * 40
    GetWindowPlacement(handle, buffer)
    @data_encoded = buffer
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
    {
      'json_class' => self.class.name,
      'data'       => [handle, data]
    }.to_json(*a)
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
end

window_placements = []

EnumWindowsProc = API::Callback.new('LP', 'I') do |handle, param|
  title_buffer = "\0" * 200
  rect_buffer = "\0" * 32

  GetWindowText(handle, title_buffer, 200)
  GetWindowRect(handle, rect_buffer)
  wp = WindowPlacement.get(handle)
  wi = WindowInfo.get(handle)
  left, top, right, bottom = rect_buffer.unpack("L4")

  if wi.application_window?
    puts "#{handle} : #{title_buffer.strip} : #{left},#{top} #{right},#{bottom} : #{wi.data} : 0x#{wi.style.to_s(16)}"
    window_placements << wp
    true
  end

  true
end

EnumWindows(EnumWindowsProc, nil)

#File.open(File.join(Dir.tmpdir, "windowstate.json"), "w") do |dump_file|
#  dump_file.puts JSON.generate(window_placements, object_nl: "\n")
#end

window_placements_read = JSON.parse(File.read(File.join(Dir.tmpdir, "windowstate.json")))

#console_window_placement = window_placements_read.find { |window| window.handle == 201280 }
#console_window_placement.set

window_placements_read.each { |wp| wp.set }
