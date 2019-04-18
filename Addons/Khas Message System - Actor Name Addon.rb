#===============================================================================
# Khas Message System addon - Actor name
# Butchered by, TheoAllen
#
# Requires original script: 
# http://arcthunder.blogspot.com/p/khas-message-system.html
#-------------------------------------------------------------------------------
# If you want to use actor name in the database
# 
# Usage:
# In the Khas's name database, use "{actor_id}"
# For example "{1}" => ["setting1", "setting2"]
# I assume you already familiar with their setting
#
# Terms of Use?
# Nah, just follow Khas' ToU
# Crediting me is trivial
#===============================================================================
class Sprite_Message
  def scan_special_commands(text)
    if text =~ /\ep/i
      @character = $game_player
    end
    if text =~ /\ef/i
      @float = true
    end
    if text =~ /\ea\[(.+)\]/i # <-- edited
      @actor = $1 if Actors[$1]
    end
    if text =~ /\ee\[(\d+)\]/i
      @character = $game_map.events[$1.to_i] if $game_map.events[$1.to_i]
    end
  end
  def draw_namebox(y)
    rect = text_size(@actual_name) # <-- edited
    color = Colors[Actors[@actor][0]]
    color.alpha = Background.alpha
    self.bitmap.fill_rect(4,y,rect.width+10,rect.height+2,Outline)
    self.bitmap.fill_rect(5,y+1,rect.width+8,rect.height,color)
    self.bitmap.draw_text(9,y+1,rect.width,rect.height,
      @actual_name) # <-- edited
  end
  
  def process_escape_character(code, text, pos)
    case code.upcase
    when '$'
      @gold_window.open
    when '.'
      wait(15)
    when '|'
      wait(60)
    when '!'
      input_pause
    when '>'
      @show_fast = true
    when '<'
      @show_fast = false
    when '^'
      @pause_skip = true
    when 'C'
      change_color(text.slice!(/^\[#?\w+\]/)[/#?\w+/])
    when 'I'
      process_draw_icon(text.slice!(/^\[\d+\]/)[/\d+/].to_i, pos)
    when '{'
      make_font_bigger
    when '}'
      make_font_smaller
    when 'A'
      text.slice!(/^\[.+\]/) # <-- Edited
    when 'S'
      shake(text.slice!(/^\[\d+\]/)[/\d+/].to_i)
    when 'E'
      text.slice!(/^\[\d+\]/)
    when 'T'
      @voice = text.slice!(/^\[\w*\]/)[/\w*/]
      @voice = nil unless @voice.size > 0
    when 'X'
      Audio.se_play("Audio/se/#{text.slice!(/^\[\w+\]/)[/\w+/]}", SE_Volume)
    end
  end
  
  alias theoxkhas_remove_esc remove_escape_characters
  def remove_escape_characters(text)
    result = theoxkhas_remove_esc(text)
    result.gsub!(/\ea\[.+\]/i,"") # <-- Added
    result
  end
  
  def draw_balloon
    # Reset stuff for new balloon
    reset_font_settings
    reset_character_actor
    
    # Process text
    text = convert_escape_characters($game_message.all_text)
    scan_special_commands(text)
    text = remove_escape_characters(text)
    
    # Should the balloon float?
    @float = true if @character.nil?
    
    # Check if the balloon will have a namebox
    @actual_name = actor_name_replace(@actor) # <-- Added
    @namebox_yplus = (@actor ? text_size(@actual_name).height : 0) # <-- Edited
    @voice = (@actor ? Actors[@actor][1] : nil)
    
    # Check if the balloon will have a detail
    @detail_yplus = (@float ? 0 : 10)
    
    # Calculate text dimensions
    tw = fitting_width(text)
    th = fitting_height(text) + @namebox_yplus + @detail_yplus
    
    # Check if the balloon needs to be inverted
    if invert_balloon?(th)
      @inverted = true
      @margin_top = @detail_yplus
      @margin_bottom = @namebox_yplus
    else
      @inverted = false
      @margin_top = @namebox_yplus
      @margin_bottom = @detail_yplus
    end
    
    # Calculate balloon dimensions
    balloon = Rect.new
    balloon.x = 0
    balloon.y = @margin_top
    balloon.width = tw > Minimum_Width ? tw : Minimum_Width
    balloon.height = th - @margin_top - @margin_bottom
    
    # Create a new bitmap
    self.bitmap.dispose if self.bitmap
    self.bitmap = Bitmap.new(balloon.width, th)
    reset_font_settings
    
    # Draw the balloon
    self.bitmap.fill_rect(balloon.x, balloon.y, balloon.width, balloon.height, 
      Outline)
    self.bitmap.fill_rect(balloon.x+1, balloon.y+1, balloon.width-2, 
      balloon.height-2, Background)
    
    # Draw the namebox
    draw_namebox(@inverted ? (th - @namebox_yplus - 2) : 0) if @actor
  end
  
  # New method (Change the regex here if u dont like it
  def actor_name_replace(string)
    string.gsub(/\{(\d+)\}/) {actor_name($1.to_i)}
  end
end
