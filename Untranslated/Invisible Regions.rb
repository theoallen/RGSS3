#==============================================================================
# TheoAllen - Invisible Regions
# Version : 1.1
# Language : Informal Indonesian
# Requires : Basic Modules v1.5 - Basic Functions
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
# 2015.08.01 - Added always visible region
# 2014.11.22 - Finished script
# =============================================================================
=begin

  ================
  *) Perkenalan :
  ----------------
  Script ini membuat agar daerah yang berbeda region ID dengan milik player
  tertutupi oleh petak gelap. Event yang berbeda region dengan player juga akan 
  dihilangkan dari layar.
  
  =====================
  *) Cara penggunaan :
  ---------------------
  Pasang script ini di bawah material namun di atas main. Jangan lupa ama
  basic modulnya di taruh atas
  
  Untuk membuat map menampilkan efek ini, taruh notetag seperti ini di map
  properties
  <invisreg>
  
  Kemudian sebar region ID. Event yang berada pada region ID sama dengan player
  akan terlihat. Sedangkan yang tidak, akan menghilang.
  
  Agar event tetap ditampilkan, masukkan event comment, lalu isi dengan
  <visible>
  
  ----------
  UPDATE 1.1
  
  Untuk membuat region tertentu tetap dapat dilihat walau player tidak berada
  pada region tersebut, gunakan notetag <visireg: n> pada peta. Dimana 'n'
  adalah angka dari region ID yang akan tetap dapat dilihat
  
  ===================
  *) Terms of use ||
  -------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.
  
=end
#===============================================================================
# No config
#===============================================================================
#===============================================================================
# ** TileMask
#-------------------------------------------------------------------------------
#  Sprite that same size as the map size. It's also scrolled alongside the map
# if it's updated. It can be used to draw anything on map. In this script, it
# used to manually draw "Fog of War" on map screen.
#===============================================================================
class TileMask < Plane_Mask
  #-----------------------------------------------------------------------------
  # * Initialize
  #-----------------------------------------------------------------------------
  def initialize(vport)
    @region_id = $game_player.region_id
    super
  end
  #-----------------------------------------------------------------------------
  # * Update
  #-----------------------------------------------------------------------------
  def update
    super
    update_invisible if refresh_case
  end
  #-----------------------------------------------------------------------------
  # * Update bitmap
  #-----------------------------------------------------------------------------
  def update_bitmap
    super
    update_invisible
  end
  #-----------------------------------------------------------------------------
  # * Update Invisible
  #-----------------------------------------------------------------------------
  def update_invisible
    @region_id = $game_player.region_id
    unless $game_map.invisible_region?
      bitmap.clear
      return
    end
    bitmap.entire_fill(Color.new(0,0,0,220))
    ($game_map.visiregs + [@region_id]).each do |visireg|
      $game_map.regions[visireg].each do |pos|
        x = pos[0] * 32
        y = pos[1] * 32
        bitmap.clear_rect(x,y,32,32)
      end
    end
  end
  #-----------------------------------------------------------------------------
  # * Refresh case
  #-----------------------------------------------------------------------------
  def refresh_case
    if $game_map.refresh_tilemask
      $game_map.refresh_tilemask = false
      return true
    end
    @region_id != $game_player.region_id
  end
  
end

#===============================================================================
# ** Game_Map
#===============================================================================

class Game_Map
  #-----------------------------------------------------------------------------
  # * Public Attributes
  #-----------------------------------------------------------------------------
  attr_accessor :refresh_tilemask
  attr_reader :regions
  attr_reader :visiregs
  #-----------------------------------------------------------------------------
  # * Setup
  #-----------------------------------------------------------------------------
  alias theo_invistile_setup setup
  def setup(map_id)
    theo_invistile_setup(map_id)
    record_regions
    @refresh_tilemask
  end
  #-----------------------------------------------------------------------------
  # * Record / pre-cache regions
  #-----------------------------------------------------------------------------
  def record_regions
    @regions = {}
    width.times do |w|
      height.times do |h|
        regid = region_id(w,h)
        (@regions[regid] ||= []) << [w,h]
      end
    end
    @visiregs = []
    @map.note.split(/[\r\n]+/).each do |line|
      if line =~ /<visireg\s*:\s*(\d+)>/i
        @visiregs << $1.to_i
      end
    end
  end
  #-----------------------------------------------------------------------------
  # * Invisible region?
  #-----------------------------------------------------------------------------
  def invisible_region?
    @map.note[/<invisreg>/i]
  end
  
end

#===============================================================================
# ** Game_Character
#===============================================================================

class Game_Character
  #-----------------------------------------------------------------------------
  # * Opacity
  #-----------------------------------------------------------------------------
  def opacity
    return @opacity unless $game_map.invisible_region?
    return 0 if region_id != $game_player.region_id
    return @opacity
  end  
end

#===============================================================================
# ** Game_Player
#===============================================================================

class Game_Player
  #-----------------------------------------------------------------------------
  # * Opacity
  #-----------------------------------------------------------------------------
  def opacity
    return @opacity
  end  
end

#===============================================================================
# ** Game_Event
#===============================================================================

class Game_Event
  #-----------------------------------------------------------------------------
  # * Stay Visible?
  #-----------------------------------------------------------------------------
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
  #-----------------------------------------------------------------------------
  # * Opacity
  #-----------------------------------------------------------------------------
  def opacity
    return @opacity if stay_visible? || !$game_map.invisible_region? ||
      $game_map.visiregs.include?(region_id)
    return 0 if region_id != $game_player.region_id
    return @opacity
  end
  #-----------------------------------------------------------------------------
  # * Screen Z value
  #-----------------------------------------------------------------------------
  def screen_z
    return 25 if stay_visible? && region_id != $game_player.region_id
    return super
  end
  
end

#===============================================================================
# ** Spriteset_Map
#===============================================================================

class Spriteset_Map
  #-----------------------------------------------------------------------------
  # * Create Viewports
  #-----------------------------------------------------------------------------
  alias theo_invistile_create_vport create_viewports
  def create_viewports
    theo_invistile_create_vport
    @tilemask = TileMask.new(@viewport1)
    @tilemask.z = 50
  end
  #-----------------------------------------------------------------------------
  # * Update
  #-----------------------------------------------------------------------------
  alias theo_invistile_update update
  def update
    theo_invistile_update
    @tilemask.update
  end
  #-----------------------------------------------------------------------------
  # * Dispose
  #-----------------------------------------------------------------------------
  alias theo_invistile_dispose dispose
  def dispose
    theo_invistile_dispose
    @tilemask.dispose
  end
  
end
