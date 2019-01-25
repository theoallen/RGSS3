#==============================================================================
# TheoAllen - Tileset Passability Referencer
# Version : 1.0c
# Contact : Discord @ Theo#3034
#==============================================================================
($imported ||= {})[:Theo_TileflagTemp] = true
#==============================================================================
# Change Logs:
#------------------------------------------------------------------------------
# 2019.01.26 - Added terrain tag
# 2019.01.23 - Added layered tag
# 2019.01.13 - Finished script
#==============================================================================
=begin
  
  -----------------------------------------
  Introduction:
  What if you could setting a passability setting for a tile for once and it
  will be used in all tileset database?
  
  This particular script will record a tileset passability setting based on
  file name. For example if you have set a passability setting for a tileset
  with a file named "Dungeon_B", then all the tileset database that used the 
  same file will follow the same rules
  
  -----------------------------------------
  How to use:
  After you install the script, decide the ID to load in the setting below.
  
  For example, if you put [1,2,3], then it will loads all tilesed ID 1,2, and 3.
  All tile names will be recorded.
  
  -----------------------------------------
  Terms:
  Free for commercial usage.
  
=end
#==============================================================================
# End of instruction
#==============================================================================
module AED
  module Tiles
    List = {}
    LoadID = [14,15,16,17] # <-- Load these tilesets as template (based on ID)
    
    tileset = load_data("Data/Tilesets.rvdata2")
    LoadID.each do |id|
      tileset[id].tileset_names.each_with_index do |name, i|
        next if name.empty?
        List[name] = [id, i]
      end
    end
  end
end
#==============================================================================
# ** Game_Map
#==============================================================================
class Game_Map
  
  # Check tile name
  def check_tilename(tile_id)
    if tile_id >= 1536 # Tile A5
      if tile_id >= 2048 # Tile A1 ~ A4
        case (tile_id - 2048) / 48
        when 0..15 # Tile A1
          name = tileset.tileset_names[0]
        when 16..47 # Tile A2
          name = tileset.tileset_names[1]          
        when 48..79 # Tile A3
          name = tileset.tileset_names[2]
        else # Tile A4
          name = tileset.tileset_names[2]
        end
      else # Tile A5
        name = tileset.tileset_names[4]
      end
    else # Tile B ~ E
      case tile_id / 256
      when 0 # Tile B
        name = tileset.tileset_names[5]
      when 1 # Tile C
        name = tileset.tileset_names[6]
      when 2 # Tile D
        name = tileset.tileset_names[7]
      else # Tile E
        name = tileset.tileset_names[8]
      end
    end
    return name
  end
  
  # Overwrite (Based on NeonBlack's bugfixes)
  def check_passage(x, y, bit)
    all_tiles(x, y).each do |tile_id|
      flag = self.flags[tile_id]
      if flag & 0x10 != 0                   # [☆]: No effect on passage
        next if flag & bit == 0             # [○] : Passable but star
        return false if flag & bit == bit   # [×] : Impassable
      else
        return true  if flag & bit == 0     # [○] : Passable
        return false if flag & bit == bit   # [×] : Impassable
      end
    end
    return false # Impassable
  end
  
  # Get tile flag correspond to the tile name
  def get_tile_flag(tile_id, name)
    return tileset.flags[tile_id] unless AED::Tiles::List[name]
    ref = AED::Tiles::List[name]
    tiles = $data_tilesets[ref[0]]
    if tile_id < 1536
      tile_id = tile_id % 256
      case ref[1]
      when 5 # Tile B
        return tiles.flags[tile_id]
      when 6 # Tile C
        return tiles.flags[tile_id + 256] 
      when 7 # Tile D
        return tiles.flags[tile_id + 256 * 2] 
      when 8 # Tile E
        return tiles.flags[tile_id + 256 * 3] 
      end
    else
      return tiles.flags[tile_id]
    end
  end
  
  # Reconstruct tile flags
  def flags
    if !@flags || @flag_id != @map_id
      @flag_id = @map_id
      @flags = tileset.flags.clone
      
      # Tile B ~ E settings
      1024.times do |tile_id|
        name = check_tilename(tile_id)
        @flags[tile_id] = get_tile_flag(tile_id, name)
      end
      
      # Tile A5 settings
      64.times do |tile_id|
        tile_id = tile_id + 1536
        name = check_tilename(tile_id)
        @flags[tile_id] = get_tile_flag(tile_id, name)
      end
      
      # Tile A1 ~ A4 settings
      (8 * 20 * 48).times do |tile_id|
        tile_id = tile_id + 2048
        name = check_tilename(tile_id)
        @flags[tile_id] = get_tile_flag(tile_id, name)
      end
    end
    return @flags
  end
  
  def layered_tiles_flag?(x, y, bit)
    layered_tiles(x, y).any? {|tile_id| flags[tile_id] & bit != 0 }
  end
  
  def terrain_tag(x, y)
    return 0 unless valid?(x, y)
    layered_tiles(x, y).each do |tile_id|
      tag = flags[tile_id] >> 12
      return tag if tag > 0
    end
    return 0
  end
  
  # For convenient sake
  def data
    @map.data
  end
  
end
#==============================================================================
# ** Spriteset_Map
#==============================================================================
class Spriteset_Map
  # Hi-jack tilemap flags
  alias aed_load_tileset load_tileset
  def load_tileset
    aed_load_tileset
    @tilemap.flags = $game_map.flags
  end
end
