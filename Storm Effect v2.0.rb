# ============================================================================
# TheoAllen - STORM EFFECTS ~
# Version : 2.0
# ============================================================================
$imported = {} if $imported.nil?
$imported[:Theo_Storm] = true
module THEO
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2018.02.19 - Reworked + Translated
# 2013.05.02 - Nambahin dokumentasi lebih detil
#            - Nambahin konfigurasi SE
# 2013.04.14 - Started and Finished script
# =============================================================================
=begin
  
  Intro :
  This script adds storm effect and to save your time from tedious eventing lul.
  It mainly adds flash effect and a thunder SE

  How to use :
  Use these script call:
  - THEO.thunder_on     
  - THEO.thunder_off    
  - THEO.flash_on       
  - THEO.flash_off      
  
  To change the effect rate (explained below in config part):
  - THEO.thunder_chance(min, max) 
  - THEO.flash_chance(min, max)
  
  TERMS OF USE :
  Credit me, TheoAllen. Feel free to use and edit as much as you want. Just dont
  claim it's yours. Gimme free copy for commercial use
  
=end
#==============================================================================  
# Konfigurasi :
#==============================================================================

  #---------------------------------------------------------------------------
  # This is where you set the rate
  #---------------------------------------------------------------------------
  # Min is how many frame passed needed so that a flash/thunder is played?
  # Max is the range from the minimum frame passed (randomized)
  #
  # In short, if you put 120 as min and 180 as max. The effect will be
  # randomized between each 2 ~ 3 seconds
  #---------------------------------------------------------------------------
  Thunder_Rate  = [110, 180]  # [Min frame, max frame]
  Flash_Rate    = [110, 180]  # [Min frame, max frame] 
  SoundFX       = RPG::SE.new('Thunder9')
  
  # Maximum flash opacity
  Max_Flash_Str = 200

#==============================================================================
# End of config
#============================================================================== 
  def self.thunder_chance(chance,dice)
    $game_system.thunder_chance = [chance,dice].dup
  end
  
  def self.flash_chance(chance,dice)
    $game_system.flash_chance = [chance,dice].dup
  end
  
  def self.thunder_on
    $game_system.turn_on_thunder
  end
  
  def self.thunder_off
    $game_system.thunder_switch = false
  end
  
  def self.flash_on
    $game_system.turn_on_flash
  end
  
  def self.flash_off
    $game_system.flash_switch = false
  end
  
end

class Game_System
  attr_accessor :flash_chance
  attr_accessor :flash_switch
  attr_accessor :thunder_chance
  attr_accessor :thunder_switch
  
  alias theo_storm_init initialize
  def initialize
    theo_storm_init
    @flash_chance = THEO::Thunder_Rate.dup
    @flash_switch = false
    @thunder_chance = THEO::Flash_Rate.dup
    @thunder_switch = false
    @thunder_count = 0
    @flash_count = 0
    @next_thunder = 0
    @next_flash = 0
  end
  
  def turn_on_thunder
    @thunder_switch = true
    @thunder_count = 0
    randomize_next_thunder
  end
  
  def turn_on_flash
    @flash_switch = true
    @flash_count = 0
    randomize_next_flash
  end
  
  def update_effect
    if @thunder_switch
      @thunder_count += 1
      if @thunder_count >= @next_thunder
        @thunder_count = 0
        se = THEO::SoundFX
        se.volume = rand(60)
        se.play
        randomize_next_thunder
      end
    end
    if @flash_switch
      @flash_count += 1
      if @flash_count >= @next_flash
        @flash_count = 0
        color = Color.new(255,255,255,(rand*THEO::Max_Flash_Str).round)
        screen.start_flash(color,(rand*30).round)
        randomize_next_flash
      end
    end
  end
  
  def randomize_next_thunder
    min = @thunder_chance[0]
    range = @thunder_chance[1] - min
    @next_thunder = rand(range) + min
  end
  
  def randomize_next_flash
    min = @flash_chance[0]
    range = @flash_chance[1] - min
    @next_flash = rand(range) + min
  end
  
  def screen
    $game_map.screen
  end
  
end

class Scene_Map < Scene_Base

  alias vg_update update
  def update
    vg_update
    $game_system.update_effect
  end
  
end
