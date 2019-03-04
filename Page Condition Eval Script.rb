# =============================================================================
# TheoAllen - Page Condition Eval Script
# Version : 1.0
# Contact : Discord @ Theo#3034
# =============================================================================
($imported ||= {})[:Theo_PageConditionScript] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2013.08.11 - Finished script
# =============================================================================
=begin

  Introduction :
  By default, there's no such a thing called event page condition eval script
  like in conditional branch. This script allow you to add page condition
  depends on script eval
  
  How to use :
  Put this script below material but above main
  Use this following tags in event comments
  
  <eval cond>
  script
  </eval cond>
  
  If you use many lines, it will be considered as one line
  
  Terms of use :
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.

=end
# =============================================================================
# No configuration
# =============================================================================
class Game_Event < Game_Character
  alias theo_eval_script_conditions_met? conditions_met?
  def conditions_met?(page)
    script = obtain_script_condition(page.list)
    unless script.empty?
      return eval(script)
    end
    return theo_eval_script_conditions_met?(page)
  end
  
  def obtain_script_condition(list)
    result = ""
    add_string = false
    list.each do |cmd|
      code = cmd.code
      next unless code == 108 || code == 408
      case cmd.parameters[0]
      when /<(?:EVAL_COND|eval cond)>/i
        add_string = true
      when /<\/(?:EVAL_COND|eval cond)>/i
        add_string = false
      else
        next unless add_string
        result += cmd.parameters[0]
      end
    end
    return result
  end
  
  def variables
    if $imported[:THEO_EventVariable]
      return $game_self_variables[$game_map.id,@id]
    end
  end
  
end
