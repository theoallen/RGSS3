#===============================================================================
# Message will be skipped when there is no input until a certain frames has
# passed
#===============================================================================
class Window_Message
  FrameWait = 60
  
  def input_pause
    self.pause = true
    wait(10)
    FrameWait.times do
      Fiber.yield
      break if Input.trigger?(:B) || Input.trigger?(:C)
    end
    Input.update
    self.pause = false
  end
  
end
