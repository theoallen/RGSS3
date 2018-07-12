#==============================================================================
# TheoAllen - Pathfinding
# Version : 1.0b
# Language : English
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://forums.rpgmakerweb.com
# *> Discord @ Theo#3034
#==============================================================================
($imported ||= {})[:Theo_Pathfinding] = true
#===============================================================================
# Change Logs:
# ------------------------------------------------------------------------------
# 2018.07.12 - Fixed a game breaking bug where move route overwriting the 
#              original move route from event instead of copy and alter it.
# 2015.01.08 - English translation
# 2015.01.07 - Added A* Pathfinding
#            - Map loop support pathfinding
# 2015.01.06 - Finished
# 2014.05.08 - Initial prototype
#===============================================================================
=begin

  =================================
  *) Introduction :
  ---------------------------------
  This script simply for determine the shortest path from started from a
  character position to target coodrinate.
  
  =================================
  *) How to use :
  ---------------------------------
  Simply put the script below material.
  
  ----------------------
  *) SCRIPT CALL
  ----------------------
  - find_path(x,y)
  Use this script call in set move route. Where (x,y) are the target coordinate.
  If path not found, character won't move.
  
  - goto_event(id)
  Use this script call in set move route. Where id is event id
  
  - goto_player
  Use this script call in set move route to make an event go to the player
  position.
  
  ----------------------
  *) EVENT COMMENT
  ----------------------
  <chase player>.
  Use this tag in event comment to make player chase the event. It behave like
  autonomous movement.
  
  <stop chase>
  script
  </stop chase>
  Use this tag if you want to stop the event from chasing the player. Script
  is a valid ruby script to determine stop condition. For example, if you have
  safe zone marked by region ID 1, you could add comment like this
  
  <stop chase>
  $game_player.region_id == 1
  </stop chase>
  
  =================================
  *) Important notes :
  ---------------------------------
  Chase player is still experimental. There's a chance that there will be
  discovered bugs. This pathfinding is exluce the diagonal movement and only
  support 4 direction at the moment. And there's a chance that it won't work
  in pixel movement as well.
  
  =================================
  *) Terms of use :
  ---------------------------------
  Credit me, TheoAllen. You are free to edit this script by your own. As long 
  as you don't claim it's yours. For commercial purpose, don't forget to give me
  a free copy of the game.

=end
#===============================================================================
# Below this line is sacred place to visit. Unless you have enough skill,
# do not try to enter or any risk is yours.
#===============================================================================

#===============================================================================
# ** Pathfinding Queue
#===============================================================================

class Pathfinding_Queue
  #----------------------------------------------------------------------------
  # * Initialize
  #----------------------------------------------------------------------------
  def initialize(tx, ty, first_node)
    @astar = !$game_map.any_loop?
    @tx = tx
    @ty = ty
    clear
    @front_queue.push(first_node)
    @range_cache = {}
  end
  
  #----------------------------------------------------------------------------
  # * Range
  #----------------------------------------------------------------------------
  def range(node)
    unless @range_cache[node]
      range_x = node.x - @tx
      range_y = node.y - @ty
      @range_cache[node] = Math.sqrt((range_x**2) + (range_y**2))
    end
    return @range_cache[node]
  end
  
  #----------------------------------------------------------------------------
  # * Push
  #----------------------------------------------------------------------------
  def push(new_node, parent_node)
    if @astar && range(new_node) < range(parent_node)
      @front_queue.push(new_node)
      @front_queue.sort! {|a,b| range(a) <=> range(b)}
    else
      @back_queue.push(new_node)
    end
  end
  
  #----------------------------------------------------------------------------
  # * Shift
  #----------------------------------------------------------------------------
  def shift
    result = @front_queue.shift
    return result if result
    return @back_queue.shift
  end
  
  #----------------------------------------------------------------------------
  # * Empty
  #----------------------------------------------------------------------------
  def empty?
    @front_queue.empty? && @back_queue.empty?
  end
  
  #----------------------------------------------------------------------------
  # * Clear
  #----------------------------------------------------------------------------
  def clear
    @front_queue = []
    @back_queue = []
  end
  
end

#===============================================================================
# ** MapNode
#===============================================================================

class MapNode
  #----------------------------------------------------------------------------
  # * Public attributes
  #----------------------------------------------------------------------------
  attr_accessor :parent   
  attr_accessor :visited
  attr_reader :expanded 
  attr_reader :nodes    
  attr_reader :x
  attr_reader :y
  
  #----------------------------------------------------------------------------
  # * Initialize
  #----------------------------------------------------------------------------
  def initialize(x,y)
    @x, @y = x, y
    @nodes = {}
    @visited = false
    @expanded = false
  end
  
  #----------------------------------------------------------------------------
  # * Expand node
  #----------------------------------------------------------------------------
  def expand_node(mapnodes, char)
    dir = [2,4,6,8]
    dir.each do |d|
      next unless char.pathfinding_passable?(@x, @y, d)
      xpos = $game_map.round_x_with_direction(@x, d)
      ypos = $game_map.round_y_with_direction(@y, d)
      key = [xpos, ypos]
      next_node = mapnodes[key]
      if next_node.nil?
        next_node = MapNode.new(xpos, ypos)
        mapnodes[key] = next_node
      elsif next_node.visited
        next
      end
      next_node.parent = self
      self.nodes[d] = next_node
    end
    @expanded = true
  end
  
  #----------------------------------------------------------------------------
  # * Get Parent Direction
  #----------------------------------------------------------------------------
  def get_parent_dir
    parent.nodes.index(self)
  end
  
end

#===============================================================================
# ** Game_Map
#===============================================================================

class Game_Map
  def any_loop?
    loop_horizontal? || loop_vertical?
  end
end

#===============================================================================
# ** Game_Character
#===============================================================================

class Game_Character
  attr_reader :move_route
  attr_reader :move_route_index
  #----------------------------------------------------------------------------
  # * Find path (x, y)
  #   Do not set clear to true in move route script
  #----------------------------------------------------------------------------
  def find_path(tx, ty, clear = false)
    return if x == tx && y == ty
    return unless [2,4,6,8].any? {|dir| passable?(tx, ty, dir)}
    last_code = @move_code || []
    
    # Initialize
    @move_code = nil
    @mapnodes = {}
    @target_findx = tx
    @target_findy = ty
    
    # Make first node to check
    first_node = MapNode.new(self.x, self.y)
    first_node.expand_node(@mapnodes, self)
    first_node.visited = true
    @mapnodes[[self.x, self.y]] = first_node
    @queue = Pathfinding_Queue.new(tx, ty, first_node)
    
    # breadth first seach iteration
    until @queue.empty?
      bfsearch(@queue.shift)
    end
    
    # Execute move code
    if clear
      unless @move_code
        process_route_end
        return
      end
      route = RPG::MoveRoute.new
      route.repeat = false
      route.list = @move_code
      force_move_route(route)
    elsif @move_code
      mv_list = @move_route.list.clone
      insert_index = @move_route_index 
      @move_code.each do |li|
        mv_list.insert(insert_index, li)
        insert_index += 1
      end
      @move_route = copy(@move_route)
      @move_route.list = mv_list
      @move_route_index -= 1 
    end
    @target_findx = @target_findy = nil
  end
  
  #----------------------------------------------------------------------------
  # * Breadth First Search
  #----------------------------------------------------------------------------
  def bfsearch(node)
    dir = [2,4,6,8]
    dir.shuffle.each do |d|
      next_node = node.nodes[d]
      next unless next_node
      next if next_node.visited
      if next_node.x == @target_findx && next_node.y == @target_findy
        @move_code = generate_route(next_node)
        @queue.clear
        return
      end
      next_node.expand_node(@mapnodes, self) unless next_node.expanded
      next_node.visited = true
      @queue.push(next_node, node)
    end
  end
  
  #----------------------------------------------------------------------------
  # * Generate move command list based on node
  #----------------------------------------------------------------------------
  def generate_route(node)
    list = []
    while node.parent
      command = RPG::MoveCommand.new
      command.code = node.get_parent_dir/2
      list.unshift(command)
      node = node.parent
    end
    return list
  end
  
  #----------------------------------------------------------------------------
  # * Chase character
  #----------------------------------------------------------------------------
  def goto_character(char, clear = false)
    return unless char
    find_path(char.x, char.y, clear)
  end
  
  #----------------------------------------------------------------------------
  # * Chase player
  #----------------------------------------------------------------------------
  def goto_player(clear = false)
    goto_character($game_player, clear)
  end
  
  #----------------------------------------------------------------------------
  # * Chase event
  #----------------------------------------------------------------------------
  def goto_event(id, clear = false)
    goto_character($game_map.events[id], clear)
  end
  
  #----------------------------------------------------------------------------
  # * Target point?
  #----------------------------------------------------------------------------
  def target_point?(x, y)
    @target_findx == x && @target_findy == y
  end
  
  #----------------------------------------------------------------------------
  # * Pathfinding Passable?
  #----------------------------------------------------------------------------
  def pathfinding_passable?(x, y, d)
    x2 = $game_map.round_x_with_direction(x, d)
    y2 = $game_map.round_y_with_direction(y, d)
    if target_point?(x2, y2)
      return true if @through
      return map_passable?(x, y, d) && map_passable?(x2, y2, reverse_dir(d))
    end
    passable?(x, y, d)
  end
  
end

#===============================================================================
# ** Game_Event
#===============================================================================

class Game_Event
  #----------------------------------------------------------------------------
  # * Regular expression for chase player
  #----------------------------------------------------------------------------
  REGX_ChasePlayer = /<chase[\s_]player>/i
  REGX_ChaseCondS  = /<stop[\s_]chase>/i
  REGX_ChaseCondE  = /<\/stop[\s_]chase>/i
  
  #----------------------------------------------------------------------------
  # * Alias : Setup page settings
  #----------------------------------------------------------------------------
  alias theo_pathfind_setup_page_settings setup_page_settings
  def setup_page_settings
    theo_pathfind_setup_page_settings
    init_chase_variables
    return unless @list
    load = false
    @list.each do |cmd|
      next unless [108, 408].include?(cmd.code)
      case cmd.parameters[0]
      when REGX_ChasePlayer
        setup_chase($game_player, 45)
      when REGX_ChaseCondS
        load = true
        @chase_condition = ""
        next
      when REGX_ChaseCondE
        load = false
      else 
        if load
          @chase_condition += cmd.parameters[0]
        end
      end
    end
  end
  
  #----------------------------------------------------------------------------
  # * Init chase variables
  #----------------------------------------------------------------------------
  def init_chase_variables
    @target_object = nil
    @path_refresh_rate = 0
    @path_refresh_count = 0
    @chase_condition = "false"
    @player_lastpost = []
  end
  
  #----------------------------------------------------------------------------
  # * Setup chase
  #----------------------------------------------------------------------------
  def setup_chase(char, rate)
    @target_object = char
    @path_refresh_rate = rate
  end
  
  #----------------------------------------------------------------------------
  # * Alias : Update
  #----------------------------------------------------------------------------
  alias theo_pathfind_update update
  def update
    theo_pathfind_update
    return unless @target_object 
    return if $game_map.interpreter.running?
    @path_refresh_count -= 1
    return if @path_refresh_count > 0 || moving? || playerpos_not_changed?
    update_pathfinding
  end
  
  #----------------------------------------------------------------------------
  # * Update pathfinding
  #----------------------------------------------------------------------------
  def update_pathfinding
    @path_refresh_count = @path_refresh_rate
    @player_lastpost = [$game_player.x, $game_player.y]
    unless eval(@chase_condition)        
      goto_character(@target_object, true)
    else
      process_route_end
    end
  end
  
  #----------------------------------------------------------------------------
  # * Player position not changed?
  #----------------------------------------------------------------------------
  def playerpos_not_changed?
    @player_lastpost == [$game_player.x, $game_player.y]
  end
  
end
#===============================================================================
# ** Misc
#===============================================================================
def copy(object)
  Marshal.load(Marshal.dump(object))
end
