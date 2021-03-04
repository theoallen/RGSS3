class Sprite_Screen < Sprite
  
  def initialize(viewport = nil)
    super(viewport)
    self.bitmap = Bitmap.new(Graphics.width,Graphics.height)
  end
  
  def dispose
    self.bitmap.dispose
    super
  end
  
end

class MazeNode
  Max_X = 20
  Max_Y = 20
  
  SizeX = 5
  SizeY = 5
  
  attr_accessor :parent
  attr_accessor :cleared
  attr_reader :x
  attr_reader :y
  
  def initialize(x,y)
    @x = x
    @y = y
  end
  
  def edge?
    return x == 0 || y == 0 || x == Max_X || y == Max_Y
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
    rect = Rect.new(x*SizeX, y*SizeY, SizeX, SizeY)
    $spr_test.bitmap.fill_rect(rect, Color.new(255,255,255))
    return true
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
  
  def initialize(start, explor)
    @start = start
    @explor_node = explor
    @state = :explor
  end
  
  def explor
    nextnode = @explor_node.expand
    if nextnode == @explor_node
      @state = :backtrace
    else
      @explor_node = nextnode
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
    @start == @explor_node 
  end
  
end
rgss_main do
  $spr_test = Sprite_Screen.new
  $mazenode = MazeNodes.new
  $starting_node = $mazenode.get(1,1)
  $starting_node.clear(nil)
  $explor = $starting_node.expand

  $scout = Scout.new($starting_node, $explor)

  loop do
    Graphics.update
    Input.update
    $spr_test.update
    $scout.update
  end
end
