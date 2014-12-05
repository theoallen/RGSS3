#===============================================================================
# TheoAllen - Insane Anti Lag
# Version : 1.0
# Language : English
#-------------------------------------------------------------------------------
# With help from following people :
# - Tsukihime
# - KilloZapit
# - Galv
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#-------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://www.theolized.com
#===============================================================================
($imported ||= {})[:Theo_AntiLag] = true
#===============================================================================
# Change Logs:
# ------------------------------------------------------------------------------
# 2014.**.** - Finished
#===============================================================================
=begin

  ------------------------------------------
  *) Introduction :
  ------------------------------------------
  As most of you already know, lag is common problem in RPG Maker games. You may
  started to think it was because you have many events on map. And so, to avoid 
  lag, you split your map into part and limiting the event as well. 
 
  It's not entirely wrong because when you have a lot of events, program need
  to checks all events. However, it wasn't done efficienly. This script 
  increase the efficiency on how default script works and prevent unecessary 
  update when it's not needed to gain speed.
    
  However, I can not guarantee that it will have high compatibility since I
  overwrite most of stuff. I will likely to make compatibility with my own
  scripts. But I'm not sure about someone's script.
  
  ------------------------------------------
  *) How to use :
  ------------------------------------------
  Put this script below material but above main. And it's recommended to put 
  this above most of custom script.
  
  Set the type of optimization that you like in config
  You may disable some kind of optimization if you have compatibility issues
  
  ------------------------------------------
  *) Terms of use : 
  ------------------------------------------
  Credit me, TheoAllen. You are free to edit this script by your own. As long 
  as you don't claim it's yours. For commercial purpose, don't forget to give me
  a free copy of the game.
  
  Additional people to put in credit credit list are listed in header above. 
  You should give them a free copy of your game as well if it's commercial ;)
  
=end
#==============================================================================
# Configurations :
#==============================================================================
module Theo
  module AntiLag
    
  #=============================================================================
  # *) Normal optimization
  #-----------------------------------------------------------------------------
  # This kind of optimization is for normal usage. These optimization may works
  # only if the total events on map is around 200 - 300.
  #=============================================================================
  
  #-----------------------------------------------------------------------------
    Optimize_XY     = true
  #-----------------------------------------------------------------------------
  # By default, event position checking is to check ALL the events on the map.
  # If you want to check an event is in x,y position, it ask EVERY event if 
  # their position is match. By using this optimization, all events registered
  # to the map table so that the engine won't check all events on map. Instead,
  # it checks if there's event on a certain table.
  #
  # This kind of optimization is recommended to set it to true. However, it may
  # not compatible with any pixel movement since they using box collider instead
  # of using grid.
  #-----------------------------------------------------------------------------
  
  #-----------------------------------------------------------------------------
    Optimize_Event  = true
  #-----------------------------------------------------------------------------
  # By default, if the engine want to check if there's event starting, they 
  # checked ALL the events on map. They did it in every frame. If you have 200
  # events in map, they checked 60 x 200 events per second.
  #
  # By using this optimization, if event is triggered, it will be registered
  # into a record. And then engine checked if there is event on the record
  #-----------------------------------------------------------------------------
  
  #-----------------------------------------------------------------------------
    Optimize_Sprite = true
  #-----------------------------------------------------------------------------
  # By default, the engine still update every sprites which located off screen.
  # This might waste the time since updating it is not necessary sometimes. By
  # using this optimization, it ignores character sprite that already off screen
  #-----------------------------------------------------------------------------
    
  #=============================================================================
  # *) Insane optimization
  #-----------------------------------------------------------------------------
  # This kind of optimization is to overcome the problem of using event beyond
  # 230 on the map which normal optimization is failed to do. This optimization
  # uses insane algorithm like table search and dispose any unecessary sprite on
  # the fly.
  #=============================================================================
    
  #-----------------------------------------------------------------------------
    Table_Limit_Search = 230
  #-----------------------------------------------------------------------------
  # Table search is a custom algorithm to grab events based on the map table.
  # Instead of iterating all events and checked them if they're on the screen,
  # it checked the visible map table instead. So, event that located far away
  # from the player won't be updated. But any parallel process or autorun events
  # or move route for an event will still updated.
  #
  # Table limit search means that if the total of events on map is above the
  # limit, this script will switch event update algorithm to table search. So
  # you will not worrying about having 999 or even 10.000 events on map.
  #
  # Table search required Optimize_XY to set to true.
  #
  # If you don't want to use table search algorithm, just put the parameter
  # to nil.
  #-----------------------------------------------------------------------------
  
  #-----------------------------------------------------------------------------
    Table_Range_Search = 3
  #-----------------------------------------------------------------------------
  # This determine how far table search will perform check. Putting 3 means that
  # it will update the event that located 3 tiles away from the screen.
  #
  # Keep in mind that the longer range search will affect the performance as
  # well. It's recommended to put it between 2 - 4
  #-----------------------------------------------------------------------------
  
  #-----------------------------------------------------------------------------
    Dispose_Sprite  = true
  #-----------------------------------------------------------------------------
  # Sometimes, limiting the events which is being updated is not enough. Sprite
  # objects is still being performace killer. Disposing sprite which is already
  # off screen will greatly affect the performance. This kind of optimization
  # is enabled only if the table search is used.
  #
  # Disposing sprite on the fly might be problematic sometimes. When something
  # wrong happened, you can disable dispose sprite be setting this to false.
  #-----------------------------------------------------------------------------
    
  end
end

#===============================================================================
# *) Final note :
#-------------------------------------------------------------------------------
# After all, these are just my attempt to speed up the game. Performance are
# still under influence by many factors. These include but may not limited to 
#
# - Your CPU speed
# - Your laptop / PC temperature 
# - How much power do you give for your CPU
# - Multi tasking
# - Someone's script
#
# I once used RM in old computer. When I switched to more advanced laptop, I 
# saw that 60 FPS is really smooth.
#
# If your CPU seems overheat, turn off your laptop / PC for a while for cooling.
# My laptop was once overheat due to broken fan. When I played my own game I
# got 10 FPS. I made my own antilag and no one of them worked until I realized
# my laptop was overheat.
# 
# Power saver mode in laptop may affect performance. Try to go high performance
# instead and let see if the lag gone. Once my friend played my game using power
# saver mode, and he got 15 FPS.
#
# If you have many programs running at same time, it may cause a little lag in
# RPG Maker games. Something like the screen won't be updated for a while.
#
# Some scripts can affect performance if it's not done right. This antilag
# script is tested using default script without additional scripts which 
# directly affect something on map.
#
#-------------------------------------------------------------------------------
# *) Below this line is sacred place to visit. Unless you have enough skill,
# do not try to enter or any risk is yours.
#===============================================================================

#===============================================================================
# ** MapTable
#-------------------------------------------------------------------------------
#  This class used to register the event into 2D table to increase performance
#===============================================================================

class MapTable
  #-----------------------------------------------------------------------------
  # * Initialize
  #-----------------------------------------------------------------------------
  def initialize
    @table = []
    ($game_map.width + 1).times do |x|
      @table[x] = []
      ($game_map.height + 1).times do |y|
        @table[x][y] = []
      end
    end
  end
  #-----------------------------------------------------------------------------
  # * Set value
  #-----------------------------------------------------------------------------
  def set(x,y,val)
    @table[x][y] << val
  end
  #-----------------------------------------------------------------------------
  # * Get array
  #-----------------------------------------------------------------------------
  def get(x,y)
    @table[x][y]
  end
  
end

#===============================================================================
# ** Array
#===============================================================================

class Array
  
  # Just a fool proof
  def values
    return self
  end
  
end

#===============================================================================
# ** Game_Map
#===============================================================================

class Game_Map
  #-----------------------------------------------------------------------------
  # * Public attributes
  #-----------------------------------------------------------------------------
  attr_accessor :event_redirect     # Redirect events
  attr_reader :forced_update_events # To keep force move route updated
  attr_reader :keep_update_events   # To keep parallel process updated
  attr_reader :cached_events        # To store event that need to be updated
  attr_reader :starting_events      # To store activated event
  attr_reader :table                # 2D Map table
  #-----------------------------------------------------------------------------
  # * Constant
  #-----------------------------------------------------------------------------
  EVENT_LIMIT = Theo::AntiLag::Table_Limit_Search
  RANGE = Theo::AntiLag::Table_Range_Search
  #-----------------------------------------------------------------------------
  # * Alias method : Setup Events
  #-----------------------------------------------------------------------------
  alias theo_antilag_setup_events setup_events
  def setup_events
    @table = MapTable.new
    @forced_update_events = []
    @keep_update_events = []
    @starting_events = []
    theo_antilag_setup_events
    select_on_screen_events
  end
  #-----------------------------------------------------------------------------
  # * Overwrite method : Events
  #-----------------------------------------------------------------------------
  def events
    @event_redirect ? @cached_events : @events
  end
#///////////////////////////////////////////////////////////////////////////////
  if Theo::AntiLag::Optimize_XY
#///////////////////////////////////////////////////////////////////////////////
  #-----------------------------------------------------------------------------
  # * Overwrite method : Event XY
  #-----------------------------------------------------------------------------
  def events_xy(x, y)
    @table.get(x,y)
  end
  #-----------------------------------------------------------------------------
  # * Overwrite method : Event XY nt
  #-----------------------------------------------------------------------------
  def events_xy_nt(x, y)
    @table.get(x,y).select do |event| 
      event.pos_nt?(x, y) 
    end
  end
#///////////////////////////////////////////////////////////////////////////////
  end
#///////////////////////////////////////////////////////////////////////////////
  if Theo::AntiLag::Optimize_Event
#///////////////////////////////////////////////////////////////////////////////
  #-----------------------------------------------------------------------------
  # * Overwrite method : Setup starting event
  #-----------------------------------------------------------------------------
  def setup_starting_map_event
    event = @starting_events[0]
    event.clear_starting_flag if event
    @interpreter.setup(event.list, event.id) if event
    event
  end
  #-----------------------------------------------------------------------------
  # * Overwrite method : Any event starting?
  #-----------------------------------------------------------------------------
  def any_event_starting?
    !@starting_events.empty?
  end
#///////////////////////////////////////////////////////////////////////////////
  end
#///////////////////////////////////////////////////////////////////////////////
  #-----------------------------------------------------------------------------
  # * Overwrite method : Refresh
  #-----------------------------------------------------------------------------
  def refresh
    @events.each_value {|event| next if event.never_refresh; event.refresh }
    @common_events.each {|event| event.refresh }
    refresh_tile_events
    @need_refresh = false
  end
  #-----------------------------------------------------------------------------
  # * Overwrite method : Update events
  #-----------------------------------------------------------------------------
  def update_events
    last_events = (@cached_events.dup rescue @events.values)
    select_on_screen_events
    events = @cached_events | @keep_update_events | @forced_update_events
    if Theo::AntiLag::Dispose_Sprite
      offscreen_events = last_events - events
      offscreen_events.each {|event| event.delete_sprite}
    end
    events.each {|event| event.update}
    @common_events.each {|event| event.update}
  end
  #-----------------------------------------------------------------------------
  # * New method : Select on screen events
  #-----------------------------------------------------------------------------
  def select_on_screen_events
    unless table_update?
      @cached_events = @events.values
      return
    end
    #---------------------------------------------------------------------------
    # * Table search algorithm
    #---------------------------------------------------------------------------
    new_dpx = display_x.to_i
    new_dpy = display_y.to_i
    dpx = loop_horizontal? ? new_dpx - RANGE : [new_dpx - RANGE, 0].max
    dpy = loop_vertical? ? new_dpy - RANGE : [new_dpy - RANGE, 0].max
    sw = (Graphics.width >> 5) + RANGE * 2
    sh = (Graphics.height >> 5) + RANGE * 2
    @cached_events = []
    sw.times do |x|
      sh.times do |y|
        xpos = loop_horizontal? ? (x + dpx) % width : x + dpx
        ypos = loop_vertical? ? (y + dpy) % height : y + dpy
        next if xpos >= width || ypos >= height
        ary = @table.get(xpos, ypos)
        @cached_events += ary
      end
    end
    @cached_events.uniq!
  end
  #-----------------------------------------------------------------------------
  # * Check if table search need to be performed or not
  #-----------------------------------------------------------------------------
  def table_update?
    EVENT_LIMIT && @events.size > EVENT_LIMIT && Theo::AntiLag::Optimize_XY
  end
  
end

#===============================================================================
# ** Game_Temp
#===============================================================================

class Game_Temp
  attr_reader :event_sprites
  #-----------------------------------------------------------------------------
  # * Alias method : Initialize
  #-----------------------------------------------------------------------------
  alias theo_antilag_init initialize
  def initialize
    theo_antilag_init
    @event_sprites = {}
  end
  
end

#===============================================================================
# ** Game_CharacterBase
#===============================================================================

class Game_CharacterBase
  #-----------------------------------------------------------------------------
  # * Empty method : Sprite
  #-----------------------------------------------------------------------------
  def sprite
    return nil
  end
  #-----------------------------------------------------------------------------
  # * Empty method : Sprite = 
  #-----------------------------------------------------------------------------
  def sprite=(spr)
  end
  
end

#===============================================================================
# ** Game_Event
#===============================================================================

class Game_Event
  #-----------------------------------------------------------------------------
  # * Never refesh flag
  #-----------------------------------------------------------------------------
  attr_reader :never_refresh
  #-----------------------------------------------------------------------------
  # * Alias method : Initialize
  #-----------------------------------------------------------------------------
  alias theo_antilag_init initialize
  def initialize(map_id, event)
    theo_antilag_init(map_id, event)
    $game_map.table.set(x,y,self)
    @last_x = @x
    @last_y = @y
  end
  #-----------------------------------------------------------------------------
  # * Alias method : Update
  #-----------------------------------------------------------------------------
  alias theo_antilag_update update
  def update
    if (sprite && sprite.disposed?) || sprite.nil?
      SceneManager.scene.spriteset.add_sprite(self)
    end
    theo_antilag_update
    if Theo::AntiLag::Optimize_XY && (@last_x != @x || @last_y != @y)
      $game_map.table.get(@last_x, @last_y).delete(self)
      $game_map.table.set(@x,@y,self)
      @last_x = @x
      @last_y = @y
    end
  end
  #-----------------------------------------------------------------------------
  # * Alias method : Start
  #-----------------------------------------------------------------------------
  alias theo_antilag_start start
  def start
    theo_antilag_start
    return unless Theo::AntiLag::Optimize_Event
    $game_map.starting_events << self if @starting
  end
  #-----------------------------------------------------------------------------
  # * Alias method : Clear starting flag
  #-----------------------------------------------------------------------------
  alias theo_antilag_clear_start clear_starting_flag
  def clear_starting_flag
    theo_antilag_clear_start
    return unless Theo::AntiLag::Optimize_Event
    $game_map.starting_events.delete(self)
  end
  #-----------------------------------------------------------------------------
  # * Alias method : Setup page setting
  #-----------------------------------------------------------------------------
  alias theo_antilag_setup_page_settings setup_page_settings
  def setup_page_settings
    theo_antilag_setup_page_settings
    if @event.pages.size == 1 && no_condition?(@event.pages[0].condition)
      @never_refresh = true
    end
    if @trigger == 3 || @interpreter
      $game_map.keep_update_events << self
      $game_map.keep_update_events.uniq!
    else
      $game_map.keep_update_events.delete(self)
    end
  end
  #-----------------------------------------------------------------------------
  # * Check if the events has no page condition
  #-----------------------------------------------------------------------------
  def no_condition?(page)
    !page.switch1_valid && !page.switch2_valid && !page.variable_valid &&
      !page.self_switch_valid && !page.item_valid && !page.actor_valid
  end
  #-----------------------------------------------------------------------------
  # * Delete sprite
  #-----------------------------------------------------------------------------
  def delete_sprite
    SceneManager.scene.spriteset.delete_sprite(sprite)
  end
  #-----------------------------------------------------------------------------
  # * Overwrite method : Force move route
  #-----------------------------------------------------------------------------
  def force_move_route(move_route)
    super
    $game_map.forced_update_events << self
    $game_map.forced_update_events.uniq!
  end
  #-----------------------------------------------------------------------------
  # * Overwrite method : Restore move route
  #-----------------------------------------------------------------------------
  def restore_move_route
    super
    $game_map.forced_update_events.delete(self)
  end
  #-----------------------------------------------------------------------------
  # * Overwrite method : Sprite
  #-----------------------------------------------------------------------------
  def sprite
    $game_temp.event_sprites[@id]
  end
  #-----------------------------------------------------------------------------
  # * Overwrite method : Sprite =
  #-----------------------------------------------------------------------------
  def sprite=(spr)
    $game_temp.event_sprites[@id] = spr
  end
  
end

#===============================================================================
# ** Sprite Character
#===============================================================================

class Sprite_Character
  #-----------------------------------------------------------------------------
  # * Alias method : Initialize
  #-----------------------------------------------------------------------------
  alias theo_antilag_init initialize
  def initialize(viewport, character = nil)
    character.sprite = self if character
    @sx = character.screen_x
    @sy = character.screen_y
    theo_antilag_init(viewport, character)
  end
  #-----------------------------------------------------------------------------
  # * Alias method : Update
  #-----------------------------------------------------------------------------
  alias theo_antilag_update update
  def update
    last_x = @sx
    last_y = @sy
    @sx = @character.screen_x
    @sy = @character.screen_y
    if Theo::AntiLag::Optimize_Sprite && !need_update?
      self.visible = false
      return
    end  
    theo_antilag_update
  end
  #-----------------------------------------------------------------------------
  # * New method : Determine if on screen
  #-----------------------------------------------------------------------------
  def need_update?
    return true if graphic_changed?
    return true if @character.animation_id > 0
    return true if @balloon_sprite
    return true if @character.balloon_id != 0
    w = Graphics.width
    h = Graphics.height
    cw = @cw || 32
    ch = @ch || 32
    @sx.between?(-cw,w+cw) && @sy.between?(0,h+ch)
  end
  #-----------------------------------------------------------------------------
  # * Overwrite update position.
  # To limit screen_x and screen_y to be called many times
  #-----------------------------------------------------------------------------
  def update_position
    move_animation(@sx - x, @sy - y)
    self.x = @sx
    self.y = @sy
    self.z = @character.screen_z
  end
  #-----------------------------------------------------------------------------
  # * Overwrite animation origin
  # Since X and Y axis of sprite is not updated when off screen
  #-----------------------------------------------------------------------------
  def set_animation_origin
    if @animation.position == 3
      if viewport == nil
        @ani_ox = Graphics.width / 2
        @ani_oy = Graphics.height / 2
      else
        @ani_ox = viewport.rect.width / 2
        @ani_oy = viewport.rect.height / 2
      end
    else
      @ani_ox = @sx - ox + width / 2
      @ani_oy = @sy - oy + height / 2
      if @animation.position == 0
        @ani_oy -= height / 2
      elsif @animation.position == 2
        @ani_oy += height / 2
      end
    end
  end
  
end

#===============================================================================
# ** Spriteset_Map
#===============================================================================

class Spriteset_Map
  #-----------------------------------------------------------------------------
  # * Alias method : create character
  #-----------------------------------------------------------------------------
  alias theo_antilag_create_characters create_characters
  def create_characters
    $game_map.event_redirect = Theo::AntiLag::Dispose_Sprite
    theo_antilag_create_characters
    $game_map.event_redirect = false
  end
  #-----------------------------------------------------------------------------
  # * New method : delete sprite
  #-----------------------------------------------------------------------------
  def delete_sprite(spr)
    return unless spr
    return if spr.disposed?
    @character_sprites.delete(spr)
    spr.dispose
  end
  #-----------------------------------------------------------------------------
  # * New method : add sprite
  #-----------------------------------------------------------------------------
  def add_sprite(char)
    spr = Sprite_Character.new(@viewport1, char)
    @character_sprites.push(spr)
  end
  
end

#===============================================================================
# ** Scene_Map
#===============================================================================

class Scene_Map
  attr_reader :spriteset
end
