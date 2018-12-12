# =============================================================================
# TheoAllen - Simple Additional Menu Info
# Version : 1.0
# Contact : -
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_SimpleMenuInfo] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2013.07.20 - Finished script
# =============================================================================
=begin

  Perkenalan :
  Script ini nambahin info Location ama Playtime di main menu RTP
  
  Cara penggunaan :
  Pasang dibawah material namun diatas main
  
  Terms of Use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

=end
# =============================================================================
# Konfigurasi ada di script
# =============================================================================
class Window_MenuInfo < Window_Base
  TimeVocab = "Time :" # Vocab untuk time
  
  # -----------------------------------------------------------------------
  # Do not touch pass this line
  # -----------------------------------------------------------------------
  def initialize(width)
    super(0,0,width,fitting_height(3))
    update_placement
    refresh
  end
  
  def update_placement
    self.y = Graphics.height - self.height
  end
  
  def refresh
    contents.clear
    change_color(normal_color)
    draw_location(0,0)
    draw_playtime(0,line_height)
    draw_currency_value(value,currency_unit,0,line_height*2,contents.width)
  end
  
  def draw_location(x,y)
    rect = Rect.new(x,y,contents.width,line_height)
    draw_text(rect,$game_map.display_name,2)
  end
  
  def draw_playtime(x,y)
    rect = Rect.new(x,y,contents.width,line_height)
    change_color(system_color)
    draw_text(rect,TimeVocab)
    change_color(normal_color)
    draw_text(rect,$game_system.playtime_s,2)
  end
  
  def value
    $game_party.gold
  end
  
  def currency_unit
    Vocab::currency_unit
  end
  
  def update
    super
    refresh if Graphics.frame_count % 60 == 0
  end
  
end

class Scene_Menu < Scene_MenuBase
  
  def create_gold_window
    width = @command_window.width
    @gold_window = Window_MenuInfo.new(width)
  end
  
end
