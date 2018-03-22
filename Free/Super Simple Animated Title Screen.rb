#===============================================================================
# Super Simple Animated Title Screen
# By: TheoAllen
#-------------------------------------------------------------------------------
# Getting tired of animated title screen script that offers you a lot of things 
# you don't even need? And why not just use traditional frame per frame 
# animated background?
#
# This script is an answer for you
#
# Terms of Use
# Free for commercial and non-commercial
#===============================================================================
module SSAnimTitle
  
  # Set the frame here. Note that it will ONLY change the title1. And will not
  # animate the border part (title2)
  BackGround = [
  "Book",
  "Castle",
  "Crystal",
  ]
  
  # Frame rate. Higher = slower
  Rate = 5
end
#===============================================================================
# End of config
#===============================================================================
class Scene_Title
  
  alias ss_anim_title_start start
  def start
    ss_anim_title_start
    @count = 0
    @bg_index = 0
  end
  
  alias ss_anim_title_update update
  def update
    ss_anim_title_update
    @count += 1
    refresh_bg if @count % SSAnimTitle::Rate == 0
  end
  
  def refresh_bg
    @bg_index += 1
    @bg_index %= SSAnimTitle::BackGround.size
    @sprite1.bitmap = Cache.title1(SSAnimTitle::BackGround[@bg_index])
    center_sprite(@sprite1)
  end
  
end
