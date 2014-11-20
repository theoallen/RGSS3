#===============================================================================
# Skip message jika selama X frame tidak ada input
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
