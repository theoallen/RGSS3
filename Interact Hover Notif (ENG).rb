# =============================================================================
# TheoAllen - Interact Hover Notification
# Version : 1.1
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# Translation: Davi Felipe (http://www.mundorpgmaker.com.br)
# =============================================================================
($imported ||= {})[:Theo_InteractNotif] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2013.08.21 - Bugfix when changing map
# 2013.08.04 - Bugfix at Event Page Condition
# 2013.07.24 - Finished script
# =============================================================================
=begin
 
  Introduction :
  This script display a hovering notification on events
  
  How to use :
  Put this script below Materials but above Main
  Use the comment <interact: interaction name> in the event
  
  Terms of Use :
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game. 
 
=end
# =============================================================================
# Configuration :
# =============================================================================
module THEO
  module Interact
    
    # Default message for events with the hover notification. Change the
    # text between "" to change the text that appears by default in all
    # the events
    DefaultNotif = "Interact"
    
    # Speed of the fade in / fade out on the notification
    FadeSpeed = 20
    
    # The bigger the value, the higher the notification will be above the event
    Displacement = 15
    
    # Maximum width
    Width  = 300
    
    # Font settings
    FontName = ["Calibri"]
    FontSize = 18
    FontBold = true
    FontItalic = false
    
  end
end
# =============================================================================
# End of configuration
# =============================================================================
class Game_Event < Game_Character
  attr_accessor :hover_notif
  
  alias theo_ihn_page_setting setup_page_settings
  def setup_page_settings
    theo_ihn_page_setting
    setup_hover_notif
  end  
  
  def setup_hover_notif
    @hover_notif = THEO::Interact::DefaultNotif
    @list.each do |command|
      next unless command.code == 108 || command.code == 408
      case command.parameters[0]
      when /<(?:INTERACT|interact): (.*)>/i
        @hover_notif = $1.to_s
      end
    end
  end
  
  def list_is_empty?
    list.all? do |command|
      command.code == 0 ||
      command.code == 108 ||
      command.code == 408 ||
      command.code == 118
    end
  end
  
  def trigger_is_possible?
    return false if list_is_empty?
    return false if trigger != 0
    return true
  end
  
  def meet_with_player?
    return in_front_of_player? if normal_priority?
    return below_or_above_player?
  end
  
  def in_front_of_player?
    self.x == $game_player.front_x && self.y == $game_player.front_y
  end
  
  def below_or_above_player?
    self.x == $game_player.x && self.y == $game_player.y
  end
  
  def showing_hover_notif?
    return false unless @hover_notif
    return false if @hover_notif.empty?
    return false if @erased
    return false if $game_map.interpreter.running?
    return trigger_is_possible? && meet_with_player?
  end
  
end
 
class Game_Player < Game_Character
  
  def front_x
    $game_map.round_x_with_direction(@x,@direction)
  end
  
  def front_y
    $game_map.round_y_with_direction(@y,@direction)
  end
  
end
 
class Window_InteractNotif < Window_Base
  include THEO::Interact
  
  def initialize(event)
    super(0,0,Width,fitting_height(1))
    self.opacity = 0
    self.contents_opacity = 0
    @event = event
    setup_font
    update_placement
    refresh
  end
  
  def setup_font
    font = contents.font
    font.size = FontSize
    font.name = FontName
    font.bold = FontBold
    font.italic = FontItalic
  end
  
  def refresh
    contents.clear
    @text = @event.hover_notif
    draw_text(contents.rect,@text,1)
  end
  
  def update
    super
    update_placement
    update_opacity
    refresh if need_refresh?
  end
  
  def update_placement
    self.x = @event.screen_x - self.width/2
    self.y = @event.screen_y - self.height - Displacement
  end
  
  def update_opacity
    if @event.showing_hover_notif?
      update_fadein
    else
      update_fadeout
    end    
  end
  
  def need_refresh?
    @text != @event.hover_notif
  end
  
  def line_height
    FontSize
  end
  
  def fade_speed
    return FadeSpeed
  end
  
  def update_fadein
    self.contents_opacity += fade_speed
  end
  
  def update_fadeout
    self.contents_opacity -= fade_speed
  end
  
end
 
class Scene_Map < Scene_Base
  
  alias theo_ihn_start start
  def start
    theo_ihn_start
    create_hover_notif_window
  end
  
  def create_hover_notif_window
    @notif_windows = []
    $game_map.events.values.each do |event|
      @notif_windows.push(Window_InteractNotif.new(event))
    end
  end
  
  alias theo_ihn_update update
  def update
    theo_ihn_update
    update_notif_windows
  end
  
  def update_notif_windows
    @notif_windows.each do |window|
      window.update
    end
  end
  
  alias theo_ihn_dispose_all dispose_all_windows
  def dispose_all_windows
    theo_ihn_dispose_all
    dispose_hover_notif
  end
  
  def dispose_hover_notif
    @notif_windows.each do |window|
      window.dispose
    end
  end
  
  alias theo_ihn_pre_trans pre_transfer
  def pre_transfer
    theo_ihn_pre_trans
    dispose_hover_notif
  end
  
  alias theo_ihn_post_trans post_transfer
  def post_transfer
    create_hover_notif_window
    theo_ihn_post_trans
  end
  
end
