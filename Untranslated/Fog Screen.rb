# =============================================================================
# TheoAllen - Fog Screen
# Version : 2.0b
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||={})[:Theo_FogScreen] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2015.03.04 - Prevent crash for updating nilClass
# 2013.08.24 - Rewrite script dengan workflow yang bueda banget (v2.0)
#            - Nambahin multiple fog support
#            - Support Kecepatan scroll lebih lambat (sekitar 0.1)
#            - Support map croll
#            - Support Battle Fog
#            - Ganti notetag fog pada peta
#            - Ilangin variasi opacity
# 2013.06.13 - Nambahin global fog (v1.3)
#            - Nambahin global disable switch
#            - Nambahin specific disable switch
# 2013.06.12 - Bug Fix. Saat pindah map fog ngga ilang (v1.15b)
# 2013.05.15 - Nambahin blend type (v1.15)
#            - Nambahin zoom
#            - Nambahin variasi opacity dan kecepatannya
# 2013.05.09 - Started and Finished script (v1.0)
# =============================================================================
=begin

  -----------------------------------------------------------------------------
  Pembukaan :
  Versi ini adalah versi rewrite besar-besaran dari versi 1.3. Jika kamu gunain
  script gw yg versi sbelumnya, semua cara penggunaan di versi sbelumnya ngga
  akan bekerja. Jadi maaf kalo u harus setting ulang dari awal
  
  -----------------------------------------------------------------------------
  Perkenalan :
  Script ini ngebikin kamu bisa nampilin fog seperti yang dimiliki RMXP.
  
  -----------------------------------------------------------------------------
  Cara penggunaan :
  Pasang dibawah material namun diatas main
  Edit konfigurasi database fognya
  Lalu untuk memasang fognya, kamu bisa gunakan script call kek gini
  
  Untuk nambah :
  add_fog(key)
  add_fog(key,fadein)
  
  Untuk ngilangin :
  delete_fog(key)
  delete_fog(key,fadeout)
  
  Note :
  - key adalah kata kunci yang ada di database fognya.
  - fadein/fadeout adalah kecepatan munculnya. Misalnya kamu isi 5, maka setiap
    frame, opacitynya akan nambah 5 sampe bates maksimal yg udah u tentuin
    di database. Kalo pengen instant munculnya, bisa diabaikan (ga diisi)
  - kamu ngga bisa nambahin fog dengan kata kunci yang sama dua kali
  
  clear_fogs
  ^
  untuk ngilangin semua fog secara langsung
  
  -----------------------------------------------------------------------------
  Notetag :
  Untuk gunain notetagnya cukup simple. Kamu tinggal kasi aja notetag dalam
  note map kek gini
  
  <add fog: key>
  
  -----------------------------------------------------------------------------
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

=end
# =============================================================================
# Konfigurasi :
# =============================================================================
module THEO
  module Fog
  # -------------------------------------------------------------------------  
  # Masukin ke battle scene?
  # -------------------------------------------------------------------------  
    BattleFog = true  
  # Set true kalo kamu pengen masukin fog jg di battle. Set false kalo ngga
    
  # -------------------------------------------------------------------------
  # Fog Database List ~
  # Level : Easy
  # -------------------------------------------------------------------------  
  # Paduan Konfigurasi
  #
  # key     => Adalah kata kunci untuk manggil fogmu (script call dan notetag)
  # name    => Nama file fog yg harus ada di Graphics/Pictures
  # opacity => Transparansi gambar fogmu (0 - 255)
  # speed_x => kecepatan scroll horizontal
  # speed_y => kecepatan scroll vertikal
  # zoom_x  => skala perbesaran horizontal (1.0 sama dengan normal)
  # zoom_y  => skala perbesaran vertikal (1.0 sama dengan normal)
  # -------------------------------------------------------------------------  
    List = {
    # "key"    => ["name", opacity, speed_x, speed_y, zoom_x, zoom_y]
      "kabut"  => ["fog",      128,     0.2,     0.2,    1.0,    1.0],
      "awan"   => ["cloud",     90,    -0.2,    -0.2,    2.0,    2.0],
      "badai"  => ["storm",     90,    -2.0,     2.0,    1.0,    1.0],
      "daun"   => ["leaf",      90,       0,       0,    2.0,    2.0],
    # Tambahin sendiri
    
    } # <-- Jangan disentuh ~ !
  # -------------------------------------------------------------------------  
  # Fog Extended Database List
  # Level : Hard
  # -------------------------------------------------------------------------
  # Disamping yang udah disebutin diatas (opacity, speed_x, dst ..) sbenernya
  # masih ada konfigurasi lainnya. Untuk alesan kerapian, jadi gw taruh
  # disini aja konfignya.
  #
  # Paduan konfigurasi :
  # Mulai dengan nulis kek gini
  # fog = fog_data["key"]
  #
  # Lalu tambahin attribut yg mo diubah. Misalnya gini
  # fog = fog_data["kabut"]
  # fog.name = "something"
  # fog.opacity = 100
  #
  # Berikut ini adalah list yg dapat kamu tambahin disamping yg udah wa
  # sediain diatas :
  # 
  # fog.switch      >> isinya ID switch (angka). Kalo switch hidup = invisible
  # fog.blend_type  >> Tipe blending. Pilih antara 0 - 2 (default : 0)
  # fog.tone        >> Isinya Tone.new(red, green, blue, gray) (kek Tint screen)
  # fog.z           >> koordinat z. Makin gede, makin ada diatas. Defaultnya
  #                    adalah 250 untuk setiap fog
  #
  # Untuk skala scroll
  # fog.scroll_scale_x >> skala horizontal 
  # fog.scroll_scale_y >> skala vertikal
  # 
  # Yang diatas ini buat skala scroll. Jika kamu ngisinya 0.0 maka ntar walo
  # mapnya nyekroll, fognya bakal tetep berada di tempat. Nilai defaultnya
  # adalah 1.0
  # ------------------------------------------------------------------------- 
    def self.custom_fogs
      fog = fog_data["daun"]
      fog.scroll_scale_x = 0.4
      fog.scroll_scale_y = 0.4
    end
    
  end
end
# =============================================================================
# Akhir dari konfigurasi. Setelah line ini semua adalah barang pribadi gw :v
# =============================================================================
module THEO
  module Fog
    def self.load_fogs
      List.each do |key,data|
        fog = fog_data[key]
        fog.name = data[0]
        fog.opacity = data[1]
        fog.speed_x = data[2]
        fog.speed_y = data[3]
        fog.zoom_x = data[4]
        fog.zoom_y = data[5]
      end
    end
    
    def self.fog_data
      $game_temp.fogs
    end    
  end
end

class << DataManager
  
  alias theo_fog_create_obj create_game_objects
  def create_game_objects
    theo_fog_create_obj
    THEO::Fog.load_fogs
    THEO::Fog.custom_fogs
  end
  
end

class DataFogs
  
  def initialize
    @data = {}
  end
  
  def [](key)
    @data[key] ||= Fog.new(key)
  end
  
end
  
class Fog
  attr_accessor :key
  attr_accessor :name
  attr_accessor :opacity
  attr_accessor :speed_x
  attr_accessor :speed_y
  attr_accessor :zoom_x
  attr_accessor :zoom_y
  attr_accessor :scroll_scale_x
  attr_accessor :scroll_scale_y
  attr_accessor :blend_type
  attr_accessor :tone
  attr_accessor :switch
  attr_accessor :z
  
  def initialize(key)
    @key = key
    @name = ""
    @opacity = 255
    @speed_x = 0.0
    @speed_y = 0.0
    @zoom_x = 1.0
    @zoom_y = 1.0
    @scroll_scale_x = 1.0
    @scroll_scale_y = 1.0
    @blend_type = 0
    @tone = Tone.new
    @switch = 0
    @z = 250
  end
  
  def visible
    !$game_switches[@switch]
  end
  
end

class Game_Temp
  attr_accessor :clear_fog
  attr_reader :fogs
  
  # --------------------------------------------------------------------------
  # They said that too much global variables isn't good. So, I used an
  # instance variable to store my fogs database =P
  # --------------------------------------------------------------------------
  alias theo_fog_init initialize
  def initialize
    theo_fog_init
    @fogs = DataFogs.new
    @clear_fog = false
  end
  
end

class Game_System
  attr_reader :used_fog
  
  alias theo_fog_init initialize
  def initialize
    theo_fog_init
    @used_fog = []
  end
  
end
# ----------------------------------------------------------------------------
# Altered Game Interpreter. For script call
# ----------------------------------------------------------------------------
class Game_Interpreter
  
  def clear_fogs
    $game_system.used_fog.clear
    $game_temp.clear_fog = true
    Fiber.yield
  end
  
  def get_fog(key)
    plane = planefogs
    return nil unless plane
    plane.get_fog(key)
  end
  
  def planefogs
    scene = SceneManager.scene
    spriteset = scene.instance_variable_get("@spriteset")
    return spriteset.instance_variable_get("@fogs")
  end
  
  def delete_fog(key,speed = 255)
    fog = get_fog(key)
    return unless fog
    $game_system.used_fog.delete(key)
    fog.fadeout(speed)
    fog.fade_delete = true
  end
  
  def add_fog(key,speed = 255)
    return if $game_system.used_fog.include?(key)
    $game_system.used_fog.push(key)
    fog = planefogs[key]
    fog.fadein(speed)
  end
  
end

class Game_Map
  attr_accessor :used_fogs
  
  alias theo_fog_init initialize
  def initialize
    theo_fog_init
    @used_fogs = []
  end
  
  alias theo_fog_setup setup
  def setup(map_id)
    theo_fog_setup(map_id)
    setup_fogs
  end
  
  def setup_fogs
    @used_fogs = []
    @map.note.split(/[\r\n]+/).each do |line|
      case line
      when /<(?:ADD_FOG|add fog): (.*)>/i
        key = $1.to_s
        next if @used_fogs.include?(key)
        @used_fogs.push(key)
      end
    end
  end
  
end

class PlaneFog < Plane
  attr_accessor :fade_delete
  attr_accessor :key
  
  def initialize(key, viewport)
    super(viewport)
    @real_ox = self.ox.to_f + rand(Graphics.width)
    @real_oy = self.oy.to_f + rand(Graphics.height)
    load_data(key)
    update_oxoy
    @fade = 0
    @fade_delete = false
  end
  
  def load_data(key)
    @data = THEO::Fog.fog_data[key]
    self.bitmap = Cache.picture(@data.name)
    @data.instance_variables.each do |varsymb|
      ivar_name = varsymb.to_s.gsub(/@/){""}
      eval("
      if self.respond_to?(\"#{ivar_name}\")
        self.#{ivar_name} = @data.#{ivar_name}
      end
      ")
    end
  end
  
  def fadeout(speed)
    @fade = -speed
  end
  
  def fadein(speed)
    @fade = speed
    self.opacity = 0
  end
  
  def spd_x
    @data.speed_x
  end
  
  def spd_y
    @data.speed_y
  end
  
  def update
    update_real_oxoy
    update_oxoy
    update_visible
    update_fade
  end
  
  def update_real_oxoy
    @real_ox += spd_x
    @real_oy += spd_y
  end
  
  def update_oxoy
    self.ox = fog_display_x + @real_ox
    self.oy = fog_display_y + @real_oy
  end
  
  def update_fade
    self.opacity = [[opacity + @fade,0].max,max_opacity].min
  end
  
  def max_opacity
    @data.opacity
  end
  
  def fog_display_x
    $game_map.display_x * (32.0 * @data.scroll_scale_x)
  end
  
  def fog_display_y
    $game_map.display_y * (32.0 * @data.scroll_scale_y)
  end
  
  def update_visible
    self.visible = @data.visible
  end
  
end

class PlaneFogs
  
  def initialize(viewport)
    @data = {}
    @viewport = viewport
    init_used_fog
  end
  
  def init_used_fog
    $game_system.used_fog.each do |fogname|
      self[fogname]
    end
  end
  
  def get_fog(key)
    @data[key]
  end
  
  def delete(key)
    fog = @data[key]
    return unless fog
    fog.dispose
    @data.delete(key)
  end
  
  def [](key)
    @data[key] ||= PlaneFog.new(key, @viewport)
  end
  
  def update
    update_basic
    @data.values.each {|fog| fog.update unless fog.disposed?}
  end
  
  def update_basic
    update_delete
    update_clear
  end
  
  def update_delete
    @data.values.each do |fog|
      next unless fog.fade_delete && fog.opacity == 0
      delete(fog.key)
      $game_system.used_fog.delete(fog.key)
    end
  end
  
  def update_clear
    if $game_temp.clear_fog
      @data.keys.each do |key|
        delete(key)
      end
      $game_temp.clear_fog = false
    end
  end
  
  def dispose
    @data.values.each {|fog| fog.dispose}
  end
  
end

class Mapfogs < PlaneFogs
  
  def init_used_fogs
    @used_fogs = $game_map.used_fogs.dup
    @used_fogs.each do |fogname|
      self[fogname]
    end
  end
  
  def update_basic
    update_used_fog
  end
  
  def update_used_fog
    if @used_fogs != $game_map.used_fogs
      delete_all
      init_used_fogs 
    end
  end
  
  def delete_all
    @data.values.each do |fog|
      delete(fog.key)
    end
  end
  
end

class Spriteset_Map
  
  alias theo_fog_viewports create_viewports
  def create_viewports
    theo_fog_viewports
    create_mapfogs
    create_global_fogs
  end
  
  def create_mapfogs
    @mapfogs = Mapfogs.new(@viewport1)
  end
  
  def create_global_fogs
    @fogs = PlaneFogs.new(@viewport1)
  end
  
  alias theo_fog_update update
  def update
    theo_fog_update
    update_global_fogs
    update_mapfogs
  end
  
  def update_global_fogs
    @fogs.update if @fogs
  end
  
  def update_mapfogs
    @mapfogs.update if @mapfogs
  end
  
  alias theo_fog_dispose dispose
  def dispose
    theo_fog_dispose
    dispose_global_fogs
    dispose_mapfogs
  end
  
  def dispose_global_fogs
    @fogs.dispose
  end
  
  def dispose_mapfogs
    @mapfogs.dispose    
  end
  
end

class Spriteset_Battle
  
  def use_fog?
    THEO::Fog::BattleFog
  end
  
  alias theo_fog_viewports create_viewports
  def create_viewports
    theo_fog_viewports
    return unless use_fog?
    create_mapfogs
    create_global_fogs
  end
  
  def create_mapfogs
    @mapfogs = Mapfogs.new(@viewport1)
  end
  
  def create_global_fogs
    @fogs = PlaneFogs.new(@viewport1)
  end
  
  alias theo_fog_update update
  def update
    theo_fog_update
    return unless use_fog?
    update_global_fogs
    update_mapfogs
  end
  
  def update_global_fogs
    @fogs.update if @fogs
  end
  
  def update_mapfogs
    @mapfogs.update if @mapfogs
  end
  
  alias theo_fog_dispose dispose
  def dispose
    theo_fog_dispose
    return unless use_fog?
    dispose_global_fogs
    dispose_mapfogs
  end
  
  def dispose_global_fogs
    @fogs.dispose
  end
  
  def dispose_mapfogs
    @mapfogs.dispose    
  end
  
end
