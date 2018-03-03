#===============================================================================
# TheoAllen - Event Trigger There
# Version : 1.0
# Language : Informal Indonesian
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#-------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://www.theolized.com
#===============================================================================
($imported ||= {})[:Theo_EventTriggerThere] = true
#===============================================================================
# Change Logs:
# ------------------------------------------------------------------------------
# 2013.11.23 - Finished
#===============================================================================
=begin

  ================
  *) Perkenalan :
  ----------------
  Script ini memaksa event lain untuk dijalankan setelah event yang sedang 
  berjalan saat ini selesai. 
  
  Contohnya, jika event ID yang berjalan saat ini adalah nomor 2, dan kamu 
  tentukan event yang berjalan berikutnya adalah event nomor 3, maka setelah 
  event nomor 2 selesai, akan langsung mengeksekusi event nomor 3. Trigger 
  action button, event touch, atau player touch tidak  berpengaruh
  
  =====================
  *) Cara penggunaan :
  ---------------------
  Pasang script ini di bawah material namun di atas main.
  Untuk mengantrikan event yang akan dieksekusi, gunakan script call berikut
  
  $game_map.events_queue << event_id
  
  Jika kamu menggunakannya seperti ini
  $game_map.events_queue << 1
  $game_map.events_queue << 2
  $game_map.events_queue << 3
  
  Maka event akan dijalankan dari 1, 2, dan 3, secara berturut-turut.
  
  ===================
  *) Terms of use ||
  -------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

=end
#===============================================================================
# Tidak ada konfig. Jangan coba-coba ubah code di bawah.
#===============================================================================
# ** Game_Map
#===============================================================================
class Game_Map
  #-----------------------------------------------------------------------------
  # * Attributes reader
  #-----------------------------------------------------------------------------
  attr_reader :force_event
  attr_reader :events_queue
  #-----------------------------------------------------------------------------
  # * Initialize
  #-----------------------------------------------------------------------------
  alias theo_event_there_init initialize
  def initialize
    @events_queue = []
    @force_event = -1
    theo_event_there_init
  end
  #-----------------------------------------------------------------------------
  # * Next Event
  #-----------------------------------------------------------------------------
  def next_event
    @force_event = @events_queue.shift || -1
  end
  #-----------------------------------------------------------------------------
  # * Update
  #-----------------------------------------------------------------------------
  alias theo_event_there_update update
  def update(main = false)
    theo_event_there_update(main)
    if !@events_queue.empty? && @force_event == -1
      next_event
    end
  end
  
end
#===============================================================================
# ** Game_Event
#===============================================================================
class Game_Event
  #-----------------------------------------------------------------------------
  # * Starting
  #-----------------------------------------------------------------------------
  alias theo_event_there_starting starting
  def starting
    theo_event_there_starting || $game_map.force_event == @event.id
  end
  
end
#===============================================================================
# ** Game_Interpreter
#===============================================================================
class Game_Interpreter
  #-----------------------------------------------------------------------------
  # * Setup
  #-----------------------------------------------------------------------------
  alias theo_event_there_setup setup
  def setup(*args)
    theo_event_there_setup(*args)
    if @event_id == $game_map.force_event
      $game_map.next_event
    end
  end
end
