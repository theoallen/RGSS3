# =============================================================================
# TheoAllen - Event Notification
# Version : 2.0b
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# -----------------------------------------------------------------------------
# Requires :
# >> Theo - Core Movement (Basic Modules)
# =============================================================================
($imported ||= {})[:Theo_EventNotif] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2014.09.** - Compatibility with latest basic module
# 2013.10.14 - Rewrite Script (v2.0)
#            - Support multiple notification show
#            - Add notification SE
#            - Notification will only show up if item has changed by event
#            - Add option to disable notification
#            - Add slide up
# 2013.06.11 - Finished script
# 2013.06.10 - Started script
# =============================================================================
=begin

  Perkenalan :
  Script ini berfungsi untuk menampilkan event popup diatas player saat player
  mendapat item atau mendapat gold. kamu juga bisa menyeting popupmu sendiri
  dengan menggunakan teks.
  
  Cara penggunaan :
  Pasang script ini dibawah material namun diatas main. 
  Pastikan kamu setting $imported[:Theo_Movement] dan $imported[:Theo_CoreFade]
  di Basic Modul gw true
  
  Untuk menghidupkan script ini, pastikan kamu menghidupkan switchnya terlebih 
  dahulu. Switch ID untuk mengaktifkan script ini bisa dilihat di konfigurasi
  
  Gunakan script call seperti berikut untuk nampilin notifikasi berupa teks
  - show_notif(text)
  - show_notif(text, icon)
  - show_notif(text, icon, color)
  
  Dimana text adalah berupa tulisan / text yang dibungkus dalam kutip ("").
  Icon adalah angka yang menunjukkan index icon dalam database (bisa diabaikan).
  Color adalah kode angka untuk warna. Sama seperti \C[n] dalam message box.
  
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.  

=end
# =============================================================================
# Konfigurasi (Awas banyak) :
# -----------------------------------------------------------------------------
# Kalo semisal kamu pusing / ga paham soal settingan ini, lebih baik ngga usah
# ngedit dan ikuti aja settingan default ini
# =============================================================================
module Theo
  module EvNotif
    
  # ==========================================================================
    Use_Notif_Switch  = 0  # Switch ID
  # --------------------------------------------------------------------------
  # Switch ID untuk menghidupkan script ini. Jika ON maka script ini akan
  # dijalankan
  # ==========================================================================  
  
  
  # ==========================================================================
    Use_Item_Sound    = true               # Gunain Sound Effect? (true/false)
    Gain_Item_Sound   = ["Item1", 80, 100] # Gain Item SE
    Lose_Item_Sound   = [ "Miss", 80, 100] # Lose Item SE
  # --------------------------------------------------------------------------
  # Sound Effect yang akan diplay saat notifikasi Change Item/Armor/Weapon
  # ditampilkan. Isi dengan format ["Nama SE", Volume, Pitch]
  # ==========================================================================
    Gain_Item_Color   = 24  # Default : 24
    Lose_Item_Color   = 25  # Default : 25
  # --------------------------------------------------------------------------
  # Untuk settingan warna gain item. Angka disana sama dengan kode \C[n] dalam
  # message box. Kamu bisa memilih angkanya antara 0 - 31.
  # ==========================================================================
  
  
  # ==========================================================================
    Use_Gold_Sound    = true               # Gunain Sound Effect? (true/false)
    Gain_Gold_Sound   = ["Item1", 80, 100] # Gain Gold SE
    Lose_Gold_Sound   = [ "Miss", 80, 100] # Lose Gold SE
  # --------------------------------------------------------------------------
  # Sound Effect yang akan diplay saat notifikasi Change Gold ditampilkan. Isi 
  # dengan format ["Nama SE", Volume, Pitch]
  # ==========================================================================
    Gain_Gold_Color   = 6       # Default : 6
    Lose_Gold_Color   = 25      # Default : 25
    Gold_Icon         = 245     # Icon untuk notifikasi Gold (Default : 245)
    Gold_Vocab        = "Gold"  # Vocab untuk notifikasi Gold
  # --------------------------------------------------------------------------
  # Udah jelas wa rasa ~
  # ==========================================================================
  
  
  # ==========================================================================
    FontName = ["Calibri"]  # Font yang digunakan
    FontSize = 17           # Ukuran font yang digunakan
    FontBold = true         # Mo ditebelin?
  # --------------------------------------------------------------------------
  # Setting untuk font. Untuk nama font, kamu bisa menggunakan multiple font
  # seperti ["Times New Roman","Calibri","Arial"]. Jika nama font paling
  # kiri tidak ada, maka akan dilanjutkan kanan.
  # ==========================================================================
  
  
  # ==========================================================================
    Notif_TimeGap     = 40  # Default : 40 (note: 1)
    Show_Time         = 40  # Default : 40 (note: 2)
    Fadeout_Speed     = 10  # Default : 30 (note: 3)
    SlideUp_Range     = 30  # Default : 30 (note: 4)
    SlideUp_Duration  = 30  # Default : 30 (note: 5)
  # --------------------------------------------------------------------------
  # [Note: 1] => Jeda waktu antara notifikasi satu dengan notifikasi lainnya
  #              Dalam hitungan frame (60 frame = 1 detik)
  # [Note: 2] => Lama notifikasi dimunculkan dalam hitungan frame sebelum
  #              akhirnya menghilang (fadeout) 
  # [Note: 3] => Kecepatan menghilang
  # [Note: 4] => Jarak pergeseran keatas dalam hitungan pixel.
  # [Note: 5] => Durasi bergerak keatas dalam hitungan frame.
  # --------------------------------------------------------------------------
  # Kalo masi ngga paham, coba aja isi make angka ekstrim. Misalnya 100, 999
  # ato 1 :v
  # ==========================================================================
  
  end
end
# =============================================================================
# Akhir dari konfigurasi. Jangan sentuh apapun setelah line ini
# =============================================================================
class NotifStruct
  attr_reader :color
  attr_reader :text
  attr_reader :icon
  attr_reader :sound
  
  def initialize(text, icon, color, sound)
    @color = color
    @text = text
    @icon = icon
    @sound = sound
  end
  
  def play
    sound.play if sound
  end
  
end

class Game_Temp
  attr_reader :notif_queue
  
  alias theo_evnotif_init initialize
  def initialize
    theo_evnotif_init
    @notif_queue = []
  end
  
  def push_notif(text, icon = 0, color = 0, sound = nil)
    notif_queue.push(NotifStruct.new(text, icon, color, sound))
  end
  
end

class Game_Interpreter
  
  include Theo::EvNotif
  
  alias :theo_evnotif_125 :command_125
  alias :theo_evnotif_126 :command_126
  alias :theo_evnotif_127 :command_127
  alias :theo_evnotif_128 :command_128
  
  def show_notif(text, icon = 0, color = 0, sound = nil)
    $game_temp.push_notif(text, icon, color, sound)
  end
  
  def command_125
    theo_evnotif_125
    return unless use_notif?
    value = operate_value(@params[0], @params[1], @params[2])
    fmt = (value > 0 ? "%s +%d" : "%s %d")
    text = sprintf(fmt, Gold_Vocab, value)
    $game_temp.push_notif(text, Gold_Icon, gold_color(value), gold_sound(value))
  end
  
  def command_126
    theo_evnotif_126
    return unless use_notif?
    value = operate_value(@params[1], @params[2], @params[3])
    item_notif($data_items, value)
  end
  
  def command_127
    theo_evnotif_127
    return unless use_notif?
    value = operate_value(@params[1], @params[2], @params[3])
    item_notif($data_weapons, value)
  end
  
  def command_128
    theo_evnotif_128
    return unless use_notif?
    value = operate_value(@params[1], @params[2], @params[3])
    item_notif($data_armors, value)
  end
  
  def item_notif(item, value)
    fmt = (value > 0 ? "%s +%d" : "%s %d")
    text = sprintf(fmt,item[@params[0]].name, value)
    $game_temp.push_notif(text, item[@params[0]].icon_index, item_color(value),
      item_sound(value))
  end
  
  def gold_color(value)
    value > 0 ? Gain_Gold_Color : Lose_Gold_Color
  end
  
  def gold_sound(value)
    return nil unless Use_Gold_Sound
    args = (value > 0 ? Gain_Gold_Sound : Lose_Gold_Sound)
    RPG::SE.new(*args)
  end
  
  def item_color(value)
    value > 0 ? Gain_Item_Color : Lose_Item_Color
  end
  
  def item_sound(value)
    return nil unless Use_Item_Sound
    args = (value > 0 ? Gain_Item_Sound : Lose_Item_Sound)
    RPG::SE.new(*args)
  end
  
  def use_notif?
    $game_switches[Use_Notif_Switch]
  end
  
end

class EvNotives < Array
  
  include Theo::EvNotif
  
  def initialize
    super
    @count = 0
  end
  
  def update
    update_delete
    update_new_notif
    update_members
  end
  
  def update_delete
    delete_if {|ev| ev.disposed? }
  end
  
  def update_new_notif
    @count += 1
    return if $game_temp.notif_queue.empty?
    return if @count <= Notif_TimeGap
    push(EvNotif.new($game_temp.notif_queue.shift))
    @count = 0
  end
  
  def update_members
    each {|ev| ev.update }
  end
  
  def dispose
    each {|ev| ev.dispose }
  end
  
end

class EvNotif < Window_Base
  
  include Theo::EvNotif
  
  def initialize(notif)
    @notif = notif
    super(0,0,1, fitting_height(1))
    self.opacity = 0
    @count = 0
    resize_width
    update_position
    draw_notif
    up(SlideUp_Range, SlideUp_Duration) # Taken from Theo - Basic Modules
  end
  
  def width=(width)
    super
    create_contents
  end
  
  def resize_width
    self.width = calc_width
    setup_font
  end
  
  def line_height
    [FontSize, super].max
  end
  
  def calc_width
    setup_font
    result = text_size(@notif.text).width + standard_padding * 2 + 2
    result += (icon? ? 24 : 0)
    result
  end
  
  def update_position
    self.x = $game_player.screen_x - width/2
    self.y = $game_player.screen_y - 48
  end
  
  def icon?
    @notif.icon > 0
  end
  
  def draw_notif
    color = @notif.color.is_a?(Color) ? @notif.color : text_color(@notif.color)
    change_color(color)
    draw_icon(@notif.icon, 0,0) if icon?
    xpos = (icon? ? 24 : 0)
    text_rect = Rect.new(xpos, 0, contents.width - xpos, contents.height)
    draw_text(text_rect, @notif.text, 1)
    @notif.play
  end
  
  def setup_font
    contents.font.name = FontName
    contents.font.size = FontSize
    contents.font.bold = FontBold
  end
  
  def update
    super
    @count += 1
    update_fadeout
    update_dispose
  end
  
  def update_fadeout
    self.contents_opacity -= Fadeout_Speed if @count >= Show_Time
  end
  
  def update_dispose
    dispose if contents_opacity == 0
  end
  
end

class Scene_Map < Scene_Base
  
  alias theo_evnotif_start start
  def start
    theo_evnotif_start
    @evnotif = EvNotives.new
  end
  
  alias theo_evnotif_update update
  def update
    theo_evnotif_update
    @evnotif.update
  end
  
  alias theo_evnotif_dispose_windows dispose_all_windows
  def dispose_all_windows
    theo_evnotif_dispose_windows
    @evnotif.dispose
  end
  
end
