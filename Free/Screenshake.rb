#===============================================================================
# The Art of Screenshake™
# By: TheoAllen
#===============================================================================
=begin 

  > Well, what is this all about?
  TLDR, just see this --> https://i.imgur.com/txUgLxQ.gif
  
  > How do I use?
  Put the script under materials
  Use script call
  
  shake_screen(duration, power)
  Example:
  
  shake_screen(45, 10)
  go experiment with the number yourself
  
  Terms of Service:
  > Free for commercial ¯\_(ツ)_/¯
  
=end
#===============================================================================
# * Don't you dare to shake these codes
#===============================================================================
class Game_Interpreter
  
  def shake_screen(duration, power)
    $game_temp.shake_maxdur = duration
    $game_temp.shake_dur = duration
    $game_temp.shake_power = power
  end
  
end

class Spriteset_Map
  
  alias theo_vlambeer_update_vport update_viewports
  def update_viewports
    theo_vlambeer_update_vport
    if $game_temp.shake_dur > 0
      $game_temp.shake_dur -= 1
      rate = $game_temp.shake_dur/$game_temp.shake_maxdur.to_f
      @viewport1.ox = rand($game_temp.shake_power)*rate*(rand > 0.5 ? 1 : -1)
      @viewport1.oy = rand($game_temp.shake_power)*rate*(rand > 0.5 ? 1 : -1)
    end
  end
  
end

class Game_Temp
  attr_accessor :shake_maxdur
  attr_accessor :shake_power
  attr_writer :shake_dur
  def shake_dur
    @shake_dur ||= 0
  end
end
