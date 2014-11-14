#===============================================================================
# ASR script - Call Pictures v1.0
# Author : TheoAllen
# Requires : Theo Basic Modules - v1.2 or above
#-------------------------------------------------------------------------------
# Change Logs :
# 2014.11.14 - Released into public
# 2013.**.** - Completed
#===============================================================================
=begin

  -----------------------------------------------------------------------------
  *) Perkenalan :
  -----------------------------------------------------------------------------
  Script ini untuk mempermudah kamu untuk memanggil picture / gambar jika kamu
  ingin membuat dialog ala game Visual Novel

  -----------------------------------------------------------------------------
  *) Penggunaan dan Script call :
  -----------------------------------------------------------------------------
  Masukkan gambar yg mau dipanggil di Graphics/picture
  Gunain script call kek gini
  
  call_picture("nama", pos, flip, effect)
  - nama    >> nama file gambar
  - pos     >> pilih salah satu antara :A (kiri) dan :B (kanan)
  - flip    >> true/false. jika tidak diisi, maka defaultnya false
  - effect  >> effect yg mo ditampilin (listnya ada dibawah)
  
  clear_pictures
  ngilangin semua picture
  
  remove_pic(pos)
  ngilangin picture di posisi tertentu (:A ato :B)
  
  -----------------------------------------------------------------------------
  *) Effects List
  -----------------------------------------------------------------------------
  - fadein(durasi)        >> Bikin effect fadein dengan durasi tertentu
  - fadeout(durasi)       >> Bikin effect fadeout dengan durasi tertentu
  - scroll_in(durasi)     >> Bikin effect scroll masuk dengan durasi tertentu
  - scroll_out(durasi)    >> Bikin effect scroll keluar dengan durasi tertentu
  - opacity(nilai)        >> Ngubah opacity gambar (0 - 255)
  - pic_tone(r,g,b,gray)  >> Ngubah tone / tint gambar.
  - pic_wait              >> Menunggu selama efek fade / scroll / animasi
  - pic_animation(id)     >> Memainkan animasi. Ganti id dengan id animasi
  
  Contoh penggunaan dalam call picture :
  call_picture("name", :A, false, fadein(10), scroll_in(10), pic_wait)
  
  Kalo pengen langsung, bisa dengan gunain :
  pic_effect(:A, scroll_out(10))
  
  Note :
  Effect bisa dimasukin dua atau lebih
  
  -----------------------------------------------------------------------------
  *) Terms of Use :
  -----------------------------------------------------------------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.
  
=end
#==============================================================================
# Do not touch anything pass this line
#==============================================================================

#==============================================================================
# * Effects Table
#==============================================================================

module Effects
  Fadein      = 1
  Fadeout     = 2
  Scroll_in   = 3
  Scroll_out  = 4
  PicTone     = 5
  Opacity     = 6
  Wait        = 7
  Animation   = 8
end

#==============================================================================
# * Effect Data
#==============================================================================

class EffData
  #----------------------------------------------------------------------------
  # * Public accessor
  #----------------------------------------------------------------------------
  attr_accessor :eff_id
  attr_accessor :param
  #----------------------------------------------------------------------------
  # * Initialize
  #----------------------------------------------------------------------------
  def initialize
    @eff_id = 0
    @param = 0
  end
end

#==============================================================================
# * Game_Interpreter
#==============================================================================

class Game_Interpreter
  #----------------------------------------------------------------------------
  # * Alias
  #----------------------------------------------------------------------------
  A = :A  # Left
  B = :B  # Right
  #----------------------------------------------------------------------------
  # * Include
  #----------------------------------------------------------------------------
  include Effects
  #----------------------------------------------------------------------------
  # * Call picture
  #----------------------------------------------------------------------------
  def call_picture(picname, pos, flip = false, *args)
    return unless SceneManager.scene_is?(Scene_Map)
    pos = :B unless pos.is_a?(Symbol) && pos == :A
    picture = SceneManager.scene.getpic(pos)
    unless picture
      bitmap = Cache.picture(picname)
      picture = Picture.new(bitmap,pos)
      picture.mirror = flip
      SceneManager.scene.add_picture(picture, pos)
    else
      picture.bitmap = Cache.picture(picname)
      picture.update_position
      picture.mirror = flip
    end
    picture.wait = false
    args.each do |eff|
      picture.start_effect(eff)
    end
    Fiber.yield while picture.wait_for_effect?
  end
  #----------------------------------------------------------------------------
  # * Picture effect
  #----------------------------------------------------------------------------
  def pic_effect(pos, *args)
    return unless SceneManager.scene_is?(Scene_Map)
    pos = :B unless pos.is_a?(Symbol) && pos == :A
    picture = SceneManager.scene.getpic(pos)
    return unless picture
    picture.wait = false
    args.each do |eff|
      picture.start_effect(eff)
    end
    Fiber.yield while picture.wait_for_effect?
  end
  #----------------------------------------------------------------------------
  # * Clear pictures
  #----------------------------------------------------------------------------
  def clear_pictures
    return unless SceneManager.scene_is?(Scene_Map)
    SceneManager.scene.clear_pictures
  end
  #----------------------------------------------------------------------------
  # * Remove picture
  #----------------------------------------------------------------------------
  def remove_pic(pos)
    return unless SceneManager.scene_is?(Scene_Map)
    pos = :B unless pos.is_a?(Symbol) && pos == :A
    SceneManager.scene.remove_pic(pos)
  end
  #----------------------------------------------------------------------------
  # * Make effect
  #----------------------------------------------------------------------------
  def make_effect(eff_id, param = nil)
    effect = EffData.new
    effect.eff_id = eff_id
    effect.param = param
    return effect
  end
  #----------------------------------------------------------------------------
  # * Fadein
  #----------------------------------------------------------------------------
  def fadein(duration)
    return make_effect(Fadein,duration)
  end
  #----------------------------------------------------------------------------
  # * Fadeout
  #----------------------------------------------------------------------------
  def fadeout(duration)
    return make_effect(Fadeout,duration)
  end
  #----------------------------------------------------------------------------
  # * Scroll In
  #----------------------------------------------------------------------------
  def scroll_in(duration)
    return make_effect(Scroll_in,duration)
  end
  #----------------------------------------------------------------------------
  # * Scroll out
  #----------------------------------------------------------------------------
  def scroll_out(duration)
    return make_effect(Scroll_out,duration)
  end
  #----------------------------------------------------------------------------
  # * Pic Tone
  #----------------------------------------------------------------------------
  def pic_tone(r,g,b,gr = 0)
    tone = Tone.new(r,g,b,gr)
    return make_effect(PicTone,tone)
  end
  #----------------------------------------------------------------------------
  # * Opacity
  #----------------------------------------------------------------------------
  def opacity(value)
    return make_effect(Opacity,value)
  end
  #----------------------------------------------------------------------------
  # * Pic Wait
  #----------------------------------------------------------------------------
  def pic_wait
    return make_effect(Wait)
  end
  #----------------------------------------------------------------------------
  # * Pic Animation
  #----------------------------------------------------------------------------
  def pic_animation(anim_id)
    return make_effect(Animation, anim_id)
  end
  
end

#==============================================================================
# * Picture class to be displayed
#==============================================================================

class Picture < Sprite_Base
  #----------------------------------------------------------------------------
  # * Public Accessor
  #----------------------------------------------------------------------------
  attr_accessor :pos
  attr_accessor :max_opacity
  attr_accessor :wait
  #----------------------------------------------------------------------------
  # * Include
  #----------------------------------------------------------------------------
  include Effects
  #----------------------------------------------------------------------------
  # * Initialize
  #----------------------------------------------------------------------------
  def initialize(bitmap,pos)
    super(nil)
    self.max_opacity = 255
    self.bitmap = bitmap
    self.pos = pos
    update_anchor
    update_position
  end
  #----------------------------------------------------------------------------
  # * Update anchor
  #----------------------------------------------------------------------------
  def update_anchor
    self.oy = height
    self.ox = width/2
  end
  #----------------------------------------------------------------------------
  # * Update position
  #----------------------------------------------------------------------------
  def update_position
    self.y = Graphics.height
    if pos == :A
      self.x = width/2
    else
      self.x = Graphics.width - width/2
    end
  end
  #----------------------------------------------------------------------------
  # * Hide position
  #----------------------------------------------------------------------------
  def hide_position
    self.y = Graphics.height
    if pos == :A
      self.x = 0 - width/2
    else
      self.x = Graphics.width + width/2
    end
  end
  #----------------------------------------------------------------------------
  # * 
  #----------------------------------------------------------------------------
  def start_effect(effect)
    effect_table[effect.eff_id].call(effect.param)
  end
  #----------------------------------------------------------------------------
  # * Effect table
  #----------------------------------------------------------------------------
  def effect_table
    hash = {
      Fadein      => method(:start_fadein),
      Fadeout     => method(:start_fadeout),
      Scroll_in   => method(:scroll_in),
      Scroll_out  => method(:scroll_out),
      PicTone     => method(:tone_change),
      Opacity     => method(:change_opacity),
      Wait        => method(:method_wait),
      Animation   => method(:pic_animation),
    }
    return hash
  end
  #----------------------------------------------------------------------------
  # * Start Fadein
  #----------------------------------------------------------------------------
  def start_fadein(duration)
    self.opacity = 0
    self.fade(max_opacity, duration)
  end
  #----------------------------------------------------------------------------
  # * Start fadeout
  #----------------------------------------------------------------------------
  def start_fadeout(duration)
    self.opacity = max_opacity
    self.fadeout(duration)
  end
  #----------------------------------------------------------------------------
  # * Scroll In
  #----------------------------------------------------------------------------
  def scroll_in(duration)
    hide_position
    if pos == :A
      right(width,duration)
    else
      left(width,duration)
    end
  end
  #----------------------------------------------------------------------------
  # * Scroll out
  #----------------------------------------------------------------------------
  def scroll_out(duration)
    update_position
    if pos == :A
      left(width,duration)
    else
      right(width,duration)
    end
  end
  #----------------------------------------------------------------------------
  # * Tone Change
  #----------------------------------------------------------------------------
  def tone_change(tone)
    self.tone = tone
  end
  #----------------------------------------------------------------------------
  # * Change opacity
  #----------------------------------------------------------------------------
  def change_opacity(value)
    self.opacity = self.max_opacity = value
  end
  #----------------------------------------------------------------------------
  # * Method for wait
  #----------------------------------------------------------------------------
  def method_wait(value)
    @wait = true
  end
  #----------------------------------------------------------------------------
  # * Pic Animation
  #----------------------------------------------------------------------------
  def pic_animation(anim_id)
    start_animation($data_animations[anim_id])
  end
  #----------------------------------------------------------------------------
  # * Wait for effect?
  #----------------------------------------------------------------------------
  def wait_for_effect?
    @wait && (moving? || fade? || animation?)
  end
  
end

#==============================================================================
# * Scene_Map
#==============================================================================

class Scene_Map < Scene_Base
  #----------------------------------------------------------------------------
  # * Start
  #----------------------------------------------------------------------------
  alias asr_callpic_start start
  def start
    asr_callpic_start
    @called_pic = {}
  end
  #----------------------------------------------------------------------------
  # * Get picture
  #----------------------------------------------------------------------------
  def getpic(pos)
    @called_pic[pos]
  end
  #----------------------------------------------------------------------------
  # * Add picture
  #----------------------------------------------------------------------------
  def add_picture(sprite, pos)
    @called_pic[pos] = sprite
  end
  #----------------------------------------------------------------------------
  # * Clear pictures
  #----------------------------------------------------------------------------
  def clear_pictures
    dispose_pics
    @called_pic.clear
  end
  #----------------------------------------------------------------------------
  # * Remove picture
  #----------------------------------------------------------------------------
  def remove_pic(pos)
    @called_pic[pos].dispose
    @called_pic.delete(pos)
  end
  #----------------------------------------------------------------------------
  # * Dispose pic
  #----------------------------------------------------------------------------
  def dispose_pics
    @called_pic.each_value do |pic|
      pic.dispose if pic
    end
  end
  #----------------------------------------------------------------------------
  # * Update
  #----------------------------------------------------------------------------
  alias asr_callpic_update update
  def update
    asr_callpic_update
    update_pics
  end
  #----------------------------------------------------------------------------
  # * Update pictures
  #----------------------------------------------------------------------------
  def update_pics
    @called_pic.values.each {|pic| pic.update }
  end
  #----------------------------------------------------------------------------
  # * Terminate 
  #----------------------------------------------------------------------------
  alias asr_callpic_terminate terminate
  def terminate
    asr_callpic_terminate
    dispose_pics
  end
  
end

#==============================================================================
# * End of script
#==============================================================================
