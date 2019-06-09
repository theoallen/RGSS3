#==============================================================================
# TheoAllen - Notification Window
# Version : 1.0
# Language : English
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakervxace.net
# *> http://www.theolized.com
#==============================================================================
($imported ||= {})[:Theo_NotifWindow] = true
#==============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2015.02.09 - Translated to english + import the basic module
# 2013.09.22 - Finished
#==============================================================================
=begin

  ==================
  || Introduction ||
  ------------------
  This script give you an alternative to display a notification instead of
  showed up using show text. Notification will be displayed on the top-left
  corner with typing effect
  
  ======================
  || How to use ||
  ----------------------
  Put this script below material but above main
  
  To show notification, use this script call
  add_notif("Your notification text")
  
  ===================
  || Terms of use ||
  -------------------
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.

=end
#==============================================================================
# Configurations
#==============================================================================
module Theo
  module Notif
  #=============================================#
  # Timing (where 60 frame equal as 1 second) ~ #
  #=============================================#
    StartFadein = 15  # Frame required to show the notification window
    DelayTime   = 120 # Time wait before the next notification
    EndFadeout  = 15  # Frame required to hide the notification
    
  #=============================================#
  # Window color in (red, green, blue, alpha) ~ #
  #=============================================#
    ColorStart  = Color.new(0,0,0,180) # From left
    ColorEnd    = Color.new(0,0,0,50)  # To right
    
  #=============================================#
  # Position (smaller value means get on top) ~ #
  #=============================================#
    XPosition   = -6
    
  end
end
#==============================================================================
# Do not touch pass this line
#==============================================================================

#------------------------------------------------------------------------------
# Importing fuction from basic module because people hate to include scripter's
# basic module :v
#------------------------------------------------------------------------------

module THEO
  module FADE
    # Default duration of fading
    DEFAULT_DURATION = 60
    # -------------------------------------------------------------------------
    # *) Init core fade instance variables
    # -------------------------------------------------------------------------
    def init_fade_members
      @obj = nil
      @target_opacity = -1
      @fade_speed = 0.0
      @pseudo_opacity = 0
    end
    # -------------------------------------------------------------------------
    # *) Set object
    # -------------------------------------------------------------------------
    def setfade_obj(obj)
      @obj = obj
      @pseudo_opacity = @obj.opacity
    end
    # -------------------------------------------------------------------------
    # *) Fade function
    # -------------------------------------------------------------------------
    def fade(opacity, duration = DEFAULT_DURATION)
      @target_opacity = opacity
      make_fade_speed(duration)
    end
    # -------------------------------------------------------------------------
    # *) Determine fade speed
    # -------------------------------------------------------------------------
    def make_fade_speed(duration)
      @fade_speed = (@target_opacity - @obj.opacity)/duration.to_f
      @pseudo_opacity = @obj.opacity.to_f
    end
    # -------------------------------------------------------------------------
    # *) Fadeout function
    # -------------------------------------------------------------------------
    def fadeout(duration = DEFAULT_DURATION)
      fade(0, duration)
    end
    # -------------------------------------------------------------------------
    # *) Fadein function
    # -------------------------------------------------------------------------
    def fadein(duration = DEFAULT_DURATION)
      fade(255, duration)
    end
    # -------------------------------------------------------------------------
    # *) Update fade
    # -------------------------------------------------------------------------
    def update_fade
      if fade?
        @pseudo_opacity += @fade_speed
        @obj.opacity = @pseudo_opacity
      else
        @target_opacity = -1
      end
    end
    # -------------------------------------------------------------------------
    # *) Is performing fade?
    # -------------------------------------------------------------------------
    def fade?
      return false if @target_opacity == -1
      @target_opacity != @pseudo_opacity.round
    end
    
  end
end

#------------------------------------------------------------------------------
# End of import
#------------------------------------------------------------------------------

class Game_Interpreter
  
  def add_notif(text)
    $game_temp.stack_notif << text
  end
  
end

class Game_Temp
  attr_reader :stack_notif
  
  alias theo_typenotif_init initialize
  def initialize
    theo_typenotif_init
    @stack_notif ||= []
  end
  
end

class Window_TypingNotif < Window_Base
  class Opacity_Fade
    attr_accessor :opacity
    include THEO::FADE
    
    def initialize
      @opacity = 0
      init_fade_members
      setfade_obj(self)
    end
  end
  
  Color1 = Theo::Notif::ColorStart
  Color2 = Theo::Notif::ColorEnd
  
  def initialize
    super(-12,Theo::Notif::XPosition,Graphics.width+24,fitting_height(1))
    @ref = Opacity_Fade.new
    refresh
    self.contents_opacity = @ref.opacity
    self.opacity = 0
  end
  
  def refresh
    contents.clear
    contents.gradient_fill_rect(contents.rect, Color1, Color2)
  end
  
  def update
    super
    @ref.update_fade
    self.contents_opacity = @ref.opacity
    if @fiber.nil? && !$game_temp.stack_notif.empty?
      @fiber = Fiber.new { update_notif_fiber }
    elsif @fiber
      @fiber.resume
    end
  end
  
  def update_notif_fiber
    refresh
    @ref.fadein(Theo::Notif::StartFadein)
    Fiber.yield while @ref.fade?
    loop do
      notif = $game_temp.stack_notif.shift
      refresh
      draw_text_ex(4 + 12,0,notif)
      Theo::Notif::DelayTime.times { Fiber.yield }
      break if $game_temp.stack_notif.empty?
    end
    @ref.fadeout(Theo::Notif::EndFadeout)
    Fiber.yield while @ref.fade?
    @fiber = nil
  end
  
  def process_character(*args)
    super(*args)
    Fiber.yield
  end
  
end


class Scene_Map
  
  alias theo_typenotif_start start
  def start
    theo_typenotif_start
    @notif_text = Window_TypingNotif.new
  end
  
end
