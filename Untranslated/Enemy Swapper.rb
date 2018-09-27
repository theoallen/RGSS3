# =============================================================================
# TheoAllen - Enemy Swapper
# Version : 1.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_EnemySwapper] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.11.08 - Finished script
# =============================================================================
=begin

  Perkenalan :
  Bosan dengan isi troop member yang itu-itu aja? Ingin membuat isi troop 
  member yang lebih dinamis? Script ini bisa mengabulkan keinginanmu
  
  Cara penggunaan :
  Pasang dibawah material namun diatas main
  Gunakan notetag <swap: id,id,id> pada notebox di database enemy
  dimana id adalah id enemy yang bakal jadi kandidat pengganti enemy tersebut
  
  Semisal ...
  Kamu menuliskan <swap: 1,2,3,4,5,6> pada slime (id-nya slime = 1)
  Nanti saat battle, slime akan diganti dengan enemy yg memiliki id dengan
  nomor 1,2,3,4,5,6
  
  Kamu bisa mengisi id sebanyak-banyaknya
  
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.    

=end
# =============================================================================
# Tidak ada konfigurasi
# =============================================================================
class RPG::Enemy < RPG::BaseItem
  attr_accessor :swap
  
  def load_swap_notetag
    @swap = []
    note.split(/[\r\n]+/).each do |line|
      if line =~ /<swap:[ ]*(.*)>/i
        @swap = $1.to_s.split(/,/).collect do |enemy_id| 
          id = enemy_id.to_i
          next if id == 0
          id
        end.compact
      end
    end
  end
  
end

class << DataManager
  
  alias theo_enemyswap_load_db load_database
  def load_database
    theo_enemyswap_load_db
    load_eswap
  end
  
  def load_eswap
    $data_enemies.compact.each do |enemy|
      enemy.load_swap_notetag
    end
  end
  
end

class Game_Troop < Game_Unit
  
  alias theo_enemyswap_uniq_name make_unique_names
  def make_unique_names
    swap_enemy_members
    theo_enemyswap_uniq_name
  end
  
  def swap_enemy_members
    members.each_with_index do |game_enemy, index|
      enemy_data = $data_enemies[game_enemy.enemy_id]
      next if enemy_data.swap.empty?
      new_id = enemy_data.swap[rand(enemy_data.swap.size)]
      @enemies[index].change_id(new_id)
    end
  end
  
end

class Game_Enemy < Game_Battler
  
  def change_id(enemy_id)
    @enemy_id = enemy_id
    enemy = $data_enemies[@enemy_id]
    @original_name = enemy.name
    @letter = ""
    @plural = false
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = mhp
    @mp = mmp
  end
  
end
