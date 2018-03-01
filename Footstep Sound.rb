# =============================================================================
# TheoAllen - Footstep Sound
# Version : 1.2
# =============================================================================
($imported ||= {})[:Theo_FootSound] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2018.03.02 - Change how the sound is handled (2)
# 2014.02.01 - Change how the sound is handled
# 2013.11.16 - Finished script
# =============================================================================
=begin

  Intro :
  Because walking with no sound is soooo boring ....
  
  How to use :
  Put the script below material and above main.
  
  > If you want an event to use footstep sound as well, put <footstep> tag by
    using comment.
  > If you want to change the footstep sound, use script call
    footstep[id] = RPG::SE.new("name", vol, pitch)
  
  Further instruction on setting.

  Terms of use :
  Credit me, TheoAllen. Feel free to use and edit as much as you want. Just dont
  claim it's yours. Gimme free copy for commercial use.
  
=end
#==============================================================================
# Configs :
#==============================================================================
module Theo
  module FSound
  #---------------------------------------------------------------------------
    RegionMode = true
  #---------------------------------------------------------------------------
  # Want to use region? If no (false) then it will use terrain tag
  #---------------------------------------------------------------------------
  
  # --------------------------------------------------------------------------
    List = {  # <-- No, dont touch this
  # --------------------------------------------------------------------------
  # Define the sound effect here with this following format
  #
  # ID => RPG::SE.new("Name",vol,pitch),
  #
  # - ID      >> ID for the region / terrain tag
  # - "Name"  >> SE name from Audio/SE
  # - vol     >> Volume SE (0 - 100)
  # - pitch   >> Pitch (50 - 150)
  # --------------------------------------------------------------------------
  
      1 => RPG::SE.new("Knock",80,150),
      
    # Add more here
    # Don't forget comma!
      
  # --------------------------------------------------------------------------
    } # <-- No, dont touch this
  # --------------------------------------------------------------------------
  
  # --------------------------------------------------------------------------
    SoundDelay = [10,6] # [normal, dash]
  # --------------------------------------------------------------------------
  # A frame delay before playing next footstep sound
  # One for walking, later one for dashing
  # --------------------------------------------------------------------------
  
  end
end
#==============================================================================
# End of config
#==============================================================================
class Game_Interpreter
  
  def footstep
    $game_system.fsound
  end
  
end

class Game_System
  attr_reader :fsound
  
  alias theo_fsound_init initialize
  def initialize
    theo_fsound_init
    @fsound = Theo::FSound::List
  end
  
end

class Game_Event
  
  alias theo_fsound_init initialize
  def initialize(map_id, event)
    theo_fsound_init(map_id, event)
    @sound_delay = 0
  end

  def fsound_tile_data_id
    Theo::FSound::RegionMode ? region_id : terrain_tag
  end
  
  def footstep_sound
    $game_system.fsound[fsound_tile_data_id]
  end
  
  alias theo_fsound_update update
  def update
    theo_fsound_update
    update_footstep_sound if play_footstep?
  end
  
  def update_footstep_sound
    @sound_delay -= 1
    if @sound_delay <= 0 && moving?
      sound = footstep_sound
      sound.play if sound
      if dash?
        @sound_delay = Theo::FSound::SoundDelay[1]
      else
        @sound_delay = Theo::FSound::SoundDelay[0]
      end
    end
  end
  
  alias theo_fsound_page_setting setup_page_settings
  def setup_page_settings
    theo_fsound_page_setting
    setup_fsound
    @sound_delay = 0
  end  
  
  def setup_fsound
    @play_footstep = false
    @list.each do |command|
      next unless command.code == 108 || command.code == 408
      if command.parameters[0][/<footstep>/i]
        @play_footstep = true
      end
    end
  end
  
  def play_footstep?
    @play_footstep
  end
  
end

class Game_Player
  
  alias theo_fsound_init initialize
  def initialize
    theo_fsound_init
    @sound_delay = 0
  end

  def fsound_tile_data_id
    Theo::FSound::RegionMode ? region_id : terrain_tag
  end
  
  def footstep_sound
    $game_system.fsound[fsound_tile_data_id]
  end
  
  alias theo_fsound_update update
  def update
    theo_fsound_update
    update_footstep_sound
  end
  
  def update_footstep_sound
    @sound_delay -= 1
    if @sound_delay <= 0 && moving?
      sound = footstep_sound
      sound.play if sound
      if dash?
        @sound_delay = Theo::FSound::SoundDelay[1]
      else
        @sound_delay = Theo::FSound::SoundDelay[0]
      end
    end
  end
  
end
