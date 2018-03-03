# =============================================================================
# TheoAllen - Namebox Window
# Version : 1.3b
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_Namebox] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.12.26 - Compatibility with Message Balloon
# 2013.11.26 - Showing unregistered name now wont throw error
# 2013.11.25 - \C[n] code do not count as window size
#            - \I[n] code do not count as window size
# 2013.11.19 - Bugfix. Namebox won't disposed in scene change
# 2013.10.22 - Now support show actor name using \\n[actor_id]
# 2013.10.19 - Added show event name
# 2013.10.18 - Finished Script
# =============================================================================
=begin

  Perkenalan :
  Script ini ngebikin kamu bisa nampilin Namebox saat dialog berlangsung
  
  Cara penggunaan :
  Pasang script ini dibawah material namun diatas main
  Gunakan kode seperti berikut untuk nampilin namebox
  
  \NBR['key'] >> untuk nampilin namebox disisi kanan
  \NBL['key'] >> untuk nampilin namebox disisi kiri
  
  Dimana key adalah hash key yang berada pada konfigurasi. Baca dibawah sana
  untuk lebih jelasnya. Dan gunakan kode seperti berikut untuk nampilin nama 
  event kalo kamu ngga mau make catetan list yang ada dibawah.
  
  \NBR[n]
  \NBL[n]
  
  Dimana n adalah angka yang menunjukkan ID sebuah event. Contoh : \NBL[1]
  
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

=end
#==============================================================================
# Konfigurasi :
#==============================================================================
module Theo
  module Namebox
  # -------------------------------------------------------------------------
  # Hash key untuk dipanggil dalam kode namebox (\NBL[''] ato \NBR['']).
  # Semisal kamu mengisikan "x" => "Something", maka jika pada message, kamu
  # ngetikin \NBL['x'], maka dalam namebox akan keluar "Something".
  #
  # Kamu juga bisa menampilkan nama actor dengan cara mengisi name dengan
  # symbol "\\n[1]" misalnya. Angka 1 adalah actor dengan ID 1 dalam database
  # -------------------------------------------------------------------------
    List = {
    # "key"   => "name",
      "ste" => "Cornelia Stella",
      "lun" => "Emille Lunar",
      "sol" => "Soleil Alfred",
      "pit" => "Pit Demon",
      "cls" => "",
      "?"   => "??????????",
      "fly" => "Flay Venonum",
      "bos" => "Skyward King",
      "bo5" => "Raja Skyward",
    # Tambahin sendiri
    } # <-- Jangan disentuh
  # -------------------------------------------------------------------------
    Buffer_X = 10 # Jarak horizontal dari tepi samping layar
    Buffer_Y = 0  # Jarak vertikal
  # -------------------------------------------------------------------------
  end
end
#===============================================================================
# Akhir dari konfigurasi
#===============================================================================

#===============================================================================
# ** Namebox
#===============================================================================
class NameBox < Window_Base
  #---------------------------------------------------------------------------
  # * Module include
  #---------------------------------------------------------------------------
  include Theo::Namebox
  
  #---------------------------------------------------------------------------
  # * Initialize
  #---------------------------------------------------------------------------
  def initialize(msg_window)
    super(0,0,1,fitting_height(1))
    self.z = 200
    @text = ""
    @msg_window = msg_window
    @right_side = false
    self.visible = !@text.empty?
    refresh
  end
  
  #---------------------------------------------------------------------------
  # * Update placement
  #---------------------------------------------------------------------------
  def update_placement
    if @msg_window.y <= 0
      self.y = @msg_window.height - Buffer_Y
    else
      self.y = @msg_window.y - self.height + Buffer_Y
    end
    if @right_side
      self.x = Graphics.width - width - Buffer_X
    else
      self.x = Buffer_X
    end
    update_balloon_placement if $imported[:Theo_MessageBalloonV2]
  end
  
  #---------------------------------------------------------------------------
  # * Update openness
  #---------------------------------------------------------------------------
  def update_openness
    self.openness = @msg_window.openness
  end
  
  #---------------------------------------------------------------------------
  # * Refresh
  #---------------------------------------------------------------------------
  def refresh
    resize_window
    create_contents
    update_placement
    draw_text_ex(0,0,@text)
  end
  
  #---------------------------------------------------------------------------
  # * Update
  #---------------------------------------------------------------------------
  def update
    super
    self.visible = !@text.empty?
    update_balloon_placement if $imported[:Theo_MessageBalloonV2]
  end
  
  #---------------------------------------------------------------------------
  # * Resize window
  #---------------------------------------------------------------------------
  def resize_window
    size = text_size(@text).width + (standard_padding * 2) + 4
    self.width = size
  end
  
  #---------------------------------------------------------------------------
  # * Set text
  #---------------------------------------------------------------------------
  def set_text(text, right, from_list = true)
    @right_side = right
    if from_list
      if List[text].nil?
        result = ""
        msgbox "Attention : Theo - Namebox!\nTrying to show unregistered name!"
      else
        result = List[text]
      end
      @text = convert_escape_characters(result)
    else
      @text = text
    end
    refresh
  end
  
  #---------------------------------------------------------------------------
  # * Text size
  #---------------------------------------------------------------------------
  def text_size(text)
    subbed_text = text.dup
    subbed_text.gsub!(/\eI\[\d+\]/i) {"    "}  # Delete Icon
    subbed_text.gsub!(/\eC\[\d+\]/i) {""}      # Delete Color
    super(subbed_text)
  end
  
  #---------------------------------------------------------------------------
  # * Update balloon placement
  #---------------------------------------------------------------------------
  def update_balloon_placement
    if self.y < 0
      self.y = @msg_window.height - Buffer_Y
    else
      self.y = @msg_window.y - self.height + Buffer_Y
    end
    if @right_side
      self.x = @msg_window.x + Graphics.width - width - Buffer_X
    else
      self.x = @msg_window.x + Buffer_X
    end
  end
  
end

#==============================================================================
# ** Game_Event
#==============================================================================

class Game_Event < Game_Character
  #---------------------------------------------------------------------------
  # * Get event name
  #---------------------------------------------------------------------------
  def name
    @event.name
  end
  
end

#==============================================================================
# ** Window_Message
#==============================================================================

class Window_Message < Window_Base
  #---------------------------------------------------------------------------
  # * Alias: Initialize
  #---------------------------------------------------------------------------
  alias theo_namebox_init initialize
  def initialize
    theo_namebox_init
    @namebox = NameBox.new(self)
  end
  
  #---------------------------------------------------------------------------
  # * Alias: Update
  #---------------------------------------------------------------------------
  alias theo_namebox_update update
  def update
    theo_namebox_update
    @namebox.update
  end
  
  #---------------------------------------------------------------------------
  # * Alias: Convert escape character
  #---------------------------------------------------------------------------
  alias theo_namebox_convert_char convert_escape_characters
  def convert_escape_characters(text)
    result = theo_namebox_convert_char(text)
    result = convert_namebox_char(result)
    result
  end
  
  #---------------------------------------------------------------------------
  # * Alias: Convert namebox character
  #---------------------------------------------------------------------------
  def convert_namebox_char(text)
    text.gsub!(/\eNBL\['(.*)'\]/i) { @namebox.set_text($1.to_s,false); "" }
    text.gsub!(/\eNBR\['(.*)'\]/i) { @namebox.set_text($1.to_s,true); "" }
    text.gsub!(/\eNBL\[(\d+)\]/i) do
      ev = $game_map.events[$1.to_i]
      result = (ev ? ev.name : "")
      @namebox.set_text(result, false, false)
      ""
    end
    text.gsub!(/\eNBR\[(\d+)\]/i) do
      ev = $game_map.events[$1.to_i]
      result = (ev ? ev.name : "")
      @namebox.set_text(result, true, false)
      ""
    end
    text
  end
  
  #---------------------------------------------------------------------------
  # * Alias: Close and wait
  #---------------------------------------------------------------------------
  alias theo_namebox_close_wait close_and_wait
  def close_and_wait
    @namebox.set_text("",false, false)
    theo_namebox_close_wait
  end
  
  #---------------------------------------------------------------------------
  # * Alias: Dispose
  #---------------------------------------------------------------------------
  alias theo_namebox_dispose dispose
  def dispose
    theo_namebox_dispose
    @namebox.dispose
  end
  
end
