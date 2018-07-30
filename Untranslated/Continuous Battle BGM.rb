# =============================================================================
# TheoAllen - Continuous Battle BGM
# Version : 1.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_Continuous] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2013.05.11 - Started and Finished script
# =============================================================================
=begin

  Script ini ngebikin lagu dalam map bisa tetap berlanjut ke dalam battle jika
  switch id tertentu (yang dikonfigurasi dalam script ini) bernilai true/ ON
  
  Note :
  - Karena script ini kelewat simple, wa bebasin mo kredit ane ato kaga.
  - Kalo semisal u make Random Battle Music gw, pastikan script ini taruh
    dibawahnya

=end
# =============================================================================
# Konfigurasi :
# =============================================================================
module THEO
  module SOUND
    
    CONTINUOUS_SWITCH = 12
    # Switch id untuk continuous battle bgm. Jika true, maka akan berlanjut
    
  end
end
# =============================================================================
# Batas akhir konfig
# =============================================================================
module BattleManager
  
  class << self
    alias not_continuous_battle_bgm play_battle_bgm
  end
  
  def self.play_battle_bgm
    if $game_switches[THEO::SOUND::CONTINUOUS_SWITCH]
      RPG::BGS.stop
    else
      not_continuous_battle_bgm
    end
  end
  
end
