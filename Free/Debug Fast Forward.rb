#===============================================================================
# Debug -  fast forward
#-------------------------------------------------------------------------------
class << Graphics
  
  alias debug_update update
  def update
    $force_skip = !$force_skip if Input.trigger?(:X) && ($TEST || $BTEST)
    return if $force_skip && ($TEST || $BTEST)
    debug_update
  end
  
end

class RPG::SE
  
  alias mod_play play
  def play
    return if $force_skip
    mod_play
  end
  
end

class Game_Interpreter
  SkipList = [101, 102, 103, 104, 105, 261, 250, 230, 212]
  
  # Overwrite
  def execute_command
    command = @list[@index]
    @params = command.parameters
    @indent = command.indent
    return if $force_skip && SkipList.include?(command.code)
    method_name = "command_#{command.code}"
    send(method_name) if respond_to?(method_name) 
  end
  
end

#===============================================================================
# Skip message jika selama X frame tidak ada input
#===============================================================================
class Window_Message
  FrameWait = 1
  
  # Overwrite
  alias ori_input_pause input_pause
  def input_pause
    if $force_skip && ($TEST || $BTEST))
      self.pause = true
      FrameWait.times do
        Fiber.yield
        break if Input.trigger?(:B) || Input.trigger?(:C)
      end
      Input.update
      self.pause = false
    else
      ori_input_pause
    end
  end
  
  def process_all_text
    open_and_wait
    return if $force_skip
    text = convert_escape_characters($game_message.all_text)
    pos = {}
    new_page(text, pos)
    process_character(text.slice!(0, 1), text, pos) until text.empty? ||
      $force_skip && ($TEST || $BTEST))
  end
  
end

#~ class Game_CharacterBase
#~   alias force_skip_move_speed real_move_speed
#~   def real_move_speed
#~     force_skip_move_speed * ($force_skip ? 3 : 1)
#~   end
#~ end
