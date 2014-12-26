#==============================================================================
# TheoAllen - Message Balloon
# Version : 2.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
#==============================================================================
($imported ||= {})[:Theo_MessageBalloonV2] = true
#==============================================================================
# Change Logs :
#------------------------------------------------------------------------------
# 2014.12.26 - Rewrite for version 2.0
#            - Get rid gradient background. Bring back windowskin
#            - Added opening animation
#            - Added <bm:x> tag for subject
#            - Compatibility with Namebox window
# 2013.09.05 - Finished script
#==============================================================================
=begin
  
  ==================
  *) Perkenalan :
  ------------------
  Script ini ngebikin kamu nampilin dialog dalam balloon diatas karakter
  
  =======================
  *) Cara penggunaan :
  -----------------------
  Pasang dibawah material namun diatas main.
  Masukkan gambar untuk ballon pointer di Graphics/system. Dan jangan lupa
  dinamain "ballonpointer".
  
  Edit konfigurasinya dan ikuti aturan script call berikut
  
  =======================
  *) Script Calls :
  -----------------------
  - message.balloon
  Panggil script call seperti ini untuk membuat text ditampilkan dalam model
  balloon
  
  - message.normal
  Panggil script call seperti ini untuk mengembalikan message seperti biasa
  
  - message.subject = angka
  Panggil script call seperti ini untuk menentukan subject yang berbicara.
  Angka disana adalah event ID. Jika kamu memasukkan 0, maka yang akan
  berbicara adalah player. Jika event ID tidak ada, maka message akan
  berubah seperti biasa
  
  Atau jika kalian kerepotan untuk membuat script call, kalian bisa memakai tag
  <bm:x> pada kotak dimana x adalah event ID tersebut. Contoh 
  
  <bm:1>Hai, apa kabar?
  
  =======================
  *) Terms of use :
  -----------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

=end
#==============================================================================
# Konfigurasi :
#==============================================================================
module Theo
  module Msg
  
  # Jarak keatas message balloon (default: 32)
    Buffer_Y     = 42
  
  # Ukuran font dalam balloon  
    FontSize     = 22
  
  # Batas minimum lebar window 
    MinimumWidth = 0
    
  # Gunakan animasi opening untuk mode balloon? (Butuh: Theo Basic Module)
    UseOpening   = true
    
  # Kecepatan opening
    OpeningSpeed = 25
    
  # Warna popup opening (red, green, blue)
    OpeningColor = Color.new(255,255,255)
    
  # Opening SE. Tuliskan dengan RPG::SE.new('nama', volume, pitch)
  # Isi dengan nil jika tidak digunakan
    OpeningSE = RPG::SE.new('Open1', 80, 150)
    
  # Closing SE. Tuliskan dengan RPG::SE.new('nama', volume, pitch)
  # Isi dengan nil jika tidak digunakan
    ClosingSE = nil
    
  end
end
#==============================================================================
# Akhir dari konfigurasi
#==============================================================================

#==============================================================================
# ** Game_Interpreter
#==============================================================================

class Game_Interpreter
    
  # Shortcut
  def message
    $game_message
  end
  
end

#==============================================================================
# ** Global window, taken from Sprite Extension
#==============================================================================

module Theo
  #--------------------------------------------------------------------------
  # * Get Global Window
  #--------------------------------------------------------------------------
  def self.window
    if @window.nil? || @window.disposed?
      @window = Window_Base.new(0,0,1,1)
      @window.visible = false
      @window.gobj_exempt if @window.respond_to?(:gobj_exempt)
      # Compatibility with mithran's
    end
    return @window
  end
  
end

#==============================================================================
# ** Bitmap
#==============================================================================

class Bitmap
  #--------------------------------------------------------------------------
  # * Border fill
  #--------------------------------------------------------------------------
  def border_fill(color)
    fill_rect(0,0,width,1,color)
    fill_rect(0,0,1,height,color)
    fill_rect(width-1,0,1,height,color)
    fill_rect(0,height-1,width,1,color)
  end
  
end

#==============================================================================
# ** Point. To store x and y
#==============================================================================

class Point
  #--------------------------------------------------------------------------
  # * Public attributes
  #--------------------------------------------------------------------------
  attr_accessor :x
  attr_accessor :y
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(x,y)
    @x, @y = x, y
  end
  
end

#==============================================================================
# ** Game_Message
#==============================================================================

class Game_Message
  #--------------------------------------------------------------------------
  # * Escape char junk
  #--------------------------------------------------------------------------
  Junk_EscapeChar = [
  /\eNBL\['.*'\]/i,
  /\eNBR\['.*'\]/i,
  /\eNBL\[\d+\]/i,
  /\eNBR\[\d+\]/i,
  /\e\^/,
  /\e\./,
  /\e\|/,
  /\e\$/,
  /\e\>/,
  /\e\</,
  /\e\!/,
  ]
  
  #--------------------------------------------------------------------------
  # * Public attributes
  #--------------------------------------------------------------------------
  attr_accessor :balloon_refresh
  attr_accessor :subject
  attr_reader :type
  
  #--------------------------------------------------------------------------
  # * Alias : Initialize
  #--------------------------------------------------------------------------
  alias theo_msgballoon_init initialize
  def initialize
    theo_msgballoon_init
    @subject = 0
    normal
  end
  
  #--------------------------------------------------------------------------
  # * Switch to balloon
  #--------------------------------------------------------------------------
  def balloon
    @type = :balloon
    @balloon_refresh = true
  end
  
  #--------------------------------------------------------------------------
  # * Switch to normal
  #--------------------------------------------------------------------------
  def normal
    @type = :normal
    @balloon_refresh = true
  end
  
  #--------------------------------------------------------------------------
  # * Balloon mode is on?
  #--------------------------------------------------------------------------
  def balloon?
    return false unless SceneManager.scene_is?(Scene_Map)
    @type == :balloon && @subject > -1 && !get_char.nil?
  end
  
  #--------------------------------------------------------------------------
  # * Convert escape char for width calculation
  #--------------------------------------------------------------------------
  def convert_escape_characters(text)
    result = Theo.window.convert_escape_characters(text)
    result.gsub!(/\eC\[\d+\]/i) { "" }        # Destroy change color code
    result.gsub!(/\eI\[\d+\]/i) { "      " }  # Destroy draw icon
    result.gsub!(/<bm:\s*(\d+)>/i) do 
      @subject = $1.to_i 
      "" 
    end
    Junk_EscapeChar.each do |esc|  
      result.gsub!(esc) { "" }
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  # * Get longest text
  #--------------------------------------------------------------------------
  def longest_text
    test = Theo.window.contents
    test.font.size = Theo::Msg::FontSize
    txts = []
    @texts.each do |txt|
      txts.push(convert_escape_characters(txt))
    end
    longest = txts.sort do |a,b|
      test.text_size(b).width <=> test.text_size(a).width
    end[0]
    result = test.text_size(longest).width
    return [result, Theo::Msg::MinimumWidth].max
  end
  
  #--------------------------------------------------------------------------
  # * Get character
  #--------------------------------------------------------------------------
  def get_char
    if @subject == 0
      player = $game_player
      return Point.new(player.screen_x, player.screen_y)
    else
      event = $game_map.events[@subject]
      return nil unless event
      return Point.new(event.screen_x, event.screen_y)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Total text
  #--------------------------------------------------------------------------
  def total_text
    @texts.size
  end
  
end

#==============================================================================
# ** BalloonPointer
#==============================================================================

class BalloonPointer < Sprite
  #--------------------------------------------------------------------------
  # * Public Attributes
  #--------------------------------------------------------------------------
  attr_reader :window
  attr_reader :pos
  
  #--------------------------------------------------------------------------
  # * 
  #--------------------------------------------------------------------------
  def initialize(viewport,window)
    super(viewport)
    @window = window
    @pos = :upper
    self.bitmap = Cache.system("ballonpointer")
    to_center
    update
  end
  
  #--------------------------------------------------------------------------
  # * Position
  #--------------------------------------------------------------------------
  def pos=(pos)
    @pos = pos
    update_placement
  end
  
  #--------------------------------------------------------------------------
  # * To center
  #--------------------------------------------------------------------------
  def to_center
    self.ox = width/2
    self.oy = height
  end
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    if window.balloon?
      self.visible = window.open?
      update_placement
    else
      self.visible = false
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Placement
  #--------------------------------------------------------------------------
  def update_placement
    self.x = window.char.x
    if pos == :upper
      self.y = window.char.y - 32
      self.angle = 0
    else
      self.angle = 180
      self.y = window.char.y
    end
  end
    
end

#==============================================================================
# ** Sprite_OpenAnimation
#==============================================================================

class Sprite_OpenAnimation < Sprite
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(vport, msg_window)
    super(vport)
    @msg = msg_window
    w = 12*5
    h = 12
    self.bitmap = Bitmap.new(w,h)
    bitmap.border_fill(Theo::Msg::OpeningColor)
    self.ox = width/2
    self.oy = height/2
    update
  end
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    if Theo::Msg::UseOpening && @msg.balloon? 
      @ratio = @msg.openness / 255.0
      self.opacity = @msg.openness
      self.zoom_x = zoom_ratio_x
      self.zoom_y = zoom_ratio_y
      self.visible = false if @msg.open?
    else
      self.visible = false
    end
  end
  
  #--------------------------------------------------------------------------
  # * Zoom ratio X
  #--------------------------------------------------------------------------
  def zoom_ratio_x
    (@msg.width / width.to_f)* @ratio
  end
  
  #--------------------------------------------------------------------------
  # * Zoom ratio Y
  #--------------------------------------------------------------------------
  def zoom_ratio_y
    (@msg.height / height.to_f) * @ratio
  end
  
  #--------------------------------------------------------------------------
  # * Start pop
  #--------------------------------------------------------------------------
  def start_pop(char)
    Theo::Msg::OpeningSE.play if Theo::Msg::OpeningSE
    self.x = char.x
    self.y = char.y - 16
    targ_x = @msg.x + @msg.width/2
    targ_y = @msg.y + @msg.height/2
    dur = 255/Theo::Msg::OpeningSpeed
    goto(targ_x, targ_y, dur)
  end
  
end

#==============================================================================
# ** Window_Message
#==============================================================================

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # * Alias : Initialize
  #--------------------------------------------------------------------------
  alias theo_msgballoon_init initialize
  def initialize
    theo_msgballoon_init
    @animation = Sprite_OpenAnimation.new(viewport, self)
    @animation.visible = false
    @pointer = BalloonPointer.new(viewport,self)
  end
  
  #--------------------------------------------------------------------------
  # * Alias clear instance variables
  #--------------------------------------------------------------------------
  alias theo_msgballoon_clear_instances clear_instance_variables
  def clear_instance_variables
    theo_msgballoon_clear_instances
    @balloon = false
    @subject = -1
  end
  
  #--------------------------------------------------------------------------
  # * Alias : Setting changed
  #--------------------------------------------------------------------------
  alias theo_msgballoon_settings_changed? settings_changed?
  def settings_changed?
    theo_msgballoon_settings_changed? || balloon_setting_changed?
  end
  
  #--------------------------------------------------------------------------
  # * Ballon setting changed
  #--------------------------------------------------------------------------
  def balloon_setting_changed?
    @balloon != balloon? || @subject != $game_message.subject
  end
  
  #--------------------------------------------------------------------------
  # * Setup Window
  #--------------------------------------------------------------------------
  def setup_window
    balloon? ? setup_balloon : setup_normal
  end
  
  #--------------------------------------------------------------------------
  # * Setup normal
  #--------------------------------------------------------------------------
  def setup_normal
    h = fitting_height(visible_line_number)
    w = Graphics.width
    self.width = w
    self.height = h
    create_contents
  end
  
  #--------------------------------------------------------------------------
  # * Setup Balloon
  #--------------------------------------------------------------------------
  def setup_balloon
    h = fitting_height($game_message.total_text) + 2
    w = $game_message.longest_text + 10 + (standard_padding * 2)
    self.width = w
    self.height = h
    create_contents
    self.opacity = 255
  end
  
  #--------------------------------------------------------------------------
  # * Balloon mode?
  #--------------------------------------------------------------------------
  def balloon?
    $game_message.balloon?
  end
  
  #--------------------------------------------------------------------------
  # * Update background
  #--------------------------------------------------------------------------
  alias theo_msgballoon_update_bg update_background
  def update_background
    recreate_choice if @balloon != balloon?
    @balloon = balloon?
    @subject = $game_message.subject
    theo_msgballoon_update_bg
  end
  
  #--------------------------------------------------------------------------
  # * Update placement
  #--------------------------------------------------------------------------
  alias theo_msgballoon_normal_placement update_placement
  def update_placement
    setup_window
    theo_msgballoon_normal_placement
    if balloon?
      update_balloon_placement 
    else
      self.x = 0
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get character
  #--------------------------------------------------------------------------
  def char
    $game_message.get_char
  end
  
  #--------------------------------------------------------------------------
  # * Update balloon placement
  #--------------------------------------------------------------------------
  def update_balloon_placement
    xpos = [[char.x - width/2,0].max, Graphics.width - width].min
    ypos = char.y - height - Theo::Msg::Buffer_Y
    @pointer.pos = :upper
    if ypos < 0
      ypos = char.y + 11
      @pointer.pos = :lower
    end
    self.x = xpos
    self.y = ypos
  end
  
  #--------------------------------------------------------------------------
  # * Alias : New page
  #--------------------------------------------------------------------------
  alias theo_msgballoon_new_page new_page
  def new_page(text, pos)
    balloon? ? balloon_new_page(text, pos) : theo_msgballoon_new_page(text, pos)
  end
  
  #--------------------------------------------------------------------------
  # * Balloon new page
  #--------------------------------------------------------------------------
  def balloon_new_page(text, pos)
    setup_balloon
    update_balloon_placement
    contents.clear
    reset_font_settings
    pos[:x] = new_line_x
    pos[:y] = 0
    pos[:new_x] = new_line_x
    pos[:height] = calc_line_height(text)
    clear_flags
  end
  
  #--------------------------------------------------------------------------
  # * Alias : New line X
  #--------------------------------------------------------------------------
  alias theo_balloon_new_line_x new_line_x
  def new_line_x
    balloon? ? 4 : theo_balloon_new_line_x
  end
  
  #--------------------------------------------------------------------------
  # * Alias : Update
  #--------------------------------------------------------------------------
  alias theo_msgballoon_update update
  def update
    theo_msgballoon_update
    @pointer.update
    @animation.update
    if balloon? 
      self.visible = open? if Theo::Msg::UseOpening 
      update_balloon_placement if !@opening && !@closing
    else
      self.visible = true
    end
    recreate_choice if $game_message.balloon_refresh
  end
  
  #--------------------------------------------------------------------------
  # * Recreate choice
  #--------------------------------------------------------------------------
  def recreate_choice
    @choice_window.dispose
    @choice_window = Window_ChoiceList.new(self)
    $game_message.balloon_refresh = false
  end
  
  #--------------------------------------------------------------------------
  # * Alias : Line height
  #--------------------------------------------------------------------------
  alias theo_msgballoon_line_height line_height
  def line_height
    balloon? ? Theo::Msg::FontSize : theo_msgballoon_line_height
  end
  
  #--------------------------------------------------------------------------
  # * Reset font settings
  #--------------------------------------------------------------------------
  alias theo_msgballoon_reset_font reset_font_settings
  def reset_font_settings
    theo_msgballoon_reset_font
    contents.font.size = Theo::Msg::FontSize if balloon?
  end
  
  #--------------------------------------------------------------------------
  # * Overwrite : Input pause
  #--------------------------------------------------------------------------
  def input_pause
    self.pause = true unless balloon?
    wait(10)
    Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C)
    Input.update
    self.pause = false unless balloon?
  end
  
  #--------------------------------------------------------------------------
  # * Alias : Open and wait
  #--------------------------------------------------------------------------
  alias theo_msgballoon_open_wait open_and_wait
  def open_and_wait
    if balloon? && Theo::Msg::UseOpening
      @animation.visible = true 
      @animation.start_pop(char)
    end
    theo_msgballoon_open_wait
  end
  
  #--------------------------------------------------------------------------
  # * Alias : Close and wait
  #--------------------------------------------------------------------------
  alias theo_msgballoon_close_wait close_and_wait
  def close_and_wait
    Theo::Msg::ClosingSE.play if Theo::Msg::UseOpening && Theo::Msg::ClosingSE
    @animation.visible = false
    theo_msgballoon_close_wait
  end
  
  #--------------------------------------------------------------------------
  # * Overwrite : Update Open Processing
  #--------------------------------------------------------------------------
  def update_open
    speed = balloon? ? Theo::Msg::OpeningSpeed : 48
    self.openness += speed
    @opening = false if open?
  end
  
  #--------------------------------------------------------------------------
  # * Overwrite : Update Close Processing
  #--------------------------------------------------------------------------
  def update_close
    speed = balloon? ? Theo::Msg::OpeningSpeed : 48
    self.openness -= speed
    @closing = false if close?
  end
  
  #--------------------------------------------------------------------------
  # * Alias : Convert escape character
  #--------------------------------------------------------------------------
  alias theo_msgballoon_convert_char convert_escape_characters
  def convert_escape_characters(text)
    result = theo_msgballoon_convert_char(text)
    result = result.gsub(/<bm:\s*(\d+)>/i) { "" }
    result
  end
  
  #---------------------------------------------------------------------------
  # * Alias : Dispose
  #---------------------------------------------------------------------------
  alias theo_msgballoon_dispose dispose
  def dispose
    theo_msgballoon_dispose
    @animation.dispose
    @pointer.dispose
  end
  
end

#==============================================================================
# ** Window_ChoiceList
#==============================================================================

class Window_ChoiceList < Window_Command
  #--------------------------------------------------------------------------
  # * Reset font settings
  #--------------------------------------------------------------------------
  alias theo_msgballoon_reset_font reset_font_settings
  def reset_font_settings
    theo_msgballoon_reset_font
    contents.font.size = Theo::Msg::FontSize if @message_window.balloon?
  end
  
  #--------------------------------------------------------------------------
  # * Alias : Update placement
  #--------------------------------------------------------------------------
  alias theo_msgballoon_update_placement update_placement
  def update_placement
    theo_msgballoon_update_placement
    if @message_window.balloon?
      update_balloon_placement
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update balloon placement
  #--------------------------------------------------------------------------
  def update_balloon_placement
    msg = @message_window
    self.y = msg.y
    self.x = msg.x + msg.width 
    if (x + width) > Graphics.width
      self.x = msg.x - width 
    end
    if x < 0
      self.x = msg.x + msg.width - self.width
      self.y = msg.y + msg.height
    end
    if (y + height) > Graphics.height
      self.y = msg.y - self.height
    end
  end
  
  #--------------------------------------------------------------------------
  # * Alias : Line height
  #--------------------------------------------------------------------------
  alias theo_msgballoon_line_height line_height
  def line_height
    @message_window.balloon? ? Theo::Msg::FontSize : theo_msgballoon_line_height
  end
  
end
