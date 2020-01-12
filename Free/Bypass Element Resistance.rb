#===============================================================================
# Bypass Element resistance
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# When the user has tag <bypass element: (ID of the element)> it can bypass
# the elemental resistance. Boosting it to 100% damage rate. It does nothing
# if the elemental damage rate is already above 100%
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The tag can be used everywhere (except item/skill), which mean it can be in
# > actor
# > armor
# > weapon
# > state
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Terms:
# Free for commercial and non-commercial. No credit needed.
#===============================================================================
class RPG::BaseItem
  def element_bypass
    return @bypass_elements if @bypass_elements
    @bypass_elements = []
    note.split(/[\r\n]+/).each do |line|
      if note =~ /<bypass element\s*:\s*(\d+)>/i      
        @bypass_elements << $1.to_i
      end
    end
    return @bypass_elements
  end
end

class Game_Battler
  alias bypass_ele item_element_rate
  def item_element_rate(user, item)
    rate = bypass_ele(user, item)
    return [rate, 1.0].max if can_bypass_element?(user, item.damage.element_id)
    return rate
  end
  
  def can_bypass_element?(user, eleid)
    user.feature_objects.inject([]){|r, obj| 
      r + obj.element_bypass}.include?(eleid)
  end
end
