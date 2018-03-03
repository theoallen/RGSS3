#==============================================================================
# TheoAllen - Same Character Event
# Version : 1.0
# Language : Informal Indonesian
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://www.theolized.com
#==============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.10.25 - Finished
#==============================================================================
=begin

  ================
  || Perkenalan ||
  ----------------
  Script ini membuat posisi event seperti karakter. Meski kamu menaruh eventnya
  sebagai Above Character. Jika posisi Y event ini berada di atas player, maka
  akan ditampilkan di belakang player. Jika posisi Y event ini di bawah player,
  maka event ini akan menutupi player
  
  ======================
  || Cara penggunaan ||
  ----------------------
  Pasang script ini di bawah material namun di atas main
  Masukkan tag <samechar> dalam komen di event
  
  ===================
  || Terms of use ||
  -------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.


=end
#==============================================================================
# Tidak ada konfig
#==============================================================================
class Game_Event
  
  alias theo_samechar_z screen_z
  def screen_z
    return 100 if @samechar
    return theo_samechar_z
  end
  
  alias theo_samechar_setup_page_settings setup_page_settings
  def setup_page_settings
    theo_samechar_setup_page_settings
    @samechar = false
    @list.each do |command|
      next unless [108,408].include?(command.code)
      @samechar = true if command.parameters[0] =~ /<samechar>/i
    end if @list
  end
  
end
