# =============================================================================
# TheoAllen - Region Bush
# Version : 1.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_RegionBush] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.03.01 - Finished script
# =============================================================================
=begin

  Perkenalan :
  Script ini ngebuat kamu bisa menyetting bush (sprite setengah transparan)
  pada tile selain rumput. Mayan berguna jika kamu mau gunain custom parallax
  mapping
  
  Cara penggunaan :
  Pasang script ini di bawah material namun di atas main
  Gunakan notetag pada map properties seperti ini
  
  <bush: x>
  Ganti x dengan angka. Semisal 1. Maka jika ada karakter yang melewati region
  id 1, maka akan tampak seperti sedang melewati rerumputan.
  
  Kamu juga bisa gunain region ganda kayak
  <bush: 1,2,3,4>
  
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.    

=end
# =============================================================================
# Tidak ada konfigurasi
# =============================================================================
class Game_Map
  attr_reader :regbush
  RegionBushREGX = /<bush\s*:\s*(.+)>/i
  
  alias theo_regbush_setup setup
  def setup(map_id)
    theo_regbush_setup(map_id)
    @regbush = []
    @map.note.split(/[\r\n]+/).each do |line|
      if line =~ RegionBushREGX
        $1.to_s.split(/,/).each do |num|
          @regbush.push(num.to_i)
        end
      end
    end
  end
  
end

class Game_CharacterBase
  
  alias theo_regbush_bush? bush?
  def bush?
    theo_regbush_bush? || region_bush?
  end
  
  def region_bush?
    $game_map.regbush.include?(region_id) rescue false
  end
  
end
