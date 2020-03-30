#===============================================================================
# Show picture, but what is being shown is a text
#-------------------------------------------------------------------------------
# Usage (script call): 
# > $game_map.screen.pictures[ID].show([name],x,y,zoom_x,zoom_y,opacity,0)
# > $game_map.screen.pictures[ID].show(["Text"],20,30,100,200,255,0)
#-------------------------------------------------------------------------------
class Sprite_Picture
  @@bitmap = Bitmap.new(1,1)
  
  def self.size_ref
    if @@bitmap.disposed?
      @@bitmap = Bitmap.new(1,1)
    end
    return @@bitmap
  end
  
  def update_bitmap
    if @picture.name.is_a?(Array)
      if @name != @picture.name
        @name = @picture.name
        size = Sprite_Picture.size_ref.text_size(@name[0])
        self.bitmap = Bitmap.new(size.width + 2, size.height)
        bitmap.draw_text(size, @name[0])
      end
    elsif @picture.name.empty?
      self.bitmap = nil
    else
      self.bitmap = Cache.picture(@picture.name)
    end
  end
  
end
#===============================================================================
# * End
#===============================================================================
