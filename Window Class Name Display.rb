#===============================================================================
# TheoAllen - Window Class Name Display
# Version 1.0
#===============================================================================
# Change log :
# 2014.11.08 - Finished
#===============================================================================
if true # <-- set false untuk deactivate
#===============================================================================
# Script ini cuman snippet iseng buat nampilin nama window kalau dipencet
# tombol tertentu yang kamu tentukan di bawah
#
# Special Thanks :
# - Aussenseiter Project (Lahan praktek)
# - Luna Engine (inspirasi)
#===============================================================================

  InputDisplay = :SHIFT
  ClassBGColor = Color.new(0,0,0,150)
  
#===============================================================================
# End config 
#===============================================================================
class Window_Base
  alias asr_base_init initialize
  def initialize(*args)
    asr_base_init(*args)
    text = "#{self.class}"
    size = text_size(text).width + 4
    @window_name = Sprite.new
    @window_name.viewport = viewport
    @window_name.bitmap = Bitmap.new(size, 24)
    @window_name.bitmap.fill_rect(@window_name.bitmap.rect, ClassBGColor)
    @window_name.bitmap.draw_text(@window_name.bitmap.rect, text)
    @window_name.z = 999
    update_window_name
  end
  
  alias asr_base_update update
  def update
    asr_base_update
    update_window_name
  end
  
  def update_window_name
    return unless @window_name
    @window_name.x = self.x
    @window_name.y = self.y
    @window_name.visible = visible && Input.press?(InputDisplay) 
    @window_name.opacity = [opacity, back_opacity, 
      contents_opacity, openness].max
  end
  
end

end
