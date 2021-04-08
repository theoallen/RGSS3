# =============================================================================
# TheoAllen - Elemental Attack Modifier
# Version : 1.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_ElementAttack] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2013.05.08 - Started and Finished script
# =============================================================================
=begin

  INTRODUCTION :
  This script provides features to provide damage based modifications
  element. For example, when actor A holds fire rod, then all attacks are
  has a fire element will increase to 150%
  
  HOW TO USE :
  Write in notetag where aja (except skill / item)
  - <elem rate: id, rate%>
  Where :
  - id >> serial number of the element
  - rate >> percent of the modifier (100% = no change)
  
  Example: <elem rate: 1, 200%>
  
  TERMS OF USE:
  Credit gw, TheoAllen. Kalo such as u can ngedit2 script I trus so more
  cool, whatever. Ane is free. Origin ngga claims aja. If like
  dipake for commercial, do not forget, I divided it for free.
  
  NOTE: 
  If you want to add ideas for management elements, immediately wrote to comment
  blog at http://theolized.blogspot.com

=end
# =============================================================================
# There is no special configuration
# Through this line, if ga ngerti script ga need sok2an ngedit: v
# =============================================================================
module THEO
  module ELEMENTS
  module REGEXP
    
    RATE = /<(?:ELEM_RATE|elem rate):[ ]*[ ]*(\d+\s*,\s*\d*)([%％])>/i
    
  end
  end
end

module DataManager
  
  class << self
    alias pre_load_elem_rate load_database
  end
  
  def self.load_database
    pre_load_elem_rate
    load_elements_rate
  end
  
  def self.load_elements_rate
    [$data_actors,$data_classes,$data_weapons,$data_armors,$data_states,
      $data_enemies].each do |databases|
      databases.compact.each do |obj|
        obj.load_elements_rate
      end
    end
  end
  
end

class RPG::BaseItem
  attr_accessor :elem_rate
  
  def load_elements_rate
    @elem_rate = {}
    for i in -1..$data_system.elements.size
      @elem_rate[i] = 1.0
    end
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when THEO::ELEMENTS::REGEXP::RATE
        puts "loaded"
        rate = $1.scan(/\d+/)
        @elem_rate[rate[0].to_i] = (rate[1].to_f)*0.01
      end
    end
  end
  
end

class Game_Battler < Game_BattlerBase
  
  alias pre_elem_attack_rate item_element_rate
  def item_element_rate(user, item)
    rate = pre_elem_attack_rate(user,item)
    rate = apply_battler_elem_rate(user, item, rate)
    rate = apply_equips_elem_rate(user, item, rate)
    rate = apply_states_elem_rate(user, item, rate)
    rate
  end
  
  def apply_battler_elem_rate(user, item, value)
    if $imported[:Theo_MultiElements]
      item.elements_array.each do |elem|
        value *= user.elem_rate[elem]
      end
    else
      value *= user.elem_rate[item.damage.element_id]
    end
    return value
  end
  
  def apply_equips_elem_rate(user, item, value)
    return value if user.is_a?(Game_Enemy)
    if $imported[:Theo_MultiElements]
      item.elements_array.each do |elem|
        user.equips.compact.each do |eq|
          value *= eq.elem_rate[item.damage.element_id]
        end
      end
    else
      user.equips.compact.each do |eq|
        value *= eq.elem_rate[item.damage.element_id]
      end
    end
    return value
  end
  
  def apply_states_elem_rate(user, item, value)
    if $imported[:Theo_MultiElements]
      item.elements_array.each do |elem|
        user.states.each do |state|
          value *= state.elem_rate[elem]
        end
      end
    else
      user.states.each do |state|
        value *= state.elem_rate[item.damage.element_id]
      end
    end
    return value
  end
  
end

class Game_Actor < Game_Battler
  
  def elem_rate
    $data_actors[id].elem_rate
  end
  
end

class Game_Enemy < Game_Battler
  
  def elem_rate
    $data_enemies[enemy_id].elem_rate
  end
  
end
