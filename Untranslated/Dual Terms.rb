# =============================================================================
# TheoAllen - Dual Terms
# Version : 1.1
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Requested by : emjenoeg
# =============================================================================
($imported ||= {})[:Theo_DualTerms] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2014.08.18 - Add message use for Skill/Item. Adjusted for AED
#            - Bugfix. It didn't load actor description
# 2013.06.08 - Bugfix at description notetag
# 2013.06.08 - Finished script
# =============================================================================
=begin

  Perkenalan :
  Script ini ngebikin kamu punya alternative name dan description untuk item2
  yang ada di dalam game. Dan juga alternative command. Terms2 alternative itu
  akan menggantikan yang asli jika switch tertentu 
  
  Cara penggunaan :
  Pasang dibawah material namun diatas main
  Edit konfigurasinya
  
  Semisal kamu prefer make notetag, maka gunain tag berikut di database
  <name: potion>
  
  <desc> 
  line pertama
  line kedua
  </desc>
  
  Khusus untuk skill use message
  Gunakan tag seperti ini
  
  <use1: Teks alternatif>
  <use2: Teks alternatif>
  
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.
  
=end
# =============================================================================
# Konfigurasi 
# =============================================================================
module THEO
  module BASEITEM
    # Switch ID untuk digunakan switch (jika ON, maka akan diganti)
    DUAL_SWITCH = 15
    
    # Kalo u gunain alternative command juga ~
    USE_ALT_COMMAND = true
    # -------------------------------------------------------------------------
    # Commands
    # -------------------------------------------------------------------------
    ALT_COMMANDS = {
      0   => "Lawan",           # Fight
      1   => "Kabur",           # Escape
      2   => "Serang",          # Attack
      3   => "Bertahan",        # Defend
      4   => "Barang",          # Items
      5   => "Kemampuan",       # Skills
      6   => "Perlengkapan",    # Equipments
      7   => "Status",          # Status
      8   => "Formasi",         # Formation
      9   => "Simpan",          # Save
      10  => "Keluar",          # End
      
      # nomor 11 ga dipake ~
      
      12  => "Senjata",         # Weapons
      13  => "Baju Pelindung",  # Armors
      14  => "Kunci-kunci",     # Key-Item
      15  => "Ganti",           # Change
      16  => "Optimasi",        # Optimize
      17  => "Lepas semua",     # Remove all
      18  => "Mulai baru",      # New Game
      19  => "Lanjutkan",       # Continue
      20  => "Keluar",          # Shutdown
      21  => "Ke title",        # To title
      22  => "Ga jadi",         # Cancel
    }
    
    # -------------------------------------------------------------------------
    # WARNING! Jika tidak dipake, kosongin aja. Ngehapus salah satu akan 
    # mengakibatkan error
    # -------------------------------------------------------------------------
    # -------------------------------------------------------------------------
    # Items
    # -------------------------------------------------------------------------
    ALT_ITEM_NAME = {

    }
    
    ALT_ITEM_DESC = {

    }
    
    # -------------------------------------------------------------------------
    # Skills
    # -------------------------------------------------------------------------
    ALT_SKILL_NAME = {
      # Isi sendiri ~
    }
    
    ALT_SKILL_DESC = {
      # Isi sendiri ~
    }
    
    # -------------------------------------------------------------------------
    # Weapons
    # -------------------------------------------------------------------------
    ALT_WEAPON_NAME = {
      # Isi sendiri ~
    }
    
    ALT_WEAPON_DESC = {
      # Isi sendiri ~
    }
    
    # -------------------------------------------------------------------------
    # Armors
    # -------------------------------------------------------------------------
    ALT_ARMOR_NAME = {
      # Isi sendiri ~
    }
    
    ALT_ARMOR_DESC = {
      # Isi sendiri ~
    }
    
    # -------------------------------------------------------------------------
    # States
    # -------------------------------------------------------------------------
    ALT_STATE_NAME = {
      # Isi sendiri ~
    }
    
    # -------------------------------------------------------------------------
    # Enemy
    # -------------------------------------------------------------------------
    ALT_ENEMY_NAME = {
      # Isi sendiri ~
    }
    
  end
end
# =============================================================================
# Akhir dari konfigurasi
# =============================================================================
module THEO
  module BASEITEM
  module REGEXP
    
    ALT_NAME      = /<(?:NAME|name):(.*)>/i
    ALT_DESC_ON   = /<(?:DESC|desc)>/i
    ALT_DESC_OFF  = /<\/(?:DESC|desc)>/i
    
  end
  end
end


class RPG::BaseItem
  
  include THEO::BASEITEM
  
  alias ori_name name
  def name
    return ori_name unless $game_switches
    $game_switches[DUAL_SWITCH] ? @alt_name : ori_name
  end
  
  alias ori_desc description
  def description
    return ori_desc unless $game_switches
    $game_switches[DUAL_SWITCH] ? @alt_desc : ori_desc
  end
  
  def target_desc
    return {}
  end
  
  def target_name
    return {}
  end
  
  def load_alternatives
    @read_desc = false
    @alt_name = target_name.include?(self.id) ? target_name[self.id] : @name
    @alt_desc = target_desc.include?(self.id) ? target_desc[self.id] : @description
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when REGEXP::ALT_NAME
        @alt_name = $1.to_s
      when REGEXP::ALT_DESC_ON
        @read_desc = true
        @alt_desc = ""
      when REGEXP::ALT_DESC_OFF
        @read_desc = false
      else
        next unless @read_desc
        @alt_desc += line.to_s + "\n"
      end
    end
  end
  
end

class RPG::Item < RPG::UsableItem
  def target_name
    ALT_ITEM_NAME
  end
  
  def target_desc
    ALT_ITEM_DESC
  end
end

class RPG::Skill < RPG::UsableItem
  ALT_USE_1 = /<use1\s*:(.+)>/i
  ALT_USE_2 = /<use2\s*:(.+)>/i
  
  def target_name
    ALT_SKILL_NAME
  end
  
  def target_desc
    ALT_SKILL_DESC
  end
  
  def load_alternatives
    super
    @alt_use1 = @message1
    @alt_use2 = @message2
    note.split(/[\r\n]+/).each do |line|
      case line
      when ALT_USE_1
        @alt_use1 = $1.to_s
      when ALT_USE_2
        @alt_use2 = $1.to_s
      end
    end
  end
  
  alias ori_message1 message1
  alias ori_message2 message2
  
  def message1
    return ori_message1 unless $game_switches
    $game_switches[DUAL_SWITCH] ? @alt_use1 : ori_message1
  end
  
  def message2
    return ori_message2 unless $game_switches
    $game_switches[DUAL_SWITCH] ? @alt_use2 : ori_message2
  end
  
end

class RPG::Weapon < RPG::EquipItem
  def target_name
    ALT_WEAPON_NAME
  end
  
  def target_desc
    ALT_WEAPON_DESC
  end
end

class RPG::Armor < RPG::EquipItem
  def target_name
    ALT_ARMOR_NAME
  end
  
  def target_desc
    ALT_ARMOR_DESC
  end
end

class RPG::States < RPG::BaseItem
  def target_name
    ALT_STATE_NAME
  end
end

class RPG::Enemy < RPG::BaseItem
  def target_name
    ALT_ENEMY_NAME
  end
end

class RPG::System::Terms
  
  include THEO::BASEITEM
  
  def load_alternatives
    @alt_commands = []
    ALT_COMMANDS.each do |id,term|
      @alt_commands[id] = term
    end
  end
  
  alias ori_commands commands
  def commands
    return ori_commands unless $game_switches || USE_ALT_COMMAND
    $game_switches[DUAL_SWITCH] ? @alt_commands : @commands
  end
  
end

class << DataManager
  
  alias pre_alter_load_db load_database
  def load_database
    pre_alter_load_db
    load_alternatives
  end
  
  def load_alternatives
    ($data_items + $data_skills + $data_weapons + $data_armors + $data_enemies +
       $data_states + [$data_system.terms] + $data_actors + 
       $data_classes).compact.each do |database|
        database.load_alternatives
      end
  end
  
end
