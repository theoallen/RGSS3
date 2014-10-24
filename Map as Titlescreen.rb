#==============================================================================
# TheoAllen - Map as Titlescreen
# Version : 1.0
# Language : Informal Indonesian
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://theolized.blogspot.com
#==============================================================================
($imported ||= {})[:Theo_MapTitle] = true
#==============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.10.24 - Finished
#==============================================================================
%Q{

  =================
  || Perkenalan ||
  -----------------
  Script ini membuat kamu bisa menggunakan map dalam RM sebagai dasar dari 
  titlescreen.
  
  ======================
  || Cara penggunaan ||
  ----------------------
  Pasang script ini di bawah material namun di atas main
  Setting konfigurasinya di bawah jika perlu
  
  ===================
  || Terms of use ||
  -------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.
  
}
#==============================================================================
# Konfigurasi
#==============================================================================
module Theo
  module MapTitle
  
  # Map ID mana yang akan kamu pakai?
    MapID = 3
  
  # Posisi map, jika map kamu lebih dari dari 17 x 13
    DisplayPos = [0,0]
    
  end
end
#==============================================================================
# Akhir dari konfigurasi
#==============================================================================
class Scene_Title
  
  alias theo_maptitle_start start
  def start    
    theo_maptitle_start
    $game_map.setup(Theo::MapTitle::MapID)
    $game_map.set_display_pos(*Theo::MapTitle::DisplayPos)
    @spriteset = Spriteset_Map.new
    @sprite1.visible = @sprite2.visible = false
  end
  
  alias theo_maptitle_update update
  def update
    theo_maptitle_update
    $game_map.update
    @spriteset.update
  end
  
  alias theo_maptitle_terminate terminate
  def terminate
    theo_maptitle_terminate
    @spriteset.dispose
  end
  
end
