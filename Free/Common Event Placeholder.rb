#===============================================================================
# Common Event Placeholder
# By: TheoAllen
#-------------------------------------------------------------------------------
# Disclaimer: 
# > Might contain unintended glitches if used incorrectly
#-------------------------------------------------------------------------------
# This script will replace event label with "<placeholder>" text on it if the
# common event is called by using event commands. It will take the next event
# command to replace the "<placeholder>".
#
# If you put more than one "<placeholder>", it will take as many as it needs
# to replace it
#
# Limitation:
# > You can not use this to insert a conditional branch event
#-------------------------------------------------------------------------------
# Terms of use
# - This script is free and should be remain free
# - You're free to edit the script or repost it anywhere
# - Any derivative works must be remain free
# - Commercial/non-commercial use ok
#===============================================================================

class RPG::CommonEvent
  Tag = /<placeholder>/
  
  def param_required
    return @param_required if @param_required
    @param_required = []
    @list.each_with_index do |li, index|
      next unless li.code == 118 && li.parameters[0] =~ Tag
      @param_required << index
    end
    return @param_required
  end
  
  def replace_placeholder(parent_list, index)
    @param_required.each do |i|
      @list[i] = parent_list.delete_at(index+1)
    end
  end
  
end

class Game_Interpreter
  
  def command_117
    common_event = $data_common_events[@params[0]]
    if common_event
      if common_event.param_required.size > 0
        common_event = copy(common_event)
        @list = copy(@list)
        common_event.replace_placeholder(@list, @index)
      end
      child = Game_Interpreter.new(@depth + 1)
      child.setup(common_event.list, same_map? ? @event_id : 0)
      child.run
    end
  end
  
  def copy(object)
    Marshal.load(Marshal.dump(object))
  end
  
end
