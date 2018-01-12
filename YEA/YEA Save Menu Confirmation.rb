# =============================================================================
# TheoAllen - Save Confirmation
# Version : 1.0b
# =============================================================================
($imported ||= {})[:Theo_SaveConfirm] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2018.01.12 - Modified for YEA Save Menu
# 2013.09.03 - Finished script
# =============================================================================
=begin

  Perkenalan :
  Script ini ngebikin saat kamu save game akan menampilkan window konfirmasi
  jika slot save sudah terpakai
  
  Cara penggunaan :
  Pasang dibawah material namun diatas main
  Edit konfigurasinya jika dirasa perlu
  
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.    

=end
# =============================================================================
# konfigurasi
# =============================================================================
module THEO
  module Save
    
  # ------------------------------------------------------------------------  
    ConfirmText = "Overwrite existing file?"
  # Text yang ditampilin di help window
  # ------------------------------------------------------------------------
  
  # ------------------------------------------------------------------------  
    YesConfirm  = "Yes" # Vocab untuk iya
    NoConfirm   = "No"  # Vocab untuk tidak
  # ------------------------------------------------------------------------
  
  end
end
# =============================================================================
# Akhir dari konfig
# =============================================================================
class Window_SaveConfirm < Window_Command  
  
  def initialize
    super(0,0)
    to_center
    self.openness = 0
    deactivate
  end
  
  def to_center
    self.x = (Graphics.width - width)/2
    self.y = (Graphics.height - height)/2
  end
  
  def alignment
    return 1
  end
  
  def make_command_list
    add_command(THEO::Save::YesConfirm, :yes)
    add_command(THEO::Save::NoConfirm, :cancel)
  end
  
  def window_width
    return 120
  end  
  
end

class Scene_Save < Scene_File
  
  alias theo_saveconfirm_start start
  def start
    theo_saveconfirm_start
    create_saveconfirm
  end
  
  def create_saveconfirm
    @confirm = Window_SaveConfirm.new
    @confirm.viewport = @viewport
    @confirm.set_handler(:yes, method(:do_save))
    @confirm.set_handler(:cancel, method(:confirm_cancel))
  end
  
  alias theo_saveconfirm_ok on_action_save
  def on_action_save
    if file_exist?
      activate_confirm
    else
      theo_saveconfirm_ok
    end
  end
  
  def do_save
    theo_saveconfirm_ok
    @confirm.close
  end
  
  def activate_confirm
    @confirm.open
    @confirm.activate
    @help_window.set_text(confirm_text)
  end
  
  def confirm_text
    THEO::Save::ConfirmText
  end
  
  def confirm_cancel
    @confirm.close
    @help_window.set_text(help_window_text)
    @action_window.activate
  end
  
  def file_exist?
    filename = DataManager.make_filename(@file_window.index)
    FileTest.exist?(filename)
  end
  
  alias theo_saveconfirm_update_cursor update_cursor
  def update_cursor
    return if @confirm.active
    theo_saveconfirm_update_cursor
  end
  
end
