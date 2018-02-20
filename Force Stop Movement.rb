# =============================================================================
# TheoAllen - Force Stop Movement
# Version : 1.0
# =============================================================================
($imported ||= {})[:Theo_StopMovement] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2018.02.20 - Translated to eng
# 2013.06.27 - Finished script
# =============================================================================
=begin

  Introduction:
  This script forces all movement to stop. Either it's evented movement or
  autonomous. Can be used to stop tileset animation as well
  
  How to use:
  Put below material & above main
  Flip the switch to ON/OFF to control. Determine the switch ID as you desire
  on the config part
  
  Terms of use :
  Crediting me (as TheoAllen) is appreciated. 
  Free for commercial

=end
#==============================================================================
# Configs :
#==============================================================================
module THEO
  module MOVEMENT
    
    # =========================================================================
      TILEMAP_SWITCH = 22 # Switch ID for tilemap
      PLAYER_SWITCH  = 24 # Switch ID for player
      EVENT_SWITCH   = 23 # Switch ID for event
    # -------------------------------------------------------------------------
    # If the switch is flipped to ON, it will stop the movement
    # =========================================================================
    
  end
end
#==============================================================================
# End of safe line
#==============================================================================
class Game_Event < Game_Character
  
  alias pre_stop_update_anim update_animation
  def update_animation
    return if $game_switches[THEO::MOVEMENT::EVENT_SWITCH]
    pre_stop_update_anim
  end
  
  alias ori_distance_per_frame distance_per_frame
  def distance_per_frame
    return 0 if $game_switches[THEO::MOVEMENT::EVENT_SWITCH]
    return ori_distance_per_frame
  end
  
end

class Game_Player < Game_Character
  
  alias pre_stop_move_input move_by_input
  def move_by_input
    return if $game_switches[THEO::MOVEMENT::PLAYER_SWITCH]
    pre_stop_move_input
  end
  
end

class Tilemap
  
  alias pre_update_stop update
  def update
    pre_update_stop unless $game_switches[THEO::MOVEMENT::TILEMAP_SWITCH]
  end
  
end
