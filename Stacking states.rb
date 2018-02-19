# =============================================================================
# TheoAllen - Stacking States
# Version : 1.0
# =============================================================================
($imported ||= {})[:Theo_StackingState] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.10.24 - Finished Script
# =============================================================================
=begin

  Perkenalan :
  Script ini ngebikin kamu bisa ngasi status ke musuh secara tumpuk-tumpuk.
  Misalnya enemy kena 3 status poison dan semacemnya.
  
  Cara penggunaan :
  Pasang script ini dibawah material namun diatas main
  Gunakan tag <stack: n> pada notebox states di database. Dimana n adalah
  angka untuk maksimal untuk tumpukan state
  
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.  

=end
# =============================================================================
# Tidak ada konfigurasi
# =============================================================================
class RPG::State < RPG::BaseItem
  attr_accessor :max_stack
  
  def load_stack
    @max_stack = 1
    note.split(/[\r\n]+/).each do |line|
      if line =~ /<stack:[ ]*(\d+)>/i
        @max_stack = $1.to_i
      end
    end
  end
  
end

class << DataManager
  
  alias theo_stackstate_load_db load_database
  def load_database
    theo_stackstate_load_db
    load_stackstate_db
  end
  
  def load_stackstate_db
    $data_states.compact.each do |state|
      state.load_stack
    end
  end
  
end

class Game_Battler < Game_BattlerBase
  # ---------------------------------------------------------------------------
  # Overwrite add state
  # ---------------------------------------------------------------------------
  def add_state(state_id)
    if state_addable?(state_id)
      add_new_state(state_id) unless state?(state_id) && state_maxed?(state_id)
      reset_state_counts(state_id)
      @result.added_states.push(state_id).uniq!
    end
  end
  
  def state_maxed?(state_id)
    @states.select {|id| id == state_id}.size == 
      $data_states[state_id].max_stack
  end
  
end
