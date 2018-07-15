# =============================================================================
# TheoAllen - Right Side Menu
# Version : 1.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentatikon is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_RightSideMenu] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2013.08.14 - Finished snippet
# =============================================================================
=begin

  Cuman script yg ngebikin pilihan menu ada di samping kanan
  Kalo mo ngedit2 ya terserah :v

=end
# =============================================================================
# Tidak ada konfigurasi
# =============================================================================
class Scene_Menu < Scene_MenuBase
  
  alias theo_rside_menu_command_window create_command_window
  def create_command_window
    theo_rside_menu_command_window
    @command_window.x = Graphics.width - @command_window.width
  end
  
  alias theo_rside_menu_gold create_gold_window
  def create_gold_window
    theo_rside_menu_gold
    @gold_window.x = Graphics.width - @gold_window.width
  end
  
  alias theo_rside_menu_status create_status_window
  def create_status_window
    theo_rside_menu_status
    @status_window.x = 0
  end
  
end
