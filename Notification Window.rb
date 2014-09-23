#==============================================================================
# TheoAllen - Notification Window
# Version : 1.0
# Language : Informal Indonesian
# Requires : Basic Modules - Core Fade
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://theolized.blogspot.com
#==============================================================================
($imported ||= {})[:Theo_NotifWindow] = true
#==============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.09.22 - Finished
#==============================================================================
=begin

  =================
  || Perkenalan ||
  -----------------
  Script ini memberi kamu alternatif untuk menampilkan notifikasi daripada
  harus menggunakan show text. Notifikasi akan di munculkan di atas dan tulisan
  akan tampak diketik
  
  ======================
  || Cara penggunaan ||
  ----------------------
  Pasang script ini di bawah material namun di atas main
  Jangan lupa pasang Basic Modules juga
  
  Untuk menampilkan notifikasi kamu bisa gunakan script call berikut
  add_notif("Teks notifikasi")
  
  ===================
  || Terms of use ||
  -------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

=end
#==============================================================================
# Konfigurasi
#==============================================================================
module Theo
  module Notif
  #============================================#
  # Timing (dalam frame dimana 60 = 1 detik) ~ #
  #============================================#
    StartFadein = 15  # Durasi window notifikasi dimunculkan
    DelayTime   = 120 # Jeda antara notifikasi satu dengan yang lain
    EndFadeout  = 15  # Durasi window disembunyikan
    
  #=============================================#
  # Pewarnaan dalam (red, green, blue, alpha) ~ #
  #=============================================#
    ColorStart  = Color.new(0,0,0,180)
    ColorEnd    = Color.new(0,0,0,50)
    
  #======================================#
  # Posisi (Makin kecil, makin keatas) ~ #
  #======================================#
    XPosition   = -6
    
  end
end
#==============================================================================
# Akhir dari konfigurasi
#==============================================================================
class Game_Interpreter
  
  def add_notif(text)
    $game_temp.stack_notif << text
  end
  
end

class Game_Temp
  attr_reader :stack_notif
  
  alias theo_typenotif_init initialize
  def initialize
    theo_typenotif_init
    @stack_notif ||= []
  end
  
end

class Window_TypingNotif < Window_Base
  class Opacity_Fade
    attr_accessor :opacity
    include THEO::FADE
    
    def initialize
      @opacity = 0
      init_fade_members
      setfade_obj(self)
    end
  end
  
  Color1 = Theo::Notif::ColorStart
  Color2 = Theo::Notif::ColorEnd
  
  def initialize
    super(-12,Theo::Notif::XPosition,Graphics.width+24,fitting_height(1))
    @ref = Opacity_Fade.new
    refresh
    self.contents_opacity = @ref.opacity
    self.opacity = 0
  end
  
  def refresh
    contents.clear
    contents.gradient_fill_rect(contents.rect, Color1, Color2)
  end
  
  def update
    super
    @ref.update_fade
    self.contents_opacity = @ref.opacity
    if @fiber.nil? && !$game_temp.stack_notif.empty?
      @fiber = Fiber.new { update_notif_fiber }
    elsif @fiber
      @fiber.resume
    end
  end
  
  def update_notif_fiber
    refresh
    @ref.fadein(Theo::Notif::StartFadein)
    Fiber.yield while @ref.fade?
    loop do
      notif = $game_temp.stack_notif.shift
      refresh
      draw_text_ex(4 + 12,0,notif)
      Theo::Notif::DelayTime.times { Fiber.yield }
      break if $game_temp.stack_notif.empty?
    end
    @ref.fadeout(Theo::Notif::EndFadeout)
    Fiber.yield while @ref.fade?
    @fiber = nil
  end
  
  def process_character(*args)
    super(*args)
    Fiber.yield
  end
  
end


class Scene_Map
  
  alias theo_typenotif_start start
  def start
    theo_typenotif_start
    @notif_text = Window_TypingNotif.new
  end
  
end
