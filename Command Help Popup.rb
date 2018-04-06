# =============================================================================
# TheoAllen - Command Help Popup
# Version : 1.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script is translated into english by AbsoluteIce)
# =============================================================================
($imported ||= {})[:Theo_CommandHelp] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.03.12 - Finished Script
# =============================================================================
=begin

  Introduction :
  This script lets you create a help popup for the window commands such as
  in the main menu, battle, or the menu in the titlescreen.
  
  How to use :
  Put this script under materials, and above main.
  Edit the configuration for the script to work.
  
  Terms of use :
  Credit TheoAllen, the creator of this script. If you're able
  to edit the script on your own, go ahead as long as you don't claim
  it as your own. If you're going to use this script for a commercial
  project, don't forget to give me a free copy of the game! ~TheoAllen

=end
# =============================================================================
# Configuration :
# =============================================================================
module Theo
  module CmnHelp
    
    # ------------------------------------------------------------------------
    # The help definition is here, and the format is like this.
    # "command" => "help"
    #
    # The command name has to be the same in terms of caps and small letters.
    # ------------------------------------------------------------------------
    List = {
      "Skills" => "Lookup your character's skills",
      "Continue" => "Continue the last saved game",
    }
    
    Button   = :ALT   # The button pressed to execute the help window.
    ShowTime = 120    # How long it takes for the help window to be shown. (60 = 1 second)
    
  end
end
# =============================================================================
# End of configuration :
# =============================================================================
class Window_Command < Window_Selectable
  
  alias theo_cmhelp_init initialize
  def initialize(*args)
    theo_cmhelp_init(*args)
    @cmn_help = Window_CommandHelp.new(viewport)
  end
  
  alias theo_cmhelp_update update
  def update
    theo_cmhelp_update
    @cmn_help.update
  end
  
  alias theo_cmhelp_dispose dispose
  def dispose
    theo_cmhelp_dispose
    @cmn_help.dispose
  end
  
  alias theo_cmhelp_process_handling process_handling
  def process_handling
    theo_cmhelp_process_handling
    return unless open? && active
    return show_help if help_avalaible? && Input.trigger?(Theo::CmnHelp::Button)
  end
  
  def show_help
    @cmn_help.show(Theo::CmnHelp::List[command_name(index)])
  end
  
  def help_avalaible?
    Theo::CmnHelp::List.include?(command_name(index))
  end
  
end

class Window_CommandHelp < Window_Base
  
  def initialize(viewport)
    super(0,0,1,fitting_height(1))
    self.viewport = viewport
    self.openness = 0
    self.z = 999
    @text = ""
    @show_time = 0
  end
  
  def show(help)
    @text = help
    resize_window
    update_position
    draw_text_ex(0,0,@text)
    self.openness = 0
    @show_time = Theo::CmnHelp::ShowTime
  end
  
  def resize_window
    size = text_size(@text)
    new_w = size.width + (standard_padding * 2) + 2
    new_h = size.height + standard_padding * 2
    self.width = new_w
    self.height = new_h
    create_contents
  end
  
  def update_position
    self.x = (Graphics.width - width)/2
    self.y = (Graphics.height - height)/2
  end
  
  def update
    super
    update_showtime
  end
  
  def update_showtime
    if @show_time > 0
      open
    else
      close
    end
    @show_time -= 1
  end
  
end
