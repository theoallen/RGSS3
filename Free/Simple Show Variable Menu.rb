#===============================================================================
# Simple Show Variable Menu
# By: TheoAllen
#-------------------------------------------------------------------------------
# Last edited : 2018.07.29
#-------------------------------------------------------------------------------
# Perhaps you want to display a game variable in convenient way like by 
# accessing a menu? This script is for you
#
# If you have incompatibilities with some custom menu, deal with it yourself.
#-------------------------------------------------------------------------------
# Terms of Use
# Free for commercial and non-commercial
#===============================================================================
module Theo
  
  VarMenuTitle    = "Variable Display"
  # Title for the menu
  
  VarMenuColumn   = 2
  # Column to split variable display
  
  VarMenu_VarID   = [1,2,3,4,5,6,7,8,9,10]
  # Variable ID to be shown
  
  VarMenu_Height  = 5
  # Window height according to how many lines will be displayed
  
  VarMenu_Vocab   = "Statistic"
  # Vocab for main menu
  
end
#===============================================================================
# End of safe line
#===============================================================================
class Window_MenuVarTitle < Window_Base
  
  def initialize
    super(0,0,Graphics.width,fitting_height(1))
    draw_text(contents.rect, Theo::VarMenuTitle, 1)
  end
  
end

class Window_MenuVariable < Window_Base
  def initialize
    super(0,fitting_height(1),Graphics.width,
      fitting_height(Theo::VarMenu_Height))
    draw_all_variables
  end
  
  def draw_all_variables
    Theo::VarMenu_VarID.each_with_index do |id, i|
      rect = item_rect(i)
      change_color(system_color)
      draw_text(rect, $data_system.variables[id])
      change_color(normal_color)
      draw_text(rect, $game_variables[id], 2)
    end
  end
  
  def item_rect(index)
    x = (index % Theo::VarMenuColumn) * (contents_width / Theo::VarMenuColumn)
    y = (index / Theo::VarMenuColumn) * line_height
    w = contents_width / Theo::VarMenuColumn - span
    h = line_height
    Rect.new(x,y,w,h)
  end
  
  def span
    return 12
  end
  
end

class Window_MenuCommand
  alias theo_var_menu add_original_commands
  def add_original_commands
    theo_var_menu
    add_command(Theo::VarMenu_Vocab, :varmenu)
  end
end

class Scene_Menu
  alias theo_var_menu_cmd create_command_window
  def create_command_window
    theo_var_menu_cmd
    @command_window.set_handler(:varmenu, method(:varmenu_ok))
  end
  
  def varmenu_ok
    SceneManager.call(Scene_VarMenu)
  end
end

class Scene_VarMenu < Scene_MenuBase
  
  def start
    super
    @title = Window_MenuVarTitle.new
    @content = Window_MenuVariable.new
  end
  
  def update
    super
    if Input.trigger?(:C) || Input.trigger?(:B)
      Sound.play_cancel
      Input.update
      SceneManager.return
    end
  end
  
end
