# =============================================================================
# TheoAllen - Animated Battleback
# Version : 1.0b
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_AnimBattleBack] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.07.15 - Fixed bug where you couldn't put unanimated battleback
# 2013.10.28 - Finished script
# =============================================================================
=begin
  
  ------------------------------------------------------------------------
  Perkenalan :
  ------------------------------------------------------------------------
  Pengen battleback kamu bisa gerak? Well, mungkin script ini bisa mewujudkan
  impianmu. Semoga saja :D
  
  ------------------------------------------------------------------------
  Cara penggunaan :
  ------------------------------------------------------------------------
  Pasang script ini dibawah material namun diatas main
  Buat folder "AnimBattleBack" di dalam folder Graphics. 
  
  Siapkan gambar background untuk battleback dengan format nama 
  "namafile_01.png". Siapkan gambar berikutnya untuk frame animasi setelahnya
  dan namakan dengan "namafile_02.png". Dan seterusnya. Kamu boleh memasukkan
  frame animasi sebanyak yang kamu mau. Dan perlu diingat, jangan lupa dengan
  nomor frame belakang tersebut ("_02.png" dst ...)
  
  Untuk menggunakan animated battleback pada map tertentu, gunakan notetag
  <anim bb: key_animasi> dimana "key_animasi" adalah "key" yang berada pada
  konfigurasi dibawah. Perlu diingat, penulisan "key_animasi" pada notetag 
  tidak perlu disertai kutip
  
  ------------------------------------------------------------------------
  Terms of use :
  ------------------------------------------------------------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

=end
# =============================================================================
# Konfigurasi
# =============================================================================
module Theo
  module AnimBB
  # --------------------------------------------------------------------------
  # Animated Battleback Database
  # --------------------------------------------------------------------------
  # Paduan konfigurasi :
  #
  # Key     --> Kata kunci untuk dipergunakan dalam notetag di map properties
  # Nama    --> Nama untuk file gambar (tanpa disertai "_01")
  # Frame   --> Frame maksimal gambar. Misalnya animasi framenya ada 20
  # Rate    --> Refresh rate. Makin kecil, gambar akan makin cepet gerak
  # --------------------------------------------------------------------------
    List = {
  # "Key"     => ["Nama"      , Frame, Rate],
    "mansion" => ["mansion"   ,     8,    4],
    "dtown"   => ["deserttown",     7,   10],
  
  # Tambahin sendiri  
    } # <-- Jangan disentuh!
    
  end
end
# =============================================================================
# Akhir dari konfigurasi
# =============================================================================
class << Cache
  
  def animbattleback(filename, index)
    file = filename + sprintf("_%02d", index)
    load_bitmap("Graphics/AnimBattleBack/", file)
  end
  
end

class Game_System
  attr_accessor :anim_bb
  
  alias theo_animbb_init initialize
  def initialize
    theo_animbb_init
    @anim_bb = ""
  end
  
end

class Game_Map
  
  alias theo_animbb_setup setup
  def setup(map_id)
    theo_animbb_setup(map_id)
    setup_animbb
  end
  
  def setup_animbb
    $game_system.anim_bb = ""
    @map.note.split(/[\r\n]+/).each do |line|
      if line =~ /<(?:anim bb|anim_bb):[ ]*(.+)>/i
        $game_system.anim_bb = $1.to_s
      end
    end
  end
  
end

class AnimBB < Sprite
  attr_reader :name
  attr_reader :index
  
  def initialize(viewport)
    super(viewport)
    init_member
  end
  
  def init_member
    @name = $game_system.anim_bb
    @count = 0
    @index = 1
    refresh_bitmap
  end
  
  def refresh_bitmap
    if name.empty?
      self.bitmap = Cache.empty_bitmap
    else
      self.bitmap = Cache.animbattleback(file, index)
    end
  end
  
  def file
    Theo::AnimBB::List[name][0]
  end
  
  def max_index
    Theo::AnimBB::List[name][1]
  end
  
  def rate
    Theo::AnimBB::List[name][2]
  end
  
  def need_refresh?
    @count % rate == 0 && !name.empty?
  end
  
  def change_index
    @index += 1
    if @index == max_index
      @index = 1
    end
    refresh_bitmap
  end
  
  def update
    super
    return if name.empty?
    @count += 1
    change_index if need_refresh?
  end
  
end

class Spriteset_Battle
  
  alias theo_animbb_create_viewports create_viewports
  def create_viewports
    theo_animbb_create_viewports
    create_animbb
  end
  
  def create_animbb
    @animbb = AnimBB.new(@viewport1)
    @animbb.z = 5
    center_sprite(@animbb)
  end
  
  alias theo_animbb_update update
  def update
    theo_animbb_update
    @animbb.update
  end
  
  alias theo_animbb_dispose dispose
  def dispose
    theo_animbb_dispose
    @animbb.dispose
  end
  
end
