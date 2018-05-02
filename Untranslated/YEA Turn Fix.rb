#==============================================================================
# 
# ¥ Yanfly Engine Ace - Ace Battle Engine v1.22 ( Turn Fix )
# -- Last Updated: 2012.03.04
# -- Level: Normal, Hard
# -- Requires: n/a
# 
# Edited by : TheoAllen 
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
#
#==============================================================================
=begin

  Perkenalan :
  Ini adalah script editan dari Yanfly Battle Engine. Sebelumnya di YEA 
  Battle Engine, jika kamu memencet kanan saat memilih action, maka pilihan 
  actor akan berpindah ke actor berikutnya. 
  
  Jika sampai aktor terakhir kamu masih tetep memencet, maka YEA Battle Engine 
  akan langsung mengeksekusi turn. Dengan kata lain, actor yang belom jalan 
  sama sekali akan di skip. Well, hal kayak gini bisa jadi sangat merugikan 
  bagi mereka yang ga sengaja atawa ngga tau. Apalagi kalau kamu make addonnya, 
  yaitu "Free Turn Battle"
  
  Cara pemasangan :
  Pasang script ini tepat dibawah YEA - Battle Engine
  
  Terms of Use :
  Ikutin aja ini http://yanflychannel.wordpress.com/terms-of-use/
  Jangan lupa, kredit Yanfly.

=end
#==============================================================================
# Do not edit below this line
#==============================================================================
class Scene_Battle
  
  # --------------------------------------------------------------------------
  # Overwrite : Next Command
  # --------------------------------------------------------------------------
  def next_command
    @status_window.show
    redraw_current_status
    @actor_command_window.show
    @status_aid_window.hide
    if BattleManager.next_command
      start_actor_command_selection
    else
      if check_prev_command
        BattleManager.prior_command
        start_actor_command_selection
      else
        turn_start
      end
    end
  end
  
  def check_prev_command
    Array.new($game_party.members) { |i| i }.any? do |member|
      !member.actions.any? {|act| act.valid? }
    end
  end
  
end
