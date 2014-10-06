# =============================================================================
# TheoAllen - Random Battle Transition
# Version : 2.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_BattleTransition] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.09.22 - Rewrite the script (version 2.0)
# 2013.05.14 - Started and Finished script
# =============================================================================
=begin

  Perkenalan:
  Script ini ngebikin tiap kali sebelum masuk battle akan menampilkan transisi
  yang berbeda-beda
  
  Cara penggunaan :
  Pasang diatas main tapi dibawah material
  Penjelasan lebih lanjut ada di bawah.
  
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

=end
# =============================================================================
# Konfigurasi :
# =============================================================================
module Theo
  #============================================================================
  # Catat file2 untuk transisi disini. File harus ada di Graphics/system
  #----------------------------------------------------------------------------
    BattleTrans = { # <-- Jangan disentuh!
  #----------------------------------------------------------------------------
  # Masukkan setting transisi dengan format seperti ini
  # 
  # "KataKunci_1" => [
  #  ["file", durasi, blend],
  #  ["file", durasi, blend],
  #  ["file", durasi, blend],
  #  ["file", durasi, blend],
  #  ], 
  #
  # Dan perhatikan KOMA!
  #
  # Durasi adalah lamanya transisi ditampilin.
  # Blend adalah (bingung gw jelasinnya). semacem nilai ambiguitas antara
  # screen sebelumnya ama sesudahnya. Coba2 sendiri lah :P
  #
  # default duration = 60
  # default blend = 100 (max 100)
  #
  # Kamu bisa menyetting transisi battle lebih bebas. Semisal, di map X 
  # transisi yang akan kamu pake adalah file1, file2, file2, kamu bisa membuat
  # kata kunci transisi lain. Semisal kata kuncinya adalah "Castle"
  # 
  # "Castle" => [
  #  ["file1", 60, 100],
  #  ["file2", 60, 100],
  #  ["file3", 60, 100],
  #  ],
  #
  # Kamu bisa mengganti random transisi dengan pake script call :
  # battle_trans("Castle")
  #
  # Nanti transisi yang akan dijalankan adalah make file1, file2, file3
  #---------------------------------------------------------------------------
  "Random_1" => [
    ["Ash"          ,60     ,100],
    ["BattleStart"  ,60     ,100],
    ["Cloud"        ,60     ,100],
    ],
    
  "Random_2" => [
    ["Crossflame"   ,60     ,100],
    ["Whitehole"    ,60     ,100],
    ["Whirlwind"    ,60     ,100],
    ],
    
  "Random_3" => [
    ["Eye"          ,60     ,100],
    ["SlideRight"   ,60     ,100],
    ["Startbattlev2",60     ,100],
    ],
  #---------------------------------------------------------------------------
  } # <-- Jangan dihapus
  #---------------------------------------------------------------------------
  
  BattleTrans_Init = "Random_3" 
  # Pada awal maen, kamu mau make transisi yang mana?
  
end
# =============================================================================
# Akhir dari konfigurasi
# =============================================================================

class Game_Interpreter
  def battle_trans(key)
    $game_system.battle_trans = key
  end
end

class Game_System
  attr_writer :battle_trans
  def battle_trans
    @battle_trans ||= Theo::BattleTrans_Init
  end
end

class Scene_Map < Scene_Base
  
  def perform_battle_transition
    array = Theo::BattleTrans[$game_system.battle_trans]
    result = array[rand(array.size).to_i]
    duration = result[1]
    path = sprintf("Graphics/System/%s",result[0])
    blend = result[2]
    Graphics.transition(duration,path,blend)
    Graphics.freeze
  end
  
end
