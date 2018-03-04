=begin
 
  Theo - Prevent Charge TP by Damage
  
  This script prevent some skill damage not charge the actor's TP if actor is
  getting hit. Simply put <no charge> in skill / item notebox.
  
  Terms of Use :
  > Free to edit / Repost
  > Free for commercial
  > Credit is not required, but don't claim it's yours
 
=end
class RPG::UsableItem
  
  def no_charge?
    return @no_charge if @no_charge
    @no_charge = !note[/<no[\s_]+charge>/i].nil?
    return @no_charge
  end
  
end
 
class Game_ActionResult
  attr_accessor :carried_item
  
  alias aed_clear clear
  def clear
    aed_clear
    @carried_item = nil
  end
  
  alias aed_make_damage make_damage
  def make_damage(value, item)
    @carried_item = item
    aed_make_damage(value, item)
  end
  
end
 
class Game_Battler
  
  alias aed_charge_tp charge_tp_by_damage
  def charge_tp_by_damage(damage_rate)
    return if @result.carried_item.no_charge?
    aed_charge_tp(damage_rate)
  end
  
end
