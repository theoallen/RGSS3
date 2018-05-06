# =============================================================================
# TheoAllen - Animated Message Portrait
# Version : 1.3
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_AnimPortrait] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.01.31 - Added screen y reposition
#            - Show portrait in bottom when placing message window in top
# 2014.01.08 - Added show picture in middle
# 2013.11.14 - Dimmed inactive portrait
#            - Bugfix, when remove portrait
# 2013.10.18 - Finished Script
# =============================================================================
=begin

  -----------------------------------------------------------------------------
  *) Perkenalan :
  -----------------------------------------------------------------------------
  Script ini ngebikin kamu bisa nampilin animated portrait waktu dalam dialog.
  
  -----------------------------------------------------------------------------
  *) Cara penggunaan :
  -----------------------------------------------------------------------------
  Pasang script ini dibawah material namun diatas main
  
  Siapkan dua buah gambar ukuran terserah. Satu gambar untuk animasi idle. 
  Satu lainnya untuk animasi bicara. Gambar terdiri dari 3 grid kesamping. Beri
  nama dua gambar tersebut seperti ini
  
  namagambar_idle.png  << nama gambar untuk idle
  namagambar_talk.png  << nama gambar untuk bicara
  
  -----------------------------------------------------------------------------
  *) Script call:
  -----------------------------------------------------------------------------
  Untuk nampilin gambar dan semacemnya, gunakan script call sebagai berikut
  
  - set_portrait(filename, pos, flip, active)
    Script call ini untuk mengeset portrait. Keterangannya kek gini
    
    *) Filename >> adalah nama file gambar yang ditulis dalam kutip (""). 
       Kamu tidak perlu menambahkan _talk / _idle dalam pemanggilannya.
    *) Pos >> untuk posisi. Pilih antara A (kiri), B (kanan), dan C (tengah)
    *) Flip >> apakah gambarnya dibalik atau tidak. Cukup tuliskan true
       atau false (bisa diabaikan. Default : false)
    *) Active >> Apakah gambar tersebut aktif? Jika true, maka saat text
       berjalan, gambar tersebut akan berbicara. (Default : true)
       
  - remove_portrait(pos)
    Untuk menghilangkan salah satu portrait. Pos isi dengan A atau B
  
  - active_portrait(pos)
    Untuk mengganti portrait mana yang aktif
    
  - clear_portrait
    Untuk menghilangkan portrait yang ada
    
  - $game_system.portrait_ypos[pos] = value
    Untuk mereposisi tempat portrait di tampilkan. Ganti pos dengan 
    (:A, :B, :C). Ganti value dengan angka. Contoh :
    
    $game_system.portrait_ypos[:B] = 60
  
  -----------------------------------------------------------------------------
  *) Terms of use :
  -----------------------------------------------------------------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

=end
# =============================================================================
# Konfigurasi
# =============================================================================
module Theo
  module AnimePortrait
    
  # --------------------------------------------------------------------------
    Talk_Refresh_Rate = 4 
  # Refresh rate gambar yang sedang aktif. Jika kamu memasukkan angka 4, maka
  # gambar akan direfresh / diganti setiap 4 huruf telah berjalan di message
  # system. (default : 4)
  # --------------------------------------------------------------------------
  
  # --------------------------------------------------------------------------
    Idle_Interval = [20,120]
  # Interval atau selang animasi idle. Format [absolute wait, random wait]
  #
  # *) absolute wait  >> Selang tunggu absolut dalam hitungan frame
  # *) random wait    >> Selang tunggu acak
  #
  # Jika kamu mengisinya [20, 120] maka itu artinya, jeda antara animasi idle
  # satu dengan yang adalah 20 ditambah angka acak dari 0 - 120. 
  # (default : [20,120])
  #
  # Note : 60 frame adalah 1 detik
  # --------------------------------------------------------------------------
    
  # --------------------------------------------------------------------------
    Use_Dim   = true    # Set true kalo mau gunain. false kalo kaga
    Dim_Power = 90      # Kekuatan dimness (default : 90)
  # --------------------------------------------------------------------------
  # Opsi untuk membuat gambar yang tidak aktif menjadi redup.
  # --------------------------------------------------------------------------
  end
end
# =============================================================================
# Akhir dari konfigurasi
# =============================================================================
class Game_System
  attr_reader :portrait_ypos
  
  alias theo_animportrait_init initialize
  def initialize
    theo_animportrait_init
    @portrait_ypos = {
    :A => 0,
    :B => 0,
    :C => 0,
    }
  end
  
end

class Game_Interpreter
  A = :A  # Kiri
  B = :B  # Kanan
  C = :C  # Tengah
  
  def set_portrait(filename, pos, flip = false, active = true)
    $game_message.animportrait_name[pos] = [filename, flip]
    $game_message.active_portrait = pos if active
  end
  
  def clear_portrait
    $game_message.reset_animportrait
  end
  
  def remove_portrait(pos)
    $game_message.animportrait_name[pos][0] = ""
  end
  
  def active_portrait(pos)
    $game_message.active_portrait = pos
  end
  
end

class Game_Message
  attr_accessor :active_portrait
  attr_reader :animportrait_name
  
  alias theo_animportrait_init initialize
  def initialize
    theo_animportrait_init
    reset_animportrait
    @active_portrait = :A
  end
  
  def reset_animportrait
    @animportrait_name = {
      :A => ["", false],
      :B => ["", false],
      :C => ["", false],
    }
  end
  
end

class AnimPortrait < Sprite
  include Theo::AnimePortrait
  Dimmed_Color = Color.new(0,0,0,Dim_Power)
  Normal_Color = Color.new(0,0,0,0)
  attr_accessor :self_switch  # Self Activation ~
  
  def initialize(pos, msg_window, viewport = nil)
    super(viewport)
    self.z = 150
    @msg_window = msg_window
    @pos = pos
    @self_switch = false
    @idle_pattern = 0
    @fiber = nil
    init_bitmap
    generate_idle_count
  end
  
  def init_bitmap
    @filename = img_name
    self.bitmap = Cache.system(@filename)
    self.mirror = $game_message.animportrait_name[@pos][1]
    case @pos
    when :A
      self.x = 0
    when :B
      self.x = Graphics.width - width
    when :C
      self.x = (Graphics.width - width) / 2
    end
  end
  
  def img_name
    str = $game_message.animportrait_name[@pos][0]
    return "" if str.empty?
    return str + (active? ? "_talk" : "_idle")
  end
  
  def bitmap=(bmp)
    super
    src_rect.width = bitmap.width / 3
  end
  
  def generate_idle_count
    @idle_count = random_idle_number
  end
  
  def random_idle_number
    return Idle_Interval[0] + rand(Idle_Interval[1])
  end
  
  def update
    super
    self.y = ypos_case
    self.opacity = @msg_window.openness
    update_bitmap
    update_color if Use_Dim
    update_idle unless active?
  end
  
  def ypos_case
    return Graphics.height - height + $game_system.portrait_ypos[@pos] if
      $game_message.position == 0
    return @msg_window.y - height + $game_system.portrait_ypos[@pos]
  end
  
  def update_bitmap
    if @filename != img_name
      init_bitmap
    end
  end
  
  def update_color
    if pos_active?
      self.color = Normal_Color
    else
      self.color = Dimmed_Color
    end
  end
  
  def update_active
    @fiber = nil if @fiber
    set_src_rect(rand(3))
  end
  
  def active?
    return pos_active? && self_switch
  end
  
  def pos_active?
    @pos == $game_message.active_portrait
  end
  
  def update_idle
    if @fiber
      @fiber.resume
    elsif @idle_count == 0
      @fiber = Fiber.new { fiber_idle }
    else
      @idle_count -= 1
    end
  end
  
  def fiber_idle
    setup_idle_anim
    update_idle_src_rect
    terminate_idle_anim
  end
  
  def setup_idle_anim
    set_src_rect(0)
  end
  
  def update_idle_src_rect
    random_wait
    set_src_rect(1)
    random_wait
    set_src_rect(2)
    random_wait
    set_src_rect(1)
    random_wait
    set_src_rect(0)
    random_wait
  end
  
  def set_src_rect(amount)
    @pattern = amount
    src_rect.x = @pattern * bitmap.width/3
  end
  
  def random_wait
    (2 + rand(3)).times { Fiber.yield }
  end
  
  def terminate_idle_anim
    @fiber = nil
    generate_idle_count
  end
  
  def dispose
    bitmap.dispose
    super
  end
  
end

class Window_Message < Window_Base
  
  alias theo_animportrait_init initialize
  def initialize
    theo_animportrait_init
    create_animportrait
  end
  
  def create_animportrait
    @animportrait = {
      :A => AnimPortrait.new(:A, self, viewport),
      :B => AnimPortrait.new(:B, self, viewport),
      :C => AnimPortrait.new(:C, self, viewport),
    }
    @talk_anim = 0
  end
  
  def active_portrait
    @animportrait[$game_message.active_portrait]
  end
  
  alias theo_animportrait_process_all_text process_all_text
  def process_all_text
    active_portrait.self_switch = true
    theo_animportrait_process_all_text
  end
  
  alias theo_animportrait_updt_show_fast update_show_fast
  def update_show_fast
    theo_animportrait_updt_show_fast
    active_portrait.set_src_rect(0) if Input.trigger?(:C)
  end
  
  alias theo_animportrait_wait_for_one_char wait_for_one_character
  def wait_for_one_character
    theo_animportrait_wait_for_one_char
    @talk_anim += 1
    active_portrait.update_active if @talk_anim % 3 == 0
  end
  
  alias theo_animportrait_process_input process_input
  def process_input
    active_portrait.set_src_rect(0)
    active_portrait.self_switch = false
    theo_animportrait_process_input
  end
  
  alias theo_animportrait_update update
  def update
    theo_animportrait_update
    @animportrait.values.each {|img| img.update }
  end
  
  alias theo_animportrait_dispose dispose
  def dispose
    theo_animportrait_dispose
    @animportrait.values.each {|img| img.dispose }
  end
  
  alias theo_animportrait_wait wait
  def wait(duration)
    active_portrait.set_src_rect(0)
    theo_animportrait_wait(duration)
  end
  
end
