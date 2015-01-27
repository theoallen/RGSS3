# =============================================================================
# TheoAllen - Anywhere Texts On Screen
# Version : 1.1
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (English Documentation)
# =============================================================================
($imported ||= {})[:Theo_AnywhereText] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2015.01.27 - Added font change
# 2013.08.26 - Finished script
# 2013.08.25 - Started script
# =============================================================================
=begin
  
  ----------------------------------------------------------------------------
  Introduction :
  This script allow you to have many texts written on screen.
  
  ----------------------------------------------------------------------------
  How to use :
  Simply put this script below material but above main
  Read the manual
  
  ----------------------------------------------------------------------------
  Script calls :
  Write this following line to script call to add text on your screen
  
  text(key,x,y,text,z,show,width,height,color1,color2)
  
  Paramaters that must be filled:
  - key  >> Is a hash key. You may fill it with numeric or string. It's used to
            delete your on screen text later
  - x    >> X coordinate from top-left
  - y    >> Y coordinate from top-left
  - text >> Is the text you want to display on screen. It's support escape
            characters such as \N[1] in show text message. But, you have to use
            double slash to activate. For example \\N[1]
  
  Parameters that can be ommited :
  - z      >> Z coordinate on screen. The larger number means the closer to 
              player text will be displayed. If it's ommited, the default value
              is 0.
  - show   >> show duration in frame. If you want to text stay on screen until
              you delete it manualy, use -1. The default value is -1
  - width  >> width of a rectangle that will be used to draw a box 
  - height >> height of a rectangle that will be used to draw a box
  - color1 >> Color of the rectangle. Must be filled by 
              Color.new(red,green,blue,alpha)
  - color2 >> Second Color of the rectangle. The default value is same as 
              color1
  
  To delete a certain text. Use this script call
  del_text(key)
  
  Key is a hash key. Same as above
  
  To clear entire screen, use
  clear_texts
  
  ##########################
  # Additional instruction #
  ##########################
  If you want to change the font, do this script call right before add the text
  
  $game_system.font_name = "Calibri"
  text(....)
  
  ----------------------------------------------------------------------------
  Terms of use :
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.

=end
# =============================================================================
# No configuration is avalaible
# Do not touch anything pass this line
# =============================================================================
class Game_Interpreter
  
  def text(key,x,y,text,z = 0,show = -1, width = 0, height = 0, 
      color1 = Color.new, color2=color1)
    return if $game_system.anytexts.include?(key)
    txt = TextDTStruct.new(key,x,y,z,width,height,text,show,color1,color2)
    $game_system.anytexts[key] = txt
    $game_temp.text_to_add = key
    Fiber.yield
  end
  
  def del_text(key)
    return unless $game_system.anytexts.include?(key)
    $game_temp.text_to_delete = key
    Fiber.yield
  end
  
  def clear_texts
    $game_system.anytexts.keys.each do |key|
      del_text(key)
    end
  end
  
end

class Game_Temp
  attr_accessor :text_to_delete
  attr_accessor :text_to_add
  
  alias theo_anytext_init initialize
  def initialize
    theo_anytext_init
    @text_to_delete = nil
    @text_to_add = nil
  end
  
end

class Game_System
  attr_writer :font_name
  attr_reader :anytexts
  
  alias theo_anytext_init initialize
  def initialize
    theo_anytext_init
    @anytexts = {}
  end
  
  def font_name
    @font_name ||= Font.default_name
  end
  
end

class TextDTStruct
  attr_accessor :key
  attr_accessor :x
  attr_accessor :y
  attr_accessor :z
  attr_accessor :width
  attr_accessor :height
  attr_accessor :text
  attr_accessor :show
  attr_accessor :color1
  attr_accessor :color2
  attr_accessor :font_name
  
  def initialize(key, x, y, z, width, height, text, show, color1, color2)
    @key = key
    @x = x
    @y = y
    @z = z
    @width = width
    @height = height
    @text = text
    @show = show
    @color1 = color1
    @color2 = color2
    @font_name = $game_system.font_name
  end
  
end

class Anywhere_Text < Window_Base
  attr_reader :key
  
  def initialize(key,viewport)
    pad = standard_padding
    super(-pad,-pad,Graphics.width+pad,Graphics.height+pad)
    self.viewport = viewport
    self.opacity = 0
    load_data(key)
    draw_contents
  end
  
  def load_data(key)
    @data = $game_system.anytexts[key]
    @key = @key
    @text = @data.text
    @xpos = @data.x
    @ypos = @data.y
    @w = @data.width
    @h = @data.height
    @color1 = @data.color1
    @color2 = @data.color2
    self.z = @data.z
    contents.font.name = @data.font_name
  end
  
  def draw_contents
    rect = Rect.new(@xpos,@ypos,@w,@h)
    contents.gradient_fill_rect(rect,@color1,@color2)
    draw_text_ex(@xpos,@ypos,@text)
  end
  
  def update
    super
    update_dispose
  end
  
  def update_dispose
    @data.show = [@data.show - 1,-1].max
    dispose if @data.show == 0
  end
  
end

class Text_Hash
  
  def initialize(viewport = nil)
    @viewport = viewport
    @data = {}
    init_used_text
  end
  
  def init_used_text
    $game_system.anytexts.keys.each do |key|
      add(key)
    end
  end
  
  def update
    update_disposed
    update_delete
    update_add
    update_text
  end
  
  def update_disposed
    @data.values.each do |text|
      next unless text.disposed?
      delete(text.key)
    end
  end
  
  def update_delete
    del_key = $game_temp.text_to_delete
    unless del_key.nil?
      delete(del_key)
      $game_temp.text_to_delete = nil
    end
  end
  
  def update_add
    add_key = $game_temp.text_to_add
    unless add_key.nil?
      add(add_key)
      $game_temp.text_to_add = nil
    end
  end
  
  def update_text
    @data.values.each {|text| text.update unless text.disposed?}
  end
  
  def delete(key)
    text = @data.delete(key)
    $game_system.anytexts.delete(key)
    return unless text
    text.dispose
  end
  
  def add(key)
    new_text = Anywhere_Text.new(key,@viewport)
    @data[key] = new_text
  end
  
  def dispose
    @data.values.each {|text| text.dispose}
  end
  
end

class Spriteset_Map
  
  alias theo_anytext_crv create_viewports
  def create_viewports
    theo_anytext_crv
    create_anytexts
  end
  
  def create_anytexts
    @anytexts = Text_Hash.new(@viewport2)
  end
  
  alias theo_anytext_update update
  def update
    theo_anytext_update
    update_anytexts
  end
  
  def update_anytexts
    @anytexts.update
  end
  
  alias theo_anytext_dispose dispose
  def dispose
    theo_anytext_dispose
    dispose_anytexts
  end
  
  def dispose_anytexts
    @anytexts.dispose
  end
  
end
