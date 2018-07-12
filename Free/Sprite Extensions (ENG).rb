#==============================================================================
# TheoAllen - Sprite Extensions
# Version : 1.0
# Language : English
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://www.theolized.com
#==============================================================================
($imported ||= {})[:Theo_SpriteEX] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.11.12 - English translation
# 2014.10.30 - Finished script
# =============================================================================
%Q{

  ==================
  || Introduction ||
  ------------------
  Have you ever thought to import the window functions like draw_text_ex or
  draw_gauge into sprite? But you don't want to copy all the functions into
  sprite?
  
  By this script, you can use all of window_base functions into Sprite class
  such as draw_text_ex, draw_gauge, or even draw_actor_simple_status.
  
  ================
  || How to use ||
  ----------------
  Put this script below material but above main
  
  As I already described above, now it's your turn to use window's function
  on Sprite class or Plane. The rest is depends on how do you use that.

}
# =============================================================================
# No config ~
# =============================================================================
module Theo
  class Global_Window < Window_Base
    attr_accessor :sprite_ref
    
    def contents
      if @sprite_ref
        if @sprite_ref.disposed?
          @sprite_ref = nil
          return super
        else
          return sprite_ref.bitmap
        end
      else
        super
      end
    end
    
  end
  
  def self.glob_window
    if @glob_window.nil? || @glob_window.disposed?
      @glob_window = Global_Window.new(0,0,1,1)
      @glob_window.visible = false
      @glob_window.gobj_exempt if @glob_window.respond_to?(:gobj_exempt)
      # Compatibility with mithran's
    end
    return @glob_window
  end
  
end

class Sprite
  
  def method_missing(name, *args, &block)
    window = Theo.glob_window
    if window.respond_to?(name)
      window.sprite_ref = self
      window.send(name, *args, &block)
    else
      super
    end
  end
  
end

class Plane
  
  def method_missing(name, *args, &block)
    window = Theo.glob_window
    if window.respond_to?(name)
      window.sprite_ref = self
      window.send(name, *args, &block)
    else
      super
    end
  end
  
end
