#===============================================================================
# TheoAllen - Fog of War
# Requested by : Zero0018
# Last edited : 15.01.2015
#-------------------------------------------------------------------------------
# How to use :
# Put the script below materials but above main
# No external resource is required
#
#------------------------------------------------------------------------------
# ** MAP NOTETAG :
#------------------------------------------------------------------------------
# To show fog in map, simply put <fog> in map note
# To hide fog in map, simply put <no fog> in map note
#
# Set the default of showing fog in configuration
#
#------------------------------------------------------------------------------
# ** SCRIPT CALL :
#------------------------------------------------------------------------------
#
# $game_map.reveal_tiles(x, y)
# $game_map.reveal_tiles(x, y, distance)
# Will reveal tiles in x,y within the distance. If distance is ommited, it will
# be same as the VisiRange in script setting
#
# $game_map.events[event_id].reveal_tiles
# $game_map.events[event_id].reveal_tiles(distance
# Will reveal tiles from the event location within the distance. If distance is
# ommited, it will be same as the VisiRange in script setting
#
#-------------------------------------------------------------------------------
# Configuration
#===============================================================================
module Theo
  
  VisiRange   = 4
# Visibility range of the character. Larger value, longer distance

  FogOpacity  = 255
# Fog opacity. Set 255 for full opacity.

  DefaultFog  = true
# If set to true, every map will has fog. Unless you put <no fog>
# If set to false, every map will has no fog. Unless you put <fog>

end
#===============================================================================
# End of config
#===============================================================================

#===============================================================================
# ** Bitmap
#===============================================================================

class Bitmap
  
  # Fill entire bitmap with color
  def entire_fill(color = Color.new(0,0,0,150))
    fill_rect(self.rect,color)
  end
  
end

#===============================================================================
# ** Fog of War
#===============================================================================

class Fog_of_War < Plane
  @@bitmap_cache = {}
  #----------------------------------------------------------------------------
  # * Initialize
  #----------------------------------------------------------------------------
  def initialize(vport)
    super(vport)
    @id = -1
  end
  
  #----------------------------------------------------------------------------
  # * Update
  #----------------------------------------------------------------------------
  def update
    if $game_map
      if @id != $game_map.map_id
        @id = $game_map.map_id
        @width = $game_map.width
        @height = $game_map.height
        update_bitmap
      end
      self.ox = $game_map.display_x * 32
      self.oy = $game_map.display_y * 32
      self.visible = !$game_map.no_fog?
    end
  end
  
  #----------------------------------------------------------------------------
  # * Update bitmap
  #----------------------------------------------------------------------------
  def update_bitmap
    bmp = @@bitmap_cache[@id]
    unless bmp && !bmp.disposed?
      bmp = Bitmap.new(@width * 32, @height * 32)
      @@bitmap_cache[@id] = bmp
    end
    self.bitmap = bmp
    return if $game_map.no_fog?
    bitmap.entire_fill(Color.new(0,0,0,Theo::FogOpacity))
    reveal_tiles($game_system.revealed_tiles)
    reveal_tiles($game_player.reveal_tiles)
  end
  
  #----------------------------------------------------------------------------
  # * Reveal Tiles
  #----------------------------------------------------------------------------
  def reveal_tiles(tiles)
    tiles.each do |pos|
      x = pos.x * 32
      y = pos.y * 32
      bitmap.clear_rect(x,y,32,32)
    end unless disposed?
  end
  
end

#===============================================================================
# ** Game_System
#===============================================================================

class Game_System
  #----------------------------------------------------------------------------
  # * Revealed tiles
  #----------------------------------------------------------------------------
  def revealed_tiles
    @revealed_map ||= {}
    @revealed_map[$game_map.map_id] ||= []
    @revealed_map[$game_map.map_id]
  end
  
  #----------------------------------------------------------------------------
  # * Revealed tiles =
  #----------------------------------------------------------------------------
  def revealed_tiles=(t)
    @revealed_map ||= {}
    @revealed_map[$game_map.map_id] = t
  end
  
end

#===============================================================================
# ** Revealed Node
#===============================================================================

class Revealed_Node
  #----------------------------------------------------------------------------
  # * Public attributes
  #----------------------------------------------------------------------------
  attr_accessor :parent   
  attr_accessor :visited
  attr_accessor :x
  attr_accessor :y
  attr_reader :expanded 
  attr_reader :nodes
  
  #----------------------------------------------------------------------------
  # * Initialize
  #----------------------------------------------------------------------------
  def initialize(x,y)
    @x ,@y = x, y
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
      xpos = $game_map.round_x_with_direction(@x, d)
      ypos = $game_map.round_y_with_direction(@y, d)
      key = [xpos, ypos]
      next_node = mapnodes[key]
      if next_node.nil?
        next_node = Revealed_Node.new(xpos, ypos)
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
  #----------------------------------------------------------------------------
  # * No fog?
  #----------------------------------------------------------------------------
  def no_fog?
    return false unless @map
    return true if @map.note[/<no[\s_]+fog>/i]
    return false if @map.note[/<fog>/i]
    return !Theo::DefaultFog
  end
  #----------------------------------------------------------------------------
  # * Reveal tiles
  #----------------------------------------------------------------------------
  def reveal_tiles(x, y, distance = Theo::VisiRange, reveal = true)
    return if no_fog?
    # Initialize
    @revealed_nodes = {}
    @max_distance = distance - 1
    @init_x = x
    @init_y = y
    
    # Make first node to check
    first_node = Revealed_Node.new(x, y)
    first_node.expand_node(@revealed_nodes, self)
    first_node.visited = true
    @revealed_nodes[[x, y]] = first_node
    @reveal_queue = []
    @reveal_queue.push(first_node)
    
    # spread search using BFS
    until @reveal_queue.empty?
      spread_search(@reveal_queue.shift)
    end
    
    node_to_reveal = @revealed_nodes.values - $game_system.revealed_tiles
    sprset = SceneManager.scene.spriteset
    sprset.fogofwar.reveal_tiles(node_to_reveal) if sprset
    $game_system.revealed_tiles += @revealed_nodes.values
  end
  
  #----------------------------------------------------------------------------
  # * Spread search
  #----------------------------------------------------------------------------
  def spread_search(node)
    dir = [2,4,6,8]
    dir.shuffle.each do |d|
      next_node = node.nodes[d]
      next unless next_node
      next if next_node.visited
      next if get_distance(next_node) > @max_distance
      next_node.expand_node(@revealed_nodes, self) unless next_node.expanded
      next_node.visited = true
      @reveal_queue.push(next_node, node)
    end
  end
  
  #----------------------------------------------------------------------------
  # * Get distance
  #----------------------------------------------------------------------------
  def get_distance(node)
    range_x = node.x - @init_x
    range_y = node.y - @init_y
    result =  Math.sqrt((range_x**2) + (range_y**2))
    return result
  end
  
end
#===============================================================================
# ** Game_Character
#===============================================================================
class Game_Character
  #----------------------------------------------------------------------------
  # * Reveal tiles
  #----------------------------------------------------------------------------
  def reveal_tiles(distance = Theo::VisiRange)
    $game_map.reveal_tiles(x, y, distance)
  end
  
end

#===============================================================================
# ** Game_Player
#===============================================================================
class Game_Player
  #----------------------------------------------------------------------------
  # * Increase step
  #----------------------------------------------------------------------------
  alias theo_fogofwar_increase_steps increase_steps
  def increase_steps
    theo_fogofwar_increase_steps
    reveal_tiles
  end
  
end

#===============================================================================
# ** Spriteset_Map
#===============================================================================

class Spriteset_Map
  #----------------------------------------------------------------------------
  # * Attribute Reader
  #----------------------------------------------------------------------------
  attr_reader :fogofwar
  
  #----------------------------------------------------------------------------
  # * Create viewports (alias)
  #----------------------------------------------------------------------------
  alias theo_fogofwar_create_viewports create_viewports 
  def create_viewports 
    theo_fogofwar_create_viewports
    create_fogofwar
  end
  
  #----------------------------------------------------------------------------
  # * Create fog of war
  #----------------------------------------------------------------------------
  def create_fogofwar
    @fogofwar = Fog_of_War.new(@viewport1)
    @fogofwar.z = 210
  end
  
  #----------------------------------------------------------------------------
  # * Update (alias)
  #----------------------------------------------------------------------------
  alias theo_fogofwar_update update
  def update
    theo_fogofwar_update
    @fogofwar.update
  end
  
  #----------------------------------------------------------------------------
  # * Dispose (alias)
  #----------------------------------------------------------------------------
  alias theo_fogofwar_dispose dispose
  def dispose
    theo_fogofwar_dispose
    @fogofwar.dispose
  end
  
end

#===============================================================================
# ** Scene_Base
#===============================================================================

class Scene_Base
  attr_reader :spriteset
end
