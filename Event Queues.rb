#===============================================================================
# TheoAllen - Event Queues (Formerly named "Event Trigger There")
# Version : 1.0
# Contact : Discord @ Theo#3034
#===============================================================================
($imported ||= {})[:Theo_EventTriggerThere] = true
#===============================================================================
# Change Logs:
# ------------------------------------------------------------------------------
# 2019.01.21 - Translated
# 2013.11.23 - Finished
#===============================================================================
=begin

  ==================
  *) Introduction :
  ------------------
  This script will queue an event once the event that is currently running
  is done.
  
  For example if the currently running event ID is 2, and you want the next
  event is 3 once the event 2 is done. It will be automatically without need
  of the player input.
  
  =====================
  *) How to use :
  ---------------------
  Put the script under material
  Use this script to queue the events
  
  $game_map.events_queue << event_id
  
  If you use it like this
  $game_map.events_queue << 1
  $game_map.events_queue << 2
  $game_map.events_queue << 3
  
  The event will be executed in the order of 1,2,3 consecutively
  
  ===================
  *) Terms of use ||
  -------------------
  Credit me, TheoAllen. You are free to edit this script by your own. As long 
  as you don't claim it's yours. For commercial purpose, don't forget to give me
  a free copy of the game.

=end
#===============================================================================
# ** Game_Map
#===============================================================================
class Game_Map
  #-----------------------------------------------------------------------------
  # * Attributes reader
  #-----------------------------------------------------------------------------
  attr_reader :force_event
  attr_reader :events_queue
  #-----------------------------------------------------------------------------
  # * Initialize
  #-----------------------------------------------------------------------------
  alias theo_event_there_init initialize
  def initialize
    @events_queue = []
    @force_event = -1
    theo_event_there_init
  end
  #-----------------------------------------------------------------------------
  # * Next Event
  #-----------------------------------------------------------------------------
  def next_event
    @force_event = @events_queue.shift || -1
  end
  #-----------------------------------------------------------------------------
  # * Update
  #-----------------------------------------------------------------------------
  alias theo_event_there_update update
  def update(main = false)
    theo_event_there_update(main)
    if !@events_queue.empty? && @force_event == -1
      next_event
    end
  end
  
end
#===============================================================================
# ** Game_Event
#===============================================================================
class Game_Event
  #-----------------------------------------------------------------------------
  # * Starting
  #-----------------------------------------------------------------------------
  alias theo_event_there_starting starting
  def starting
    theo_event_there_starting || $game_map.force_event == @event.id
  end
  
end
#===============================================================================
# ** Game_Interpreter
#===============================================================================
class Game_Interpreter
  #-----------------------------------------------------------------------------
  # * Setup
  #-----------------------------------------------------------------------------
  alias theo_event_there_setup setup
  def setup(*args)
    theo_event_there_setup(*args)
    if @event_id == $game_map.force_event
      $game_map.next_event
    end
  end
end
