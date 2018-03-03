# =============================================================================
# TheoAllen - Region Switcher
# Version : 1.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_RegionSwitch] = true
# =============================================================================
# Change Logs :
# -----------------------------------------------------------------------------
# 2014.03.21 - Finished script
# =============================================================================
=begin

  Perkenalan :
  Script ini ngebuat kamu bisa ngeswitch region dari nomor tertentu ke nomor
  lain. Berguna buat mendukung script-script yang ngemanfaatin region
  
  Cara penggunaan :
  Pasang script ini di bawah material namun di atas main.
  Gunakan script call seperti berikut
  
  region_switch(ori_id, switch)
  
  Ganti ori_id dengan original region ID yang akan kamu ubah.
  Contoh :
  
  region_switch(1, 0)
  
  Script call tersebut akan mengubah region id dari map saat kamu berada yang 
  awalnya nilainya 1 akan jadi 0.
  
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.  

=end
# =============================================================================
# Tidak ada konfigurasi
# =============================================================================
class Game_System
  attr_reader :regswitch
  
  alias theo_regswitch_init initialize
  def initialize
    theo_regswitch_init
    @regswitch = {}
  end
  
end

class Game_Map
  
  alias theo_regswitch_reg_id region_id
  def region_id(x,y)
    result = theo_regswitch_reg_id(x,y)
    switch = $game_system.regswitch[[map_id, result]]
    if switch.nil?
      $game_system.regswitch[[map_id, result]] = result
    end
    return switch
  end
  
end

class Game_Interpreter
  
  def region_switch(region_id, switch, map_id = $game_map.map_id)
    $game_system.regswitch[[map_id, region_id]] = switch
  end
  
end

#~ class Scene_Map
#~   
#~   alias theo_regtest_update update
#~   def update
#~     theo_regtest_update
#~     puts $game_player.region_id
#~   end
#~   
#~ end
