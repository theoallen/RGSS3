#==============================================================================
# 
# ¥ Yanfly Engine Ace - Ace Battle Engine v1.22 ( Turn Fix for FTB )
# -- Last Updated: 2012.03.04
# -- Level: Normal, Hard
# -- Requires: n/a
# 
# Edited by : TheoAllen 
# Make FTB do not change turn when you still have an action
#==============================================================================
# Do not edit below this line
#==============================================================================
class Scene_Battle
  
  # --------------------------------------------------------------------------
  # Overwrite : Next Command
  # --------------------------------------------------------------------------
  def next_command
    @status_window.show
    redraw_current_status
    @actor_command_window.show
    @status_aid_window.hide
    if BattleManager.next_command
      start_actor_command_selection
    else
      if check_prev_command
        BattleManager.prior_command
        start_actor_command_selection
      else
        turn_start
      end
    end
  end
  
  def check_prev_command
    Array.new($game_party.members) { |i| i }.any? do |member|
      !member.actions.any? {|act| act.valid? }
    end
  end
  
end
