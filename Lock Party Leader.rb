#===============================================================================
# TheoAllen - Lock Party Leader
# Version : 1.0
# Contact : www.theolized.com
#-------------------------------------------------------------------------------
# ID : Script ini membuat party leader ngga bisa ditukar ama member lain
# EN : This script makes party leader can not swapped with another party member 
#-------------------------------------------------------------------------------
# Free to use without exception
#===============================================================================
class Scene_Menu
  #-----------------------------------------------------------------------------
  # Overwrite formation ok
  #-----------------------------------------------------------------------------
  def on_formation_ok
    if @status_window.index == 0
      RPG::SE.stop
      Sound.play_buzzer
    elsif @status_window.pending_index >= 0
      $game_party.swap_order(@status_window.index,
                             @status_window.pending_index)
      @status_window.pending_index = -1
      @status_window.redraw_item(@status_window.index)
    else
      @status_window.pending_index = @status_window.index
    end
    @status_window.activate
  end
  
end
