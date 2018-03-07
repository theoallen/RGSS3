class << Graphics
  
  alias debug_update update
  def update
    return if Input.press?(:X) && ($TEST || $BTEST)
    debug_update
  end
  
end
