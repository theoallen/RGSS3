#==============================================================================
# TheoAllen - (In)visible Region
# Version : 1.0
# Language : Informal Indonesian
# Requires : Theo Basic Modules - Basic Functions
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://www.theolized.com
#==============================================================================
($imported ||= {})[:Theo_InvisRegion] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.11.22 - Finished script
# =============================================================================
=begin

  Perkenalan :
  -
  
  Cara penggunaan :
  Pasang script ini di bawah material namun di atas main. Jangan lupa ama
  basic modulnya di taruh atas
  
  Untuk membuat map menampilkan efek ini, taruh notetag seperti ini di map
  properties
  <invisreg>
  
  Kemudian sebar region ID. Event yang berada pada region ID sama dengan player
  akan terlihat. Sedangkan yang tidak, akan menghilang.
  
  Agar event tetap ditampilkan, masukkan event comment, lalu isi dengan
  <visible>

=end
# =============================================================================
# No config
# =============================================================================
class TileMask < Plane_Mask
  
  def initialize(vport)
    @region_id = $game_player.region_id
    super
  end
  
  def update
    super
    update_invisible if refresh_case
  end
  
  def update_bitmap
    super
    update_invisible
  end
  
  def update_invisible
    @region_id = $game_player.region_id
    unless $game_map.invisible_region?
      bitmap.clear
      return
    end
    bitmap.entire_fill(Color.new(0,0,0,220))
    $game_map.regions[@region_id].each do |pos|
      x = pos[0] * 32
      y = pos[1] * 32
      bitmap.clear_rect(x,y,32,32)
    end
  end
  
  def refresh_case
    if $game_map.refresh_tilemask
      $game_map.refresh_tilemask = false
      return true
    end
    @region_id != $game_player.region_id
  end
  
end

class Game_Map
  attr_accessor :refresh_tilemask
  attr_reader :regions
  
  alias theo_invistile_setup setup
  def setup(map_id)
    theo_invistile_setup(map_id)
    record_regions
    @refresh_tilemask
  end
  
  def record_regions
    @regions = {}
    width.times do |w|
      height.times do |h|
        regid = region_id(w,h)
        (@regions[regid] ||= []) << [w,h]
      end
    end
  end
  
  def invisible_region?
    @map.note[/<invisreg>/i]
  end
  
end

class Game_Character
  def opacity
    return @opacity unless $game_map.invisible_region?
    return 0 if region_id != $game_player.region_id
    return @opacity
  end  
end

class Game_Player
  def opacity
    return @opacity
  end  
end

class Game_Event
  
  def stay_visible?
    if @last_list != @list
      @last_list = @list
      return false unless @list
      @stay_visible = false
      @list.each do |command|
        next unless [108,408].include?(command.code)
        @stay_visible = true if command.parameters[0] =~ /<visible>/i
      end
    end
    return @stay_visible
  end
  
  def opacity
    return @opacity if stay_visible? || !$game_map.invisible_region?
    return 0 if region_id != $game_player.region_id
    return @opacity
  end
  
  def screen_z
    return 25 if stay_visible? && region_id != $game_player.region_id
    return super
  end
  
end

class Spriteset_Map
  
  alias theo_invistile_create_vport create_viewports
  def create_viewports
    theo_invistile_create_vport
    @tilemask = TileMask.new(@viewport1)
    @tilemask.z = 50
  end
  
  alias theo_invistile_update update
  def update
    theo_invistile_update
    @tilemask.update
  end
  
  alias theo_invistile_dispose dispose
  def dispose
    theo_invistile_dispose
    @tilemask.dispose
  end
  
end
