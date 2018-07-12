#===============================================================================
# Adjustable Picture Viewport v1.0
# By: TheoAllen
#-------------------------------------------------------------------------------
# Change log:
# > 2018.07.12 - Initial Release
#-------------------------------------------------------------------------------
# Bringing picture into different viewport. Allow you to place "Show Picture"
# below map sprites or above any UI
# 
# To use:
# Paste this script on your project (I assume you've already know how)
#
# Use these script call to move all picture to desired viewport
# - picture_send_back 
# - picture_normalize
# - picture_send_front
#
# Send back, will be shown below sprites. Do note that the pic may shake 
# alongside with map & sprites if you use shake screen
#
# Normalize, makes the picture send back to their original viewport. Above 
# sprites, below UI
#
# Send front, pic will be send in front of anything including UI
#-------------------------------------------------------------------------------
# Terms of Use
# > Free for non-commercial / commercial
#===============================================================================
class Game_Interpreter
  
  def picture_send_back
    $game_system.pic_flag = :back
    $game_temp.pic_change_refresh = true
    Fiber.yield
  end
  
  def picture_normalize
    $game_system.pic_flag = :normal
    $game_temp.pic_change_refresh = true
    Fiber.yield
  end
  
  def picture_send_front
    $game_system.pic_flag = :front
    $game_temp.pic_change_refresh = true
    Fiber.yield
  end
  
end

class Game_System
  attr_writer :pic_flag
  def pic_flag
    @pic_flag ||= :normal
  end
end

class Game_Temp
  attr_accessor :pic_change_refresh
end

class Spriteset_Map
  
  alias create_more_viewports create_viewports
  def create_viewports
    create_more_viewports
    @viewport4 = Viewport.new
    @viewport4.z = 999
  end
  
  alias dispose_more_viewports dispose_viewports
  def dispose_viewports
    dispose_more_viewports
    @viewport4.dispose
  end
  
  def update_pictures
    $game_map.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(pic_vport, pic)
      @picture_sprites[pic.number].update
    end
    if $game_temp.pic_change_refresh
      $game_troop.screen.pictures.each do |pic|
        @picture_sprites[pic.number].viewport = pic_vport
      end
      $game_temp.pic_change_refresh = false
    end
  end  
  
  def pic_vport
    case $game_system.pic_flag
    when :back
      return @viewport1
    when :normal
      return @viewport2
    when :front
      return @viewport4
    end
  end
  
end
