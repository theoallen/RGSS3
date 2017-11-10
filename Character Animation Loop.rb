# =============================================================================
# TheoAllen - Character Animation Loop
# Version : 1.0
# =============================================================================
($imported ||= {})[:Theo_CharAnimloop] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.02.12 - Finished script
# =============================================================================
=begin

  -----------------------------------------------------------------------------
  Intro :
  This script allow you to play animation on map sprite, loop it, and follow
  the character
  
  -----------------------------------------------------------------------------
  How to use :
  Put this script below material and above main
  Use these script call in SET MOVE ROUTE (pick one u need)
  
  animloop(id)
  animloop(id, mirror)
  animloop(id, mirror, rate)
  
  id > is animation id in database
  mirror > will animation will be mirrored? (true/false)
  rate > animation speed. Put in from range 1 ~ 4
  
  To stop animation, write a script call
  end_animloop
  
  -----------------------------------------------------------------------------
  Terms of use :
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.

=end
# =============================================================================
# Tidak ada konfigurasi. Jangan sentuh apapun di bawah ini
# =============================================================================
class Game_Character
  attr_accessor :animloop_id
  attr_accessor :animloop_mirror
  attr_accessor :animloop_rate
  
  alias theo_animloop_id_init initialize
  def initialize
    theo_animloop_id_init
    init_animloop_members
  end
  
  def init_animloop_members
    @animloop_id = 0
    @animloop_mirror = false
    @animloop_rate = 3
  end
  
  def animloop(id, mirror = false, rate = 3)
    @animloop_id = id
    @animloop_mirror = mirror
    @animloop_rate = rate
  end
  
  def end_animloop
    init_animloop_members
  end
  
end
# -----------------------------------------------------------------------------
# Pseudo Sprite for animation
# -----------------------------------------------------------------------------
class Char_Animloop < Sprite_Base  
  attr_reader :char_sprite
  
  def initialize(char_sprite)
    super(char_sprite.viewport)
    @char_sprite = char_sprite
    update_all
  end
  
  def update_all
    src_rect.set(char_sprite.src_rect)
    self.ox = char_sprite.ox
    self.oy = char_sprite.oy
    last_x = char_sprite.x - self.x
    last_y = char_sprite.y - self.y
    move_animation(last_x, last_y)
    self.x = char_sprite.x
    self.y = char_sprite.y
    self.z = char_sprite.z
  end
  
  def update
    super
    update_all
    setup_animation
  end
  
  def setup_animation
    if !animation? && character.animloop_id != 0
      @anim_id = character.animloop_id
      start_animation($data_animations[@anim_id], character.animloop_mirror)
    end
  end
  
  def character
    char_sprite.character
  end
  
  def end_animation
    if character.animloop_id == @anim_id
      @ani_duration = @animation.frame_max * @ani_rate + 1
    # Revert back
    elsif character.animloop_id != @anim_id && character.animloop_id != 0
      @anim_id = character.animloop_id
      start_animation($data_animations[@anim_id], character.animloop_mirror)
    # Change animation  
    else
      @anim_id = 0
      super
    # End animation
    end
  end
  
  def move_animation(dx, dy)
    if @animation && @animation.position != 3
      @ani_ox += dx
      @ani_oy += dy
      @ani_sprites.each do |sprite|
        sprite.x += dx
        sprite.y += dy
      end
    end
  end
  
  def set_animation_rate
    @ani_rate = character.animloop_rate
  end
  
end

class Sprite_Character
  
  alias theo_animloop_id_init initialize
  def initialize(*args)
    theo_animloop_id_init(*args)
    @sprite_animloop = Char_Animloop.new(self)
  end
  
  alias theo_animloop_id_update update
  def update
    theo_animloop_id_update
    @sprite_animloop.update if @sprite_animloop
  end
  
  alias theo_animloop_id_dispose dispose
  def dispose
    theo_animloop_id_dispose
    @sprite_animloop.dispose
  end
  
end
