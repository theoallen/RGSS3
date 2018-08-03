# =============================================================================
# TheoAllen - Windowskin Changer
# Version : 2.0
# Contact : Discord @ Theo#3034
# =============================================================================
($imported ||= {})[:Theo_WSkinV2] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.11.14 - Finished script
# =============================================================================
=begin

  Perkenalan :
  Script ini membuat kamu bisa mengganti windowskin di tengah game. Beda dengan
  windowskin changer yang versi 1 dulu karena bergantung pada scriptnya si
  yanfly
  
  Cara penggunaan :
  Pasang script ini dibawah material namun diatas main
  Edit konfigurasinya.
  
  Jika kamu ingin mengganti windowskin dengan menggunakan event, kamu cukup
  menggunakan script call
  
  $game_system.used_skin = "windowskinbaru"
  
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

=end
# =============================================================================
# Konfigurasi :
# =============================================================================
module Theo
  module WSkin
  
    Init        = "Window"
  # Inisial nama window skin yang kamu pake saat game dimulai
  
    HelpText    = "Choose your window style : " 
  # Tulisan help untuk menu windowskin
  
    MainMenu    = true
  # Jika kamu set true, maka player bisa ganti windowskin di main menu
  
    MenuCommand = "Style"
  # Command untuk ganti windowskin
    
    Selected_Window_Color = 16
  # Warna untuk windowskin yang dipilih (Warna sama kek \C[n] di message)
  
    List = [  # <-- Jangan disentuh
  # List windowskin yang kamu pakai disini. Nama harus sesuai dengan nama file
  # windowskin yang kamu taruh di Graphics/system
    "Window",
    "Window2",
    "Window3",
    "Window4",
    
  # Tambah disini
  # Dan disini
  # Jangan lupa komma
  
    ] # <-- Jangan disentuh
  
  end
end
# =============================================================================
# Akhir dari konfigurasi
# =============================================================================
class Game_System
  attr_accessor :used_skin
  
  alias theo_wskinchanger_init initialize
  def initialize
    theo_wskinchanger_init
    @used_skin = Theo::WSkin::Init
  end
  
end

class Window_Base < Window
  
  alias theo_windowskin_init initialize
  def initialize(*args)
    theo_windowskin_init(*args)
    @skin = $game_system.used_skin
    self.windowskin = Cache.system(@skin)
  end
  
  alias theo_update_windowskin update
  def update
    theo_update_windowskin
    update_windowskin
  end
  
  def update_windowskin
    return unless @skin != $game_system.used_skin
    @skin = $game_system.used_skin
    self.windowskin = Cache.system(@skin)
  end
  
end

class Window_SkinChanger < Window_Command
  
  def initialize(x,y)
    super(x,y)
    self.visible = false
    deactivate
  end
  
  def item_rect(index)
    rect = super(index)
    rect.y += 2 * line_height
    rect
  end
  
  def make_command_list
    Theo::WSkin::List.each do |skin|
      add_command(skin, skin.to_sym)
    end
  end
  
  def resize(width,height)
    self.width = width
    self.height = height
    refresh
  end
  
  def set(x,y,width,height)
    self.x = x
    self.y = y
    resize(width,height)
  end
  
  def wskin_name
    command_name(index)
  end
  
  def draw_item(index)
    if command_name(index) == $game_system.used_skin
      change_color(text_color(Theo::WSkin::Selected_Window_Color))
    else
      change_color(normal_color)
    end
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
  
  def refresh
    super
    draw_text(4,0,contents.width,line_height,Theo::WSkin::HelpText)
  end
  
end

class Window_MenuCommand < Window_Command
  
  alias theo_wskinchanger_ori_cmd add_original_commands
  def add_original_commands
    theo_wskinchanger_ori_cmd
    add_command(Theo::WSkin::MenuCommand, :wskin) if Theo::WSkin::MainMenu
  end
  
end

class Scene_Menu < Scene_MenuBase
  
  alias theo_wskinchange_start start
  def start
    theo_wskinchange_start
    create_wskin_changer
  end
  
  def create_wskin_changer
    wx = @status_window.x
    wy = @status_window.y
    ww = @status_window.width
    wh = @status_window.height
    @wskin = Window_SkinChanger.new(0,0)
    @wskin.set(wx,wy,ww,wh)
    @wskin.set_handler(:ok, method(:change_skin))
    @wskin.set_handler(:cancel, method(:on_skin_cancel))
    @command_window.set_handler(:wskin, method(:on_wskin_ok))
  end
  
  def change_skin
    $game_system.used_skin = @wskin.wskin_name
    @wskin.refresh
    @wskin.activate
  end
  
  def on_skin_cancel
    @status_window.visible = true
    @wskin.visible = false
    @command_window.activate
  end
  
  def on_wskin_ok
    @status_window.visible = false
    @wskin.visible = true
    @wskin.activate
  end
  
end
