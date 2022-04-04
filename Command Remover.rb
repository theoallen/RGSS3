# =============================================================================
# TheoAllen - Command Remover
# Version : 1.0
# Contact : Discord @ Theo#3034
# =============================================================================
($imported ||= {})[:Theo_CommandRemover] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2013.08.09 - Finished script
# =============================================================================
=begin

  Introduction :
  This script allow you to temporary erase a certain command and display it
  again later using Game Switches
 
  How to use :
  Put this script below material but above main
  Edit the configuration
 
  Terms of use :
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.
 
=end
# =============================================================================
# Configuration :
# =============================================================================
module THEO
  module Command
    
    # Write down the command name you want to remove. Then turn on the switch
    # If you want to display it again, just turn off the switch
    
    List = {
    # "Command Name" => Switch id,
      "Items"     => 38,
      "Skills"     => 38,
      "Equipment"     => 38,
      "Team Setup"     => 51,
      "Soul Shards"     => 52,
      "Bestiary" => 33,
      "Class"     => 53,
      "Status" => 38,
    # Add by yourself
    } # <-- don't touch this
    
  end
end
# =============================================================================
# End of configuration
# =============================================================================
class Window_Command < Window_Selectable
  alias theo_disable_add_command add_command
  def add_command(name, symbol, enabled = true, ext = nil)
    hash = THEO::Command::List
    if hash.include?(name)
      return if $game_switches[hash[name]]
    end
    theo_disable_add_command(name,symbol,enabled,ext)
  end
end
