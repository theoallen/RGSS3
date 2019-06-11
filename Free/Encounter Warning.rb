#==============================================================================
# TheoAllen - Encounter Warning
# Version : 1.0b
#==============================================================================
($imported ||= {})[:Theo_EncWarning] = true
#==============================================================================
# Change Logs:
#------------------------------------------------------------------------------
# 2019.06.12 - Fixed the script call to disable
# 2019.06.09 - Finished
#==============================================================================
=begin

  -----------------------------------------------------------------------------
  > Intro :
  -----------------------------------------------------------------------------
  One of my biggest pet peeve on random encounter is that it doesn't have a
  warning on when I actually get an encounter. Most of the time when I entered
  a battle, it bummed me out. This simple script is simply adding a warning
  when the you're nearing the encounter
  
  -----------------------------------------------------------------------------
  > How to use :
  -----------------------------------------------------------------------------
  Put the script under material
  To show/hide the warning icon, use script call
  
  $game_system.warning = true
  OR
  $game_system.warning = false
  
  -----------------------------------------------------------------------------
  > Terms of use :
  -----------------------------------------------------------------------------
  It's free. If you edit it and redistribute it (e.g, port it to MV), please 
  keep it free.

=end
#==============================================================================
# Configurations
#==============================================================================
module Theo
  module Enc
    XPos = Graphics.width - 32  # X position of the warning icon
    YPos = 8                    # Y position of the warning icon
    MaxOpacity    = 180         # Maximum opacity of the icon
    OpacitySpeed  = 10          # Opacity change per frame. Larger = faster
    
    IconSafe    = 189 # Safe icon index indicator
    IconUnsafe  = 190 # Entering unsafe icon index indicator
    IconDanger  = 187 # Danger state icon index indicator
    
    MidStep     = 30 # Step remains when entering unsafe state
    DangerStep  = 10 # Step remains when entering danger state
    Exclamation = 2  # Step remains when the player sprite display an 
                     # exclamation balloon. Set nil to disable
    
    # Exclamation balloon icon sound
    ExclamationSound = RPG::SE.new('Jump1',60,135)
    
    # Show warning icon at the start of the game?
    ShowAtStart = true
  end
end
#==============================================================================
# End of safe line
#==============================================================================
class Game_System
  def warning
    @warning = Theo::Enc::ShowAtStart if @warning.nil?
    @warning
  end
  attr_writer :warning
end

class Warning_Sprite < Sprite
  include Theo::Enc

  def initialize
    super
    @last_count = $game_player.encounter_count
    make_bitmaps
    update
    update_pos
    update_bitmap
    self.opacity = 0
  end
  
  def make_bitmaps
    icon = Cache.system("iconset")
    @bitmaps = []
    [IconSafe,IconUnsafe,IconDanger].each do |index|
      rect = Rect.new(index % 16 * 24, index / 16 * 24, 24, 24)
      bmp = Bitmap.new(32,32)
      bmp.blt(0,0,icon,rect)
      @bitmaps.push(bmp)
    end
  end
  
  def update
    super
    if @last_count != $game_player.encounter_count
      @last_count = $game_player.encounter_count
      update_bitmap
    end
    if $game_system.warning
      self.opacity = [MaxOpacity,opacity+OpacitySpeed].min 
    else
      self.opacity = [0,opacity-OpacitySpeed].max
    end
  end
  
  def update_bitmap
    level = $game_player.warning_level
    self.bitmap = @bitmaps[level]
  end
  
  def update_pos
    self.x = XPos
    self.y = YPos
  end
  
end

class Game_Player
  attr_reader :encounter_count
  def warning_level
    make_encounter_count unless @encounter_count
    return 2 if @encounter_count <= Theo::Enc::DangerStep
    return 1 if @encounter_count <= Theo::Enc::MidStep
    return 0
  end
  
  alias aed2_update_encounter update_encounter
  def update_encounter
    aed2_update_encounter
    if Theo::Enc::Exclamation && @encounter_count == Theo::Enc::Exclamation &&
      $game_system.warning
      Theo::Enc::ExclamationSound.play
      self.balloon_id = 1
    end
  end
end

class Scene_Map
  alias aed2_warning_start start
  def start
    aed2_warning_start
    @warn = Warning_Sprite.new
    @warn.z = 100
  end
  
  alias aed2_warning_update update
  def update
    aed2_warning_update
    @warn.update
  end
  
  alias aed2_warning_terminate terminate
  def terminate
    aed2_warning_terminate
    @warn.dispose
  end
end
