#==============================================================================
# Usage:
# Script call
# > Scout.new(start_x, start_y, tile_id, [max_depth])
#
# Example:
# > Scout.new(1,1,2816)
#==============================================================================
class AutoTile
  attr_reader :neighbor
  #---------------------------------
  # Toggle Rules
  #---------------------------------
  # > -1 : Doesn't matter
  # > 0  : Not present
  # > 1  : Present
  #---------------------------------
  def initialize(x, y, id, data = $game_map.data, layer = 0)
    @neighbor = {
      1 => -1, # Bottom Left
      2 => -1, # Bottom
      3 => -1, # Bottom Right
      
      4 => -1, # Left
      6 => -1, # Right
      
      7 => -1, # Top Left
      8 => -1, # Top 
      9 => -1, # Top Right
    }
    @tile_id = id
    @data = data
    @layer = layer
    @x = x
    @y = y
    check_neighbor
  end
  
  def dir_x(d)
    case d
    when 1,4,7
      return @x - 1
    when 3,6,9
      return @x + 1
    else
      return @x
    end
  end
  
  def dir_y(d)
    case d
    when 1,2,3
      return @y + 1
    when 7,8,9
      return @y - 1
    else
      return @y
    end
  end
  
  def check_neighbor
    [2,4,6,8].each do |d|
      @neighbor[d] = check_next(d)
    end
    # Bottom Left
    if @neighbor[2]==1 && @neighbor[4]==1
      @neighbor[1] = check_next(1)
    end
    # Bottom Right
    if @neighbor[2]==1 && @neighbor[6]==1
      @neighbor[3] = check_next(3)
    end
    # Top Left
    if @neighbor[8]==1 && @neighbor[4]==1
      @neighbor[7] = check_next(7)
    end
    # Top Left
    if @neighbor[8]==1 && @neighbor[6]==1
      @neighbor[9] = check_next(9)
    end
  end
  
  def check_next(d)
    return 1 if @data[dir_x(d), dir_y(d), @layer] == nil
    if (@data[dir_x(d), dir_y(d), @layer] - 2048)/48 == real_id
      return 1
    else
      return 0
    end
  end
  
  def sub_id
    # Directions:
    # [7,8,9]
    # [4,5,6]
    # [1,2,3]
    case @neighbor.values
    # Directions (-1: Doesnt matter | 0: Not exist | 1: Exist)
    # At:[ 1, 2, 3, 4, 6, 7, 8, 9]
    when [-1, 0,-1, 0, 0,-1, 0,-1]; return 47
    when [-1, 0,-1, 1, 0,-1, 0,-1]; return 45
    when [-1, 0,-1, 0, 0,-1, 1,-1]; return 44
    when [-1, 0,-1, 0, 1,-1, 0,-1]; return 43
    when [-1, 1,-1, 0, 0,-1, 0,-1]; return 42
    when [-1, 0,-1, 0, 1,-1, 1, 0]; return 41
    when [-1, 0,-1, 0, 1,-1, 1, 1]; return 40
    when [-1, 0,-1, 1, 0, 0, 1,-1]; return 39
    when [-1, 0,-1, 1, 0, 1, 1,-1]; return 38
    when [ 0, 1,-1, 1, 0,-1, 0,-1]; return 37
    when [ 1, 1,-1, 1, 0,-1, 0,-1]; return 36
    when [-1, 1, 0, 0, 1,-1, 0,-1]; return 35
    when [-1, 1, 1, 0, 1,-1, 0,-1]; return 34     
    when [-1, 0,-1, 1, 1,-1, 0,-1]; return 33
    when [-1, 1,-1, 0, 0,-1, 1,-1]; return 32
    when [-1, 0,-1, 1, 1, 0, 1, 0]; return 31
    when [-1, 0,-1, 1, 1, 1, 1, 0]; return 30
    when [-1, 0,-1, 1, 1, 0, 1, 1]; return 29
    when [-1, 0,-1, 1, 1, 1, 1, 1]; return 28
    when [ 0, 1,-1, 1, 0, 0, 1,-1]; return 27
    when [ 1, 1,-1, 1, 0, 0, 1,-1]; return 26
    when [ 0, 1,-1, 1, 0, 1, 1,-1]; return 25
    when [ 1, 1,-1, 1, 0, 1, 1,-1]; return 24
    when [ 0, 1, 0, 1, 1,-1, 0,-1]; return 23  
    when [ 0, 1, 1, 1, 1,-1, 0,-1]; return 22
    when [ 1, 1, 0, 1, 1,-1, 0,-1]; return 21
    when [ 1, 1, 1, 1, 1,-1, 0,-1]; return 20
    when [-1, 1, 0, 0, 1,-1, 1, 0]; return 19
    when [-1, 1, 0, 0, 1,-1, 1, 1]; return 18
    when [-1, 1, 1, 0, 1,-1, 1, 0]; return 17
    when [-1, 1, 1, 0, 1,-1, 1, 1]; return 16  
    when [ 0, 1, 0, 1, 1, 0, 1, 0]; return 15
    when [ 0, 1, 0, 1, 1, 1, 1, 0]; return 14
    when [ 0, 1, 0, 1, 1, 0, 1, 1]; return 13
    when [ 0, 1, 0, 1, 1, 1, 1, 1]; return 12
    when [ 0, 1, 1, 1, 1, 0, 1, 0]; return 11
    when [ 0, 1, 1, 1, 1, 1, 1, 0]; return 10
    when [ 0, 1, 1, 1, 1, 0, 1, 1]; return 9
    when [ 0, 1, 1, 1, 1, 1, 1, 1]; return 8
    when [ 1, 1, 0, 1, 1, 0, 1, 0]; return 7
    when [ 1, 1, 0, 1, 1, 1, 1, 0]; return 6
    when [ 1, 1, 0, 1, 1, 0, 1, 1]; return 5
    when [ 1, 1, 0, 1, 1, 1, 1, 1]; return 4
    when [ 1, 1, 1, 1, 1, 0, 1, 0]; return 3
    when [ 1, 1, 1, 1, 1, 1, 1, 0]; return 2
    when [ 1, 1, 1, 1, 1, 0, 1, 1]; return 1
    when [ 1, 1, 1, 1, 1, 1, 1, 1]; return 0
    else
      return 0
    end
  end
  
  def real_id
    (@tile_id - 2048) / 48
  end
  
  def practical_id
    return @tile_id if @tile_id < 2048
    real_id * 48 + sub_id + 2048
  end
  
end
class MazeNode
  attr_accessor :parent
  attr_accessor :cleared
  attr_accessor :depth
  attr_reader :x
  attr_reader :y
  
  def initialize(x,y)
    @x = x
    @y = y
    @depth = 0
  end
  
  def edge?
    return x == 0 || y == 0 || 
      x == $game_map.width-1 || y == $game_map.height-1
  end
  
  def expand
    expandir = [
      "#{x},#{y+1}",
      "#{x},#{y-1}",
      "#{x+1},#{y}",
      "#{x-1},#{y}",
    ].shuffle
    expandir.each do |dir|
      nextnode = $mazenode[dir]
      return nextnode if nextnode && nextnode.clear(self)
    end
    return self
  end
  
  def clearable?
    return false if cleared
    return false if edge?
    return @clearable unless @clearable.nil? # Optimization
    result = true
    
    # Binary operation
    bin = 0
    
    # Directional binary assignment. 
    # Check if neighbor node is cleared/visited
    bin += 1 if $mazenode.get(x-1,y+1).cleared    # 00000001 > Kiara
    bin += 2 if $mazenode.get(x  ,y+1).cleared    # 00000010 > Bottom
    bin += 4 if $mazenode.get(x+1,y+1).cleared    # 00000100 > Bottom right
    bin += 8 if $mazenode.get(x-1,y).cleared      # 00001000 > Left
      
    bin += 16 if $mazenode.get(x+1,y).cleared     # 00010000 > Right
    bin += 32 if $mazenode.get(x-1,y-1).cleared   # 00100000 > Top left
    bin += 64 if $mazenode.get(x  ,y-1).cleared   # 01000000 > Top
    bin += 128 if $mazenode.get(x+1,y-1).cleared  # 10000000 > Top Right
    
    if bin & 2 > 0
      result = bin & 248 == 0 # 11111000
    elsif bin & 8 > 0
      result = bin & 214 == 0 # 11010110
    elsif bin & 16 > 0
      result = bin & 107 == 0 # 01101011
    elsif bin & 64 > 0
      result = bin & 31 == 0 # 00011111
    end
    unless @result
      @clearable = result
    end
    return result
  end
  
  def clear(parent)
    return false unless clearable?
    self.parent = parent
    self.cleared = true
    self.depth = parent.depth + 1 if parent
    if $scout && $scout.deepest && $scout.deepest.depth < self.depth
      $scout.deepest = self
    end
    place_tile(x,y)
    return true
  end
  
  def place_tile(x,y)
    $game_map.data[x,y,0] = $scout.autotile_id#2816
  end
  
end

class MazeNodes
  
  def initialize
    @nodes = {}
  end
  
  def [](position)
    if position =~ /(\d+),(\d+)/i
      x = $1.to_i
      y = $2.to_i      
      return @nodes[position] ||= MazeNode.new(x,y)
    end
    return nil
  end
  
  def get(x,y)
    return self["#{x},#{y}"]
  end
  
end

class Scout 
  attr_accessor :deepest
  attr_accessor :autotile_id
  
  def initialize(x, y, autotile_id, max_depth = 70)
    $mazenode = MazeNodes.new
    $scout = self
    @autotile_id = autotile_id
    @max_depth = max_depth
    @start = $mazenode.get(x,y)
    @start.clear(nil)
    @explor_node = @start.expand
    @deepest = @explor_node
    @state = :explor
    update until done?
  end
  
  def explor
    nextnode = @explor_node.expand
    if nextnode == @explor_node
      @state = :backtrace
    else
      @explor_node = nextnode
    end
    if done?
      end_explor
    end
  end
  
  def backtrace
    return unless @explor_node
    nextnode = @explor_node.expand
    if nextnode != @explor_node
      @state = :explor
      @explor_node = nextnode
    else
      @explor_node = @explor_node.parent
    end
    if done?
      end_explor
    end
  end
  
  def end_explor
    $game_map.width.times do |i|
      $game_map.height.times do |y|
        id = $game_map.data[i, y, 0]
        $game_map.data[i, y, 0] = AutoTile.new(i, y, id).practical_id
      end
    end
  end
  
  def update
    return if done?
    if @state == :explor
      explor
    elsif @state == :backtrace
      backtrace
    end
  end
  
  def done?
    @start == @explor_node || @explor_node.depth == @max_depth
  end
  
end
