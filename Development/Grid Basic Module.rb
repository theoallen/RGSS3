#===============================================================================
# TheoAllen - Grid Basic Module 
# > For grid battle system
#===============================================================================

module Grid
  MaxRow = 3
  MaxCol = 8
  
  #-----------------------------------------------------------------------------
  # Position based on index
  #-----------------------------------------------------------------------------
  Position = 
[
[ 88,152],[140,152],[192,152],[246,152],[300,152],[352,152],[406,152],[460,152],
[ 77,174],[132,174],[188,174],[244,174],[302,174],[356,174],[414,174],[471,174],
[ 66,196],[126,192],[184,196],[242,196],[304,196],[360,196],[422,196],[482,196]
]
  
end

#===============================================================================
# * Grid Counting Module
#===============================================================================

class << Grid
  #----------------------------------------------------------------------------
  # * Grid direction rules
  #----------------------------------------------------------------------------
  # 2 = DOWNWARD
  # 4 = FORWARD
  # 6 = BACKWARD
  # 8 = UPWARD
  #
  # 1 = DOWN-LEFT
  # 3 = DOWN-RIGHT
  # 7 = UP-LEFT
  # 9 = UP-RIGHT
  #----------------------------------------------------------------------------
  # * Get neighbor grid
  #----------------------------------------------------------------------------
  def neighbor(index, dir, times = 1)
    if times > 1
      index = neighbor(index, dir, times - 1)
    end
    return nil unless index
    coordinate = index
    coordinate = point(index) unless index.is_a?(Array)
    case dir
    when 2; coordinate[1] += 1  # DOWN
    when 4; coordinate[0] -= 1  # FORWARD
    when 6; coordinate[0] += 1  # BACKWARD
    when 8; coordinate[1] -= 1  # UP
      
    # Diagonal direction
    when 1
      coordinate[0] -= 1
      coordinate[1] += 1
    when 3
      coordinate[0] += 1
      coordinate[1] += 1
    when 7
      coordinate[0] -= 1
      coordinate[1] -= 1
    when 9
      coordinate[0] += 1
      coordinate[1] -= 1
    end
    return cell(*coordinate)
  end
  
  #-----------------------------------------------------------------------------
  # Translate point coordinate [x,y] into Cell Index
  # > Column equal as X axis
  # > Row equal as Y axis
  #-----------------------------------------------------------------------------
  def cell(col, row)
    return nil if out_of_bound?(row, 0, Grid::MaxRow - 1)
    return nil if out_of_bound?(col, 0, Grid::MaxCol - 1)
    return (Grid::MaxCol * row) + col
  end
  
  #-----------------------------------------------------------------------------
  # * Translate cell index into point [x,y]
  #-----------------------------------------------------------------------------
  def point(index)
    return [index % Grid::MaxCol, index / Grid::MaxCol]
  end
  
  #-----------------------------------------------------------------------------
  # * Simply check if the value is out of bound
  #-----------------------------------------------------------------------------
  def out_of_bound?(value, min, max)
    return value > max || value < min
  end
  
  #-----------------------------------------------------------------------------
  # * Max Index
  #-----------------------------------------------------------------------------
  def max_index
    Grid::MaxRow * Grid::MaxCol
  end
  
  #-----------------------------------------------------------------------------
  #                           TARGETING PART!
  #-----------------------------------------------------------------------------
  # * Surrounding grid
  #-----------------------------------------------------------------------------
  def surrounding(index, directions = Grid::Movement, compact = true)
    result = directions.collect {|dir| neighbor(index, dir)} + [index]
    return result.compact.uniq if compact
    return result.uniq
  end
  
  #-----------------------------------------------------------------------------
  # * Spread search. Expand node using BFS iteration
  #-----------------------------------------------------------------------------
  def spread(index, directions = Grid::Movement,limit = 1,compact = true)
    return [] unless index
    return [] if limit < 0
    i = 0
    result = [index]
    iteration = [index]
    until i == limit
      temp_res = []
      iteration.each do |it| 
        cells = surrounding(it, directions, compact)
        cells.delete_if {|c| result.include?(c)}
        temp_res += cells
      end
      temp_res.uniq!
      iteration = temp_res
      result += temp_res
      i += 1
    end
    return result.compact.uniq if compact
    return result.uniq
  end
  
  #-----------------------------------------------------------------------------
  # * Linear repeated search
  #-----------------------------------------------------------------------------
  def linear(index, directions = Grid::Movement,limit = 1,compact = true)
    result = []
    directions.each do |dir|
      result += spread(index, [dir], limit, compact)
    end
    return result.uniq
  end
  
  #-----------------------------------------------------------------------------
  # * Random grid drop
  #-----------------------------------------------------------------------------
  def random_grid(index = nil)
    return rand(max_index) unless index
    result = nil
    result = rand(max_index) until result != index
    return result
  end
  
  #-----------------------------------------------------------------------------
  # * Horizontal line
  #-----------------------------------------------------------------------------
  def horizontal(index, limit = Grid::MaxCol)
    linear(index, [4,6], limit)
  end
  
  #-----------------------------------------------------------------------------
  # * Vertical line
  #-----------------------------------------------------------------------------
  def vertical(index, limit = Grid::MaxRow)
    linear(index, [2,8], limit)
  end
  #-----------------------------------------------------------------------------
  # * Eight direction spread
  #-----------------------------------------------------------------------------
  def dir8(index, limit = 1)
    spread(index, [1,2,3,4,6,7,8,9], limit)
  end
  
  #-----------------------------------------------------------------------------
  # * Four direction spread
  #-----------------------------------------------------------------------------
  def dir4(index, limit = 1)
    spread(index, [2,4,6,8], limit)
  end
  
  #-----------------------------------------------------------------------------
  # * Cross shaped area
  #-----------------------------------------------------------------------------
  def cross_shape(index, limit = 1)
    linear(index, [1,3,7,9], limit)
  end
  
  #-----------------------------------------------------------------------------
  # * Plus shaped area
  #-----------------------------------------------------------------------------
  def plus_shape(index, limit = 1)
    linear(index, [2,4,6,8], limit)
  end
  
  #-----------------------------------------------------------------------------
  # * All area
  #-----------------------------------------------------------------------------
  def all_area
    Array.new(Grid::MaxRow * Grid::MaxCol) {|i| i }
  end
  
end
