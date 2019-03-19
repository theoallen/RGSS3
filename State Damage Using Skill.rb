#==============================================================================
# TheoAllen - State Damage Using Skill
# Version : 1.0
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> Discord @ Theo#3034
#==============================================================================
($imported ||= {})[:Theo_StateSkillDamage] = true
#==============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.09.24 - Finished
#==============================================================================
%Q{

  ==================
  || Introduction ||
  ------------------
  Once upon a time, a man realized that slip damage from the default system
  is suck. Because it's based on percentage. So why not using a skill to create
  a slip damage?
  
  ======================
  || How to use this? ||
  ----------------------
  Put this under ▼ Materials
  
  Use this notetag in the state notebox <skill damage: id> 
  Change the ID accordingly to the skill ID you want to use as the slip damage
  
  Ex :
  <skill damage: 10>
  
  ===================
  || Terms of use ||
  -------------------
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.

}
#==============================================================================
# End of the instruction
#==============================================================================
class RPG::State
  
  # Store skill ID for formula damage
  def skill_damage
    if !@skill_damage
      @skill_damage = 0
      if note =~ /<skill[\s_]+damage\s*:\s*(\d+)>/i
        @skill_damage = $1.to_i
      end
    end
    return @skill_damage
  end
  
end

class Game_Battler
  
  alias theo_slipformula_clear_states clear_states
  def clear_states
    theo_slipformula_clear_states
    @state_battler = {}
  end
  
  alias theo_slipformula_eff_add_state_attack item_effect_add_state_attack
  def item_effect_add_state_attack(user, item, effect)
    theo_slipformula_eff_add_state_attack(user, item, effect)
    return unless @result.success
    user.atk_states.each do |state_id|
      if @states.include?(state_id)
        @state_battler[state_id] = user
      end
    end
  end
  
  alias theo_slipformula_eff_add_state_normal item_effect_add_state_normal
  def item_effect_add_state_normal(user, item, effect)
    theo_slipformula_eff_add_state_normal(user, item, effect)
    return unless @result.success
    if @states.include?(effect.data_id)
      @state_battler[effect.data_id] = user
    end
  end
  
  alias theo_slipformula_erase_state erase_state
  def erase_state(state_id)
    theo_slipformula_erase_state(state_id)
    @state_battler.delete(state_id)
  end
  
  alias theo_slipformula_turn_end on_turn_end
  def on_turn_end
    if alive?
      perform_slip_damage_formula
    end
    theo_slipformula_turn_end
  end
  
  def perform_slip_damage_formula
    @states.each do |state_id|
      if $data_states[state_id].skill_damage > 0 && @state_battler[state_id]
        skill = $data_skills[$data_states[state_id].skill_damage]
        item_apply(@state_battler[state_id], skill)
        self.animation_id = skill.animation_id
        SceneManager.scene.log_window.display_action_results(self, skill)
        if $imported["YEA-BattleEngine"] && !YEA::BATTLE::MSG_ADDED_STATES
          SceneManager.scene.perform_collapse_check(self)
        end
        15.times {SceneManager.scene.update_basic}
      end
    end
  end
  
end

class Scene_Battle
  attr_reader :log_window
end
