# =============================================================================
# TheoAllen - Light Effect
# Version : 1.2b
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_LightFX] = true
# =============================================================================
# Change logs:
# -----------------------------------------------------------------------------
# 2015.08.26 - Fixed bug where light effect in event didn't updated
#            - Update compatibility with invisible region
# 2014.11.08 - Change light viewport.
#            - Support display light effect on player
# 2014.07.21 - Bugfix, fading function isn't working properly
# 2014.01.02 - Reduces Lag
# 2013.08.03 - Bugfix at event page condition
#            - Added fading funtion
# 2013.07.25 - Finished script
# =============================================================================
=begin

  Pembukaan :
  Berlatar belakang dari keluhan beberapa orang tentang script light effect
  untuk RGSS3 yang terkadang kelewat susah konfignya. Seperti punyanya Victor
  (Walo gw belom coba seh). Dan kelewat ngelag, (punya e Khas). 
  
  Beberapa orang pengen script light effect yang simple aja, kayak script
  Thomas Edison VX buatan BulletXT & Kylock. Akhirnya gw putusin, gw bikin 
  script yang serupa.
  
  Oh iya, disini gw bukan port script T.Edison VX ke Ace. Ane cuman ngambil
  idenya doank ama cara nyetingnya. Sisanya gw bikin dari 0 tanpa nyontek
  sedikitpun.
  
  Cara penggunaan :
  Pasang script ini dibawah material namun diatas main
  Sisanya bisa diliat di konfigurasi script
  
  Terms of Use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

  Note :
  Karena ini inspirasi dari BulletXT, alangkah baiknya kalo kamu juga credit
  dia.

=end
# =============================================================================
# Konfigurasi :
# =============================================================================
module Theo
  module Lights
    # ------------------------------------------------------------------------
    # General Setting (Settingan umum)
    # ------------------------------------------------------------------------
    DefaultName = "le" # Nama file yang harus ada di folder Graphics/Picture
    DefaultRate = 3    # Refresh rate. Makin kecil, makin sering refresh
    # ------------------------------------------------------------------------
    # Switch ID untuk tipe2 light effect. Kamu juga bisa nambahin tipe switch
    # kamu sendiri. Dengan syarat, huruf awal harus besar. 
    # ------------------------------------------------------------------------
    Fire  = 100
    Torch = 2
    Light = 3
    # ------------------------------------------------------------------------
    # Konfigurasi mode Simple :
    # ------------------------------------------------------------------------
    # Paduan Konfig :
    # - Keyword >> Nama light effect yang nanti digunakan dalam comment
    # - RGB     >> Nilai Red,Green,Blue. Antara -255 s.d 255
    # - Zoom    >> Nilai zoom light effectnya. 1.0 = normal
    # - Opacity >> Opacity light effectnya
    # - Var     >> Makin gede, makin bervariasi nilai opacitynya
    # - Offset  >> Jarak perpindahan dari posisi original
    # - Blend   >> Tipe blend. Pilih antara 0 - 2
    # - Switch  >> Switch ID untuk disable.
    #
    # Penggunaan dalam comment :
    # Gunakan comment pada event <light: keyword>
    # Contohnya <light: Fire>
    # Inget, besar kecil hurufnya harus sama :v
    #
    # Untuk menggunakan light effect pada karakter player, gunakan script call
    # $game_player.light_key = 'keyword'
    # ------------------------------------------------------------------------
    Database = {
    # Keyword => [  R,   G,   B, Zoom, Opacity, Var, Offset, Blend, Switch]
      "Fire1" => [128, -50,  -50, 2.5,     128, 10,      1,     1,   Fire],
      "Fire2" => [128, -50,  -50, 1.3,     128, 10,      1,     1,   Fire],
      "Blue"  => [-50, -25,  128, 2.5,     128, 10,      1,     1,   Fire],
     "Green"  => [ 50, 190,   50, 1.5,     128, 10,      1,     1,   Fire],
    "Green+"  => [ 50, 190,   50, 2.5,     128, 10,      1,     1,   Fire],
    "Yellow"  => [128, 128,   50, 1.9,     128, 10,      1,     1,   Fire],
      
      "Light" => [  0,   0,    0, 1.5,     200,   0,      0,     0,  Light],
    
    # Tambahin sendiri kalo perlu
    }
    # ------------------------------------------------------------------------
    # Konfigurasi mode Lanjut / Advanced
    # ------------------------------------------------------------------------
    # Bagian sini adalah konfigurasi yang lebih lanjut jika kamu masi tidak
    # puas dengan konfigurasi simple diatas. Tidak disarankan ngedit bagian 
    # sini kalo ngga ngerti 
    #
    # Paduan konfig :
    # Gunakan awalan seperti ini
    # light = $data_lights["keyword"]
    #
    # Lalu tambahkan variable yang akan diubah. Misalnya gini
    # light.name = "le"
    # light.red = 100
    # light.offset = 1
    #
    # Variable2 yang dapat diubah :
    # - light.name          = ngubah nama default gambar cahaynya
    # - light.red           = unsur merah (default : 0)
    # - light.green         = unsur hijau (default : 0)
    # - light.blue          = unsur biru (default : 0)
    # - light.gray          = unsur gray (default : 0)
    # - light.blink         = jika true, maka cahaya akan ngeblink 
    # - light.blink_rate    = blink refresh rate (default : DefaultRate)
    # - light.opacity       = nilai opacity (default : 255)
    # - light.opacity_var   = opacity variance (default : 0)
    # - light.opacity_rate  = opacity refresh rate (default : DefaultRate)
    # - light.offset        = nilai offset (default : 0)
    # - light.offset_rate   = offset refresh rate (default : DefaultRate)
    # - light.zoom          = nilai zoom (default : 1.0)
    # - light.switch        = switch id (default : 0)
    # - light.buffer_x      = Jarak X dari event (default : 0)
    # - light.buffer_y      = Jarak Y dari event (default : -15)
    # - light.fading_speed  = Kecepatan ilang muncul (default : 0)
    # - light.blend_type    = Tipe blending. Pilih antara 0 - 2 (default : 0)
    # ------------------------------------------------------------------------
    def self.load_custom_database
      
      light = $data_lights["Orb"]
      light.red = -120
      light.green = -20
      light.blue = 150
      light.zoom = 3.0
      light.opacity = 150
      light.fading_speed = 1.5
      light.blend_type = 1
      light.switch = 100
      
      light = $data_lights["Lamp"]
      light.buffer_y = 5
      light.zoom = 2.0
      light.switch = 2
      
      light = $data_lights["Lamp2"]
      light.name = "le2"
      light.buffer_y = 5
      light.opacity = 150
      light.opacity_var = 50
      light.opacity_rate = 1
      light.switch = 2
      
      light = $data_lights["Fire1"]
      light.buffer_x = 2
      light.buffer_y = -16
      
      light = $data_lights["Fire2"]
      light.buffer_x = 2
      light.buffer_y = -16
      
      light = $data_lights["Orb2"]
      light.red = -120
      light.green = -20
      light.blue = 150
      light.zoom = 2.8
      light.opacity = 150
      light.fading_speed = 0
      light.blend_type = 1
      light.buffer_y = - 32
      light.switch = 100
      
    end
  end
end
# =============================================================================
# Akhir dari konfigurasi
# =============================================================================
module Theo
  module Lights
    def self.load_database
      Database.each do |key,data|
        light = $data_lights[key]
        light.red = data[0]
        light.green = data[1]
        light.blue = data[2]
        light.zoom = data[3]
        light.opacity = data[4]
        light.opacity_var = data[5]
        light.offset = data[6]
        light.blend_type = data[7]
        light.switch = data[8]
        light.offset_rate = light.opacity_rate = light.blink_rate = DefaultRate
        light.name = DefaultName
      end
    end
  end
end

module Math
  def self.radian(degree)
    return (degree.to_f/180) * Math::PI
  end
end

class Data_Light
  attr_reader :key
  attr_accessor :name
  attr_accessor :red
  attr_accessor :green
  attr_accessor :gray
  attr_accessor :blue
  attr_accessor :blink
  attr_accessor :blink_rate
  attr_accessor :opacity
  attr_accessor :opacity_rate
  attr_accessor :opacity_var
  attr_accessor :offset
  attr_accessor :offset_rate
  attr_accessor :blend_type
  attr_accessor :zoom
  attr_accessor :switch
  attr_accessor :buffer_x
  attr_accessor :buffer_y
  attr_accessor :fading_speed
  
  def initialize(key)
    @key = key
    @name = Theo::Lights::DefaultName
    @red = @green = @blue = @gray = 0
    @blink = false
    @blink_rate = 0
    @opacity = 255
    @opacity_rate = 0
    @opacity_var = 0
    @offset = 0
    @offset_rate = 0
    @blend_type = 0
    @zoom = 1.0
    @switch = 0
    @buffer_x = 0
    @buffer_y = -15
    @fading_speed = 0
  end
  
  def tone
    Tone.new(red,green,blue,gray)
  end
  
end

class << DataManager
  
  alias theo_le_load_db load_database
  def load_database
    theo_le_load_db
    load_le_database
  end
  
  def load_le_database
    $data_lights = Data_Lights.new
    Theo::Lights.load_database
    Theo::Lights.load_custom_database
  end
  
end

class Data_Lights
  
  def initialize
    @data = {}
  end
  
  def [](key)
    @data[key] ||= Data_Light.new(key)
  end
  
end

class Game_Event < Game_Character
  attr_accessor :light_key
  attr_writer :light_start_count
  
  alias theo_sle_page_settings setup_page_settings
  def setup_page_settings
    theo_sle_page_settings
    setup_light_key
  end
  
  def setup_light_key
    @light_key = ""
    @light_start_count = 0
    return unless list
    list.each do |command|
      next unless command.code == 108 || command.code == 408
      case command.parameters[0]
      when /<light\s*:\s*(.+)>/i
        @light_key = $1.to_s
      when /<light[\s_]start[\s_]count\s*:\s*(\d+)>/i
        @light_start_count = $1.to_i
      when /<light[\s_]rand[\s_]count\s*:\s*(\d+)>/i
        @light_start_count = rand($1.to_i)
      end
    end
  end
  
  def light_start_count
    @light_start_count ||= 0
  end
  
  def in_screen?
    near_the_screen?(14, 10)
  end
  
end

class Game_Player
  attr_writer :light_start_count
  attr_writer :light_key
  
  def light_key
    @light_key ||= ""
  end
  
  def light_start_count
    @light_start_count ||= 0
  end
  
  def in_screen?
    return true
  end
  
end
# ----------------------------------------------------------------------------
# Unique Names for compatibility purposes :P
# ----------------------------------------------------------------------------
class Theo_LightFX < Sprite
  
  def initialize(char, viewport = nil)
    super(viewport)
    @char = char
    init_members
    setup(@char.light_key)
  end
  
  def setup(key)
    @key = key.nil? ? "" : key
    if @key.empty?
      return
    end
    setup_database(key)
    self.ox = self.width/2
    self.oy = self.height/2
    self.z = 250
  end
  
  def init_members
    self.bitmap = nil
    @offset = @offset_x = @offset_y = @buffer_x = @buffer_y = @opacity_var = 0
    @switch = 0
    @blink = false
    @blink_rate = @opacity_rate = @offset_rate = Theo::Lights::DefaultRate
    @op_count = @count = @char.light_start_count
    @op_fade = 0
    @ori_opacity = 255
    @opacity_offset = 0
    @show_light = true
  end
  
  def setup_database(key)
    le = $data_lights[key]
    self.bitmap = Cache.picture(le.name)
    self.tone = le.tone
    @ori_opacity=self.opacity=le.fading_speed > 0 ? le.opacity/2.0 : le.opacity
    self.blend_type = le.blend_type
    @blink = le.blink
    @blink_rate = le.blink_rate
    @opacity_rate = le.opacity_rate
    @opacity_var = le.opacity_var
    @offset = le.offset
    @offset_rate = le.offset_rate
    self.zoom_x = self.zoom_y = le.zoom
    @switch = le.switch
    @buffer_x = le.buffer_x
    @buffer_y = le.buffer_y
    @op_fade = le.fading_speed > 0 ? @ori_opacity : 0
    update_placement
    check_blink
    update_op_fade
    update_opacity
  end
  
  def check_blink
    return if @blink_rate == 0 || !@blink
    @show_light = !@show_light if (@count/@blink_rate) % 2 == 0
  end
  
  def update
    setup(@char.light_key) if light_changed?
    super
    @count += 1
    update_placement
    update_op_fade
    return if !@char.in_screen?
    update_offset
    update_visibility
    update_blink
    update_opacity
  end
  
  def update_placement
    self.x = @char.screen_x + @buffer_x + @offset_x
    self.y = @char.screen_y + @buffer_y + @offset_y
  end
  
  def update_offset
    return unless refresh_count?(@offset_rate)
    return if @offset <= 0
    @offset_x = -@offset + rand(@offset*2)
    @offset_y = -@offset + rand(@offset*2)
  end
  
  def update_visibility
    self.visible = !$game_switches[@switch] && @show_light
  end
  
  def update_blink
    return unless @blink
    return unless refresh_count?(@blink_rate)
    @show_light = !@show_light
  end
  
  def update_opacity
    self.opacity = @ori_opacity + @opacity_offset + @op_fade
    self.opacity = 0 if @char.opacity == 0 && $imported[:Theo_InvisRegion]
    return unless refresh_count?(@opacity_rate)
    @opacity_offset = -@opacity_var + rand(@opacity_var*2)
  end
  
  def update_op_fade
    return unless $data_lights[@key].fading_speed > 0
    @op_count += $data_lights[@key].fading_speed
    @op_fade = Math.cos(Math.radian(@op_count)) * @ori_opacity
  end
  
  def refresh_count?(rate)
    return false if rate <= 0
    return @count % rate == 0
  end  
  
  def light_changed?
    @key != @char.light_key
  end
  
end

class Spriteset_Map
  
  alias theo_le_create_char create_characters
  def create_characters
    theo_le_create_char
    @simple_lights = []
    $game_map.events.values.each do |char|
      @simple_lights.push(Theo_LightFX.new(char,@viewport1))
    end
    @simple_lights << Theo_LightFX.new($game_player, @viewport1)
    Graphics.frame_reset
  end
  
  alias theo_le_update update
  def update
    theo_le_update
    update_simple_lights
  end
  
  def update_simple_lights
    @simple_lights.each do |light|
      light.update
    end
  end
  
  alias theo_sle_dispose_char dispose_characters
  def dispose_characters
    theo_sle_dispose_char
    @simple_lights.each {|light| light.dispose}
  end
  
end
