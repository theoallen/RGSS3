# Too lazy to write instruction
# For more information, visit this thread instead:
# https://forums.rpgmakerweb.com/index.php?threads/is-there-a-way-to-auto-generate-a-map-from-a-black-white-image.157071/

# -----------------------------------------------------------------------------
# Terms of Use?
# Do whatever you want with this script tbh.
# But if you claimed that you made this script. You're a horrible person and 
# you need to check your mental health immediately.
# -----------------------------------------------------------------------------
# - TheoAllen

module Theo
  module MapGen
    LandTileID = 16
    WaterTileID = 0
    
    # (R,G,B, Alpha)
    LandColorCheck = Color.new(0,0,0,255)
    WaterColorCheck = Color.new(0,0,0,0)
    
    # Run the game in the intended map.
    # Game will save the map to the file.
    # Then close and reopen the game.
    # Enjoy your generated map
    AutoSave = true
    
  end
end

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

class Game_Map

  alias theo_mapgen_setup setup
  def setup(map_id)
    theo_mapgen_setup(map_id)
    theo_generate_map
  end
  
  def theo_generate_map
    if @map.note[/<gen\s*:\s*(.+)>/i]
      ref = Cache.system($1.to_s)
      # Assign tiles
      width.times do |w|
        height.times do |h|
          color = ref.get_pixel(w, h) 
          if color == Theo::MapGen::WaterColorCheck
            data[w,h,0] = 2048 + Theo::MapGen::WaterTileID * 48
          elsif color == Theo::MapGen::LandColorCheck
            data[w,h,0] = 2048 + Theo::MapGen::LandTileID * 48
          end
        end
      end      
      
      # Smoothen the edge
      width.times do |w|
        height.times do |h|
          if (data[w,h,0] - 2048) / 48 == Theo::MapGen::WaterTileID  
            data[w,h,0] = AutoTile.new(w,h,data[w,h,0],data,0).sub_id + 2048 +
              48*Theo::MapGen::WaterTileID
          elsif (data[w,h,0] - 2048) / 48 == Theo::MapGen::LandTileID  
            data[w,h,0] = AutoTile.new(w,h,data[w,h,0],data,0).sub_id + 2048 +
              48*Theo::MapGen::LandTileID
          end
        end
      end
      
      if Theo::MapGen::AutoSave
        save_data(@map, sprintf("Data/Map%03d.rvdata2", @map_id))
        p "map #{sprintf("Data/Map%03d.rvdata2", @map_id)} has been saved."
        p "Please reload"
      end
    end
  end
  
end
