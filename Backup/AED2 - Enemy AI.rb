#==============================================================================
# TheoAllen - Enhanced Enemy AI+ (Modified)
# Version : 1.0++
# This version was never been released in public.
#==============================================================================
($imported ||= {})[:Theo_EnemyAI] = true
#==============================================================================
# Change Logs:
#------------------------------------------------------------------------------
# 2014.01.15 - Finished script
#==============================================================================
=begin

  Notetag :
  <ai[skill_index]: script eval>
  <ai[0]: $game_switches[1] && self.hp == 1>
  
  <ai(skill_id, rating): script eval>
  <ai(1,5): $game_switches[1] && self.hp == 1>

=end
#==============================================================================
# *
#==============================================================================
module Theo
  module AI
    List = { # < --- Obsolete
    
    
"Obv" => [83,10,"!$game_party.any_state?(34) && conditions_met_turns?(1,3) &&
!state?(58)"],
"Obv2" => [83,10,"!$game_party.any_state?(34) && state?(58)"],
"Mark" => [84,10,"!$game_party.any_state?(31) && state?(58)"],

    }
    
    
    Notetag = /ai\s*:\s*(.+)/i
  # Old Tag
    
    NoteEX = /ai\s*\[(\d+)\]\s*:\s*(.+)/i
  # Notetag Extended (hardcoded)
  # <ai[index]: keyword>
  
    NoteEval = /<ai\[(\d+)\]\s*:\s*(.+)>/i
  # Notetag Eval script
  # <ai[index]: script eval>
  
    NoteGen = /<ai\((\d+),(\d+)\)\s*:\s*(.*)>/i
  # Notetag generate
  # <ai(skill,rating): script eval>
    
  end
end
#==============================================================================
# New code
#==============================================================================
class Game_Enemy
  
  def hardcoded
    keylist = {
      "Test" => lambda { true }
    }
    return keylist
  end
  
  def con_hardcoded?(param1, param2)
    code = hardcoded[param1]
    if code
      return code.call
    else
      return false
    end
  end
  
  def con_evalcoded?(param1, param2)
    p eval(param1)
    return eval(param1)
  end
  
  alias turns? conditions_met_turns?
  
end
#==============================================================================
# Old code
#==============================================================================
class RPG::Enemy
  
  def load_custom_ai
    note.split(/[\r\n]+/).each do |line|
      if line =~ Theo::AI::Notetag
        db = Theo::AI::List[$1.to_s]
        if db
          act = RPG::Enemy::Action.new
          act.condition_type = 7
          act.skill_id = db[0]
          act.rating = db[1]
          act.condition_param1 = db[2]
          actions.push(act)
        else
          msgbox "Uninitialize AI constant #{$1.to_s} for \n" +
            "Enemy #{name}"
          exit
        end
      #----------------------------
      # New Code
      #----------------------------
      elsif line =~ Theo::AI::NoteEval
        act = actions[$1.to_i]
        act.condition_type = 9
        act.condition_param1 = $2.to_s
      elsif line =~ Theo::AI::NoteEX
        act = actions[$1.to_i]
        act.condition_type = 8
        act.condition_param1 = $2.to_s
      elsif line =~ Theo::AI::NoteGen
        act = RPG::Enemy::Action.new
        act.condition_type = 7
        act.skill_id = $1.to_i
        act.rating = $2.to_i
        act.condition_param1 = $3.to_s
        actions.push(act)
      end
    end
  end  
  
end

class << DataManager
  
  alias theo_enemy_ai_load_db load_database
  def load_database
    theo_enemy_ai_load_db
    load_custom_ai
  end
  
  def load_custom_ai
    $data_enemies.compact.each do |enemy|
      enemy.load_custom_ai
    end
  end
  
end

class Game_Action
  
  alias theo_custom_ai_prepare prepare
  def prepare
    theo_custom_ai_prepare
    # ------------------------------------------------------------------------
    # Refresh enemy action. Make sure current action is conditionally valid.
    # Two times or more action often performed an action whether the current
    # action is conditionally valid or not
    # ------------------------------------------------------------------------
    if subject.enemy? && !forcing
      skill = subject.enemy_action
      set_enemy_action(skill)
      # mainly aimed for script eval condition
      subject.performed_item.push(item.id) if item
    end
  end
  
end

class Game_Enemy
  attr_reader :performed_item
  
  alias theo_custom_ai_init initialize
  def initialize(*args)
    theo_custom_ai_init(*args)
    @performed_item = []
  end
  # --------------------------------------------------------------------------
  # Overwrite conditions met
  # --------------------------------------------------------------------------
  def conditions_met?(action)
    method_table = {
      1 => :conditions_met_turns?,
      2 => :conditions_met_hp?,
      3 => :conditions_met_mp?,
      4 => :conditions_met_state?,
      5 => :conditions_met_party_level?,
      6 => :conditions_met_switch?,
      7 => :conditions_met_script?,
      # New Code
      8 => :con_hardcoded?,
      9 => :con_evalcoded?,
    }
    method_name = method_table[action.condition_type]
    if method_name
      send(method_name, action.condition_param1, action.condition_param2)
    else
      true
    end
  end
  
  def conditions_met_script?(param1, param2)
    eval(param1)
  end
  
  def enemy_action
    action_list = enemy.actions.select {|a| action_valid?(a) }
    return if action_list.empty?
    rating_max = action_list.collect {|a| a.rating }.max
    rating_zero = rating_max - 3
    action_list.reject! {|a| a.rating <= rating_zero }
    return select_enemy_action(action_list, rating_zero)
  end
  
end

class Game_Battler
  alias theo_custom_ai_turn_end on_turn_end
  def on_turn_end
    theo_custom_ai_turn_end
    @performed_item.clear if enemy?
  end
end

class Game_Party
  
  def any_state?(id)
    members.any? {|m| m.state?(id)}
  end
  
end
