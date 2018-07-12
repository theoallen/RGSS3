# =============================================================================
# TheoAllen - Event Skip / Disable Event Command
# Version : 1.0
# =============================================================================
($imported ||= {})[:Theo_DisableEventCmd] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.10.14 - Finished script
# =============================================================================
=begin

  Introduction :
  This script is to disable some event command in event for debugging purpose.
  For example, you neither want to remove the intro of your game nor watch it 
  again, don't you?
  
  How to use :
  Put this script below material but above main
  
  Set the label <event skip> to start skipping event commands
  Set the label </event skip> to end skipping event commands
  
  Terms of use :
  It just for debugging purpose. Edit it as you want
  Free for commercial and non-commercial. Why would you use this for end 
  commercial product anyway?

=end
# =============================================================================
# No configuration
# =============================================================================
class Game_Interpreter
  
  alias theo_decmd_init initialize
  def initialize(*args)
    theo_decmd_init(*args)
    @event_skip = false
  end
  
  alias theo_decmd_118 command_118
  def command_118
    theo_decmd_118
    if !(@params[0] =~ /<event skip>/i).nil?
      @event_skip = true
    elsif !(@params[0] =~ /<\/event skip>/i).nil?
      @event_skip = false
    end
  end
  
  alias theo_decmd_exe_cmd execute_command
  def execute_command
    return skip_event_command if @event_skip
    return theo_decmd_exe_cmd
  end
  
  def skip_event_command
    command = @list[@index]
    @params = command.parameters
    @indent = command.indent
    if command.code == 118
      method_name = "command_#{command.code}"
      send(method_name) if respond_to?(method_name)
    else
      command_skip
    end
  end
  
end
