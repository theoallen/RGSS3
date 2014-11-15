#===============================================================================
# TheoAllen - Character Shadow
# Version : 1.0
# Language : Informal Indonesian
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#-------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://www.theolized.com
#===============================================================================
($imported ||= {})[:Theo_CharShadow] = true
#===============================================================================
# Change Logs:
# ------------------------------------------------------------------------------
# 2013.11.16 - Finished
#===============================================================================
=begin

  --------------------
  *) Perkenalan :
  --------------------
  Script ini memberikan efek shadow sederhana pada karakter. Yup, gitu doang :3
  
  --------------------
  *) Cara penggunaan :
  --------------------
  Pasang script ini di bawah material namun di atas main.
  Script ini plug n play, dalam artian kamu ngga perlu ngasi konfigurasi
  tambahan.
  
  Catatan :
  Bayangan ngga bakal keluar pada beberapa kasus berikut ini :
  
  > Karakter kendaraan macem pesawat atau perahu
  > Jika event / karakter ngga mempunyai gambar
  > Jika nama karakter mengandung '!'
  > Jika kamu menggunakan gambar tileset
  > Jika karakter dalam keadaan Transparent ON
  > Jika event terhapus pake erase event
  
  --------------------
  *) Terms of Use :
  --------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

=end
#===============================================================================
# * Game_CharacterBase
#===============================================================================
class Game_CharacterBase
  #-----------------------------------------------------------------------------
  # * Real position Y on screen
  #-----------------------------------------------------------------------------
  def screen_real_y
    $game_map.adjust_y(@real_y) * 32 + 32
  end
  #-----------------------------------------------------------------------------
  # * Shadow exist?
  #-----------------------------------------------------------------------------
  def shadow_exist?
    !@character_name.empty? && !@transparent && !object_character?
  end
  
end

#===============================================================================
# * Game_Event
#===============================================================================

class Game_Event
  #-----------------------------------------------------------------------------
  # * Shadow Exist?
  #-----------------------------------------------------------------------------
  def shadow_exist?
    return false if @erased
    return super
  end
  
end

#===============================================================================
# * Game_Vehicle
#===============================================================================

class Game_Vehicle
  #-----------------------------------------------------------------------------
  # * Shadow Exist?
  #-----------------------------------------------------------------------------
  def shadow_exist?
    return false
  end
  
end

#===============================================================================
# * Sprite_CharShadow
#===============================================================================

class Sprite_CharShadow < Sprite
  #-----------------------------------------------------------------------------
  # * Public attribute
  #-----------------------------------------------------------------------------
  attr_accessor :character
  #-----------------------------------------------------------------------------
  # * Initialize
  #-----------------------------------------------------------------------------
  def initialize(vport, char)
    super(vport)
    self.bitmap = Cache.system('Shadow')
    self.ox = width/2
    self.oy = height
    self.z = 50
    @character = char
    update
  end
  #-----------------------------------------------------------------------------
  # * Update
  #-----------------------------------------------------------------------------
  def update
    super
    if @character
      self.y = @character.screen_real_y
      self.x = @character.screen_x
      self.opacity = @character.opacity
      self.visible = @character.shadow_exist?
    else
      self.visible = false
    end
  end
  
end

#===============================================================================
# * Sprite_Character
#===============================================================================

class Sprite_Character
  #-----------------------------------------------------------------------------
  # * Initialize
  #-----------------------------------------------------------------------------
  alias theo_charshadow_init initialize
  def initialize(vport, char = nil)
    @shadow = Sprite_CharShadow.new(vport, char)
    theo_charshadow_init(vport, char)
  end
  #-----------------------------------------------------------------------------
  # * Character=
  #-----------------------------------------------------------------------------
  alias theo_charshadow= character=
  def character=(char)
    self.theo_charshadow = char
    @shadow.character = char
  end
  #-----------------------------------------------------------------------------
  # * Update
  #-----------------------------------------------------------------------------
  alias theo_charshadow_update update
  def update
    theo_charshadow_update
    @shadow.update
  end
  #-----------------------------------------------------------------------------
  # * Dispose
  #-----------------------------------------------------------------------------
  alias theo_charshadow_dispose dispose
  def dispose
    theo_charshadow_dispose
    @shadow.dispose
  end
  
end
