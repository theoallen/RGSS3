# =============================================================================
# TheoAllen - Character Animation Loop
# Version : 1.1b
# =============================================================================
($imported ||= {})[:Theo_CharAnimloop] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2018.08.07 - Added bottom flag
# 2018.07.15 - Fixes script efficiency for less fps drop
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
  animloop(id, mirror, rate, bottom)
  
  id      > animation id in database
  mirror  > will animation will be mirrored? (true/false)
  rate    > animation speed. Put in from range 1 ~ 4
  bottom  > true/false. If set to true, will play behind the sprite. Default
            is false
  
  If you just want to play animation on the back, just have to fill ALL the
  others even though u don't need it. For example
  
  animloop(66, false, 3, true)
            
  To stop animation, write a script call
  end_animloop
  
  -----------------------------------------------------------------------------
  Terms of use :
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.

=end
#==============================================================================
# No config whatsoever
#==============================================================================
class Game_Character
  attr_accessor :animloop_id
  attr_accessor :animloop_mirror
  attr_accessor :animloop_rate
  attr_accessor :animloop_bottom
  
  alias theo_animloop_id_init initialize
  def initialize
    theo_animloop_id_init
    init_animloop_members
  end
  
  def init_animloop_members
    @animloop_id = 0
    @animloop_mirror = false
    @animloop_rate = 3
    @animloop_bottom = false
  end
  
  def animloop(id, mirror = false, rate = 3, bottom = false)
    @animloop_id = id
    @animloop_mirror = mirror
    @animloop_rate = rate
    @animloop_bottom = bottom
    sprset = get_spriteset
    return unless sprset
    spr = get_spriteset.get_sprite(self)
    get_spriteset.get_sprite(self).end_animation if spr
  end
  
  def end_animloop
    init_animloop_members
  end
  
  def animloop_id
    return @animloop_id ||= 0
  end
  
end
#------------------------------------------------------------------------------
# Pseudo Sprite for animation
#------------------------------------------------------------------------------
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
  
    def animation_set_sprites(frame)
    cell_data = frame.cell_data
    @ani_sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      sprite.bitmap = pattern < 100 ? @ani_bitmap1 : @ani_bitmap2
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @ani_mirror
        sprite.x = @ani_ox - cell_data[i, 1]
        sprite.y = @ani_oy + cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = @ani_ox + cell_data[i, 1]
        sprite.y = @ani_oy + cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      zpos = character.animloop_bottom ? 50 - 17 : 300
      sprite.z = self.z + zpos + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
  
end

class Sprite_Character
  
  alias theo_animloop_id_update update
  def update
    theo_animloop_id_update
    if character.animloop_id > 0 && !@sprite_animloop
      @sprite_animloop = Char_Animloop.new(self)
    end
    @sprite_animloop.update if @sprite_animloop
  end
  
  alias theo_animloop_id_dispose dispose
  def dispose
    theo_animloop_id_dispose
    @sprite_animloop.dispose if @sprite_animloop
  end
  
end

class Spriteset_Map
  
  def get_sprite(char)
    @character_sprites.find {|c| c.character == char}
  end
  
end
