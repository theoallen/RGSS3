#===============================================================================
# "Last Get" Text - VXA Version
# By: TheoAllen
#-------------------------------------------------------------------------------
# Stolen the idea from: 
# https://forums.rpgmakerweb.com/index.php?threads/last-get-text.109846
#===============================================================================
# Short description:
#-------------------------------------------------------------------------------
# If you use \lastget in the message box, it will be replaced with whatever 
# item you just get it. Works only in event command, not script call
#-------------------------------------------------------------------------------
# Configuration:
#-------------------------------------------------------------------------------
# Change the format here
# <V> = value/amount of item get
# <I> = item icon (only valid for items/weapons/armors, not gold)
# <N> = item name
#-------------------------------------------------------------------------------
  LastGetFormat = "<V> <I><N>"
#===============================================================================
# Terms of use:
# Free for commercial/non-commercial
#===============================================================================
class Game_Interpreter
  alias lastget_125 command_125
  alias lastget_126 command_126
  alias lastget_127 command_127
  alias lastget_128 command_128
  #--------------------------------------------------------------------------
  # * Change Gold
  #--------------------------------------------------------------------------
  def command_125
    lastget_125
    value = operate_value(@params[0], @params[1], @params[2])
    name = Vocab.currency_unit
    $game_system.last_get = text_format(value,"",name)
  end
  #--------------------------------------------------------------------------
  # * Change Items
  #--------------------------------------------------------------------------
  def command_126
    lastget_126
    value = operate_value(@params[1], @params[2], @params[3])
    icon = "\eI[#{$data_items[@params[0]].icon_index}]"
    name = $data_items[@params[0]].name
    $game_system.last_get = text_format(value,icon,name)
  end
  #--------------------------------------------------------------------------
  # * Change Weapons
  #--------------------------------------------------------------------------
  def command_127
    lastget_127
    value = operate_value(@params[1], @params[2], @params[3])
    icon = "\eI[#{$data_weapons[@params[0]].icon_index}]"
    name = $data_weapons[@params[0]].name
    $game_system.last_get = text_format(value,icon,name)    
  end
  #--------------------------------------------------------------------------
  # * Change Armor
  #--------------------------------------------------------------------------
  def command_128
    lastget_128
    value = operate_value(@params[1], @params[2], @params[3])
    icon = "\eI[#{$data_armors[@params[0]].icon_index}]"
    name = $data_armors[@params[0]].name
    $game_system.last_get = text_format(value,icon,name)
  end
  
  def text_format(v,i,n)
    text = LastGetFormat.clone
    text.gsub!("<V>") {v}
    text.gsub!("<I>") {i}
    text.gsub!("<N>") {n}
    text
  end
end

class Window_Base
  alias lastget_convert_esc convert_escape_characters
  def convert_escape_characters(text)
    result = lastget_convert_esc(text)
    result.gsub!(/\elastget/i) { $game_system.last_get }
    result
  end
end

class Game_System
  attr_accessor :last_get
end
