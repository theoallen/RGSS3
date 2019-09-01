# Full explanation: https://forums.rpgmakerweb.com/index.php?threads/a-better-game_interpreter-line-1411-error-backtracer.112849/
class Game_Interpreter
  
  def command_355
    script = @list[@index].parameters[0] + "\n"
    while next_event_code == 655
      @index += 1
      script += @list[@index].parameters[0] + "\n"
    end
    name = "command_ex"
    eval("create_method(:#{name}) {#{script}}")
    method(name).call
  end
  
  def create_method(name, &block)
    self.class.send(:define_method, name, &block)
  end
  
end
