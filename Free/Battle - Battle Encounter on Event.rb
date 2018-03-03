#===============================================================================
# TheoAllen - Battle Encounter on Event
# Version: 1.0
# Contact: Discord @ Theo#3034
#===============================================================================
($imported ||= {})[:Theo_BattleEvent] = true
#===============================================================================
# Change Logs:
# ------------------------------------------------------------------------------
# 2014.12.09 - Finished
#===============================================================================
=begin

  --------------------------------------
  *) Introduction :
  --------------------------------------
  This script simply enable you to use random encounter features like surprise 
  and preemptive in battle processing through battle processing event. You can 
  make your evented encounter same as random encounter, force surprise attack, 
  or force preemptive attack.
  
  --------------------------------------
  *) How to use :
  --------------------------------------
  Put this script below material but above main
  
  Select these script call and put right before the battle processing
  > Battle.surprise
  > Battle.preemptive
  > Battle.same_as_encount

  It only works just for one evented battle process call. Put the script call
  once again if you want to use.
  
  ------------------------------------------
  *) Terms of use : 
  ------------------------------------------
  > Free to edit / Repost of edit
  > Free for commercial / non-commercial / contest with prize
  > Credit is not required, but don't claim it's yours

=end
#===============================================================================
# End of instructions. Do not touch anything below
#===============================================================================

#===============================================================================
# ** Battle (For script call)
#===============================================================================
module Battle
class << self
  
  def surprise
    $game_temp.battle_surprise = true
  end
  
  def preemptive
    $game_temp.battle_preemptive = true
  end
  
  def same_as_encount
    $game_temp.battle_same_encounter = true
  end    
    
end
end
#===============================================================================
# ** Game_Temp
#===============================================================================
class Game_Temp
  attr_accessor :battle_surprise
  attr_accessor :battle_preemptive
  attr_accessor :battle_same_encounter
  
  def battle_event_reset
    @battle_surprise = false
    @battle_preemptive = false
    @battle_same_encounter = false
  end
  
end
#===============================================================================
# ** BattleManager
#===============================================================================
class << BattleManager
  
  alias theo_battle_event_start battle_start
  def battle_start
    if @event_proc
      @preemptive = $game_temp.battle_preemptive
      @surprise = $game_temp.battle_surprise && !$game_temp.battle_preemptive
      on_encounter if $game_temp.battle_same_encounter
      $game_temp.battle_event_reset
    end
    theo_battle_event_start
  end
  
end
