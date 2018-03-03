#==============================================================================
# TheoAllen - State Damage Using Skill
# Version : 1.0
# Language : Informal Indonesian
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://theolized.blogspot.com
#==============================================================================
($imported ||= {})[:Theo_StateSkillDamage] = true
#==============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.09.24 - Finished
#==============================================================================
%Q{

  =================
  || Perkenalan ||
  -----------------
  Pernah kepikiran untuk membuat slip damage pada state tidak hanya berdasar
  pada persenan? Namun berdasar skill? Dimana di dalam skill tersebut ada
  formula yang dimana user (dilambangkan 'a' dalam formula) adalah yang 
  memberikan state tersebut kepada target? Dengan kata lain, slip damage
  tergantung kepada subject yang memberikan state pada korban. Script ini akan 
  membantumu
  
  ======================
  || Cara penggunaan ||
  ----------------------
  Pasang script ini di bawah material namun di atas main.
  
  Gunakan tag <skill damage: id> pada state notebox
  dimana id adalah ID dari skill yang akan kamu pakai
  
  Contoh :
  <skill damage: 10>
  
  ===================
  || Terms of use ||
  -------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

}
#==============================================================================
# Tidak ada konfigurasi
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
