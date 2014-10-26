class Game_Switches
  
  Global_ID = [1,2,3] # <-- Set disini yang mau dijadiin global
  
  alias :glob_switch :[]
  alias :glob_switch_set :[]=
  
  def [](id)
    return $global_switches[id] if Global_ID.include?(id)
    return glob_switch(id)
  end
  
  def []=(id,val)
    return $global_switches[id] = val if Global_ID.include?(id)
    return glob_switch_set(id,val)
  end
  
end

class Game_GlobalSwitches < Game_Switches
  
  def [](id)
    return glob_switch(id)
  end
  
  def []=(id,val)
    return glob_switch_set(id,val)
  end
  
end

$global_switches = Game_GlobalSwitches.new
