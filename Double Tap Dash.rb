# =============================================================================
# TheoAllen - Double Tap Dash
# Version : 1.1
# Contact : Discord @ Theo#3034
# =============================================================================
($imported ||= {})[:Theo_DoubleTapDash] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2013.08.15 - Add option to keep shift as dash trigger
# 2013.08.13 - Finished script
# =============================================================================
=begin

  Introduction :
  This script will make dash activated by double tap instead of pressing shift.
  In case if you want to use shift button for another thing
  
  Cara penggunaan :
  Put the script below material but above main
  Edit the configuration if necessary
  
  Terms of use :
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.

=end
# =============================================================================
# Little Configuration :
# =============================================================================

  DashDelay_Duration = 15 
  # Set double tap maximal delay duration here (60 = one second)
  
  KeepShift = true
  # Set true if you still want to use shift as dash trigger
  
# =============================================================================
# End of config. Do not touch anything pass this line or the risk is yours
# =============================================================================
class Game_Player < Game_Character
  
  alias theo_double_tap_init initialize
  def initialize
    theo_double_tap_init
    init_tap_dash_member
  end
  
  def init_tap_dash_member
    @pending_dash = 0
    @pending_dash2 = 0
    @dash_delay = 0
  end
  
  alias theo_double_tap_update update
  def update
    theo_double_tap_update
    update_tap_dash
  end
  
  def update_tap_dash
    if !dash?
      @dash_delay = [@dash_delay - 1,0].max 
    end
    if (Input.dir4 == 0 && tap_dash?) || @dash_delay == 0
      init_tap_dash_member
    end
    if input_arrow? && !dash_impossible? && !dash?
      if @pending_dash == Input.dir4
        @pending_dash2 = Input.dir4
      else
        @pending_dash = Input.dir4
        @dash_delay = DashDelay_Duration
      end
    end
  end
  
  def dash_impossible?
    return @move_route_forcing || $game_map.disable_dash? || vehicle
  end
  
  def input_arrow?
    [:UP,:DOWN,:LEFT,:RIGHT].any? {|key| Input.trigger?(key)}
  end
  
  def dash?
    return false if @move_route_forcing
    return false if $game_map.disable_dash?
    return false if vehicle
    return true if KeepShift ? Input.press?(:A) : false
    return Input.dir4 != 0 && tap_dash?
  end
  
  def tap_dash?
    (@pending_dash2 == @pending_dash) && @pending_dash2 != 0
  end
  
end
