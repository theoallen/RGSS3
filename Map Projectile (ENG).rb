# =============================================================================
# TheoAllen - Map Projectiles
# Version : 1.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (English Language)
# -----------------------------------------------------------------------------
# Require : Theo - Basic Modules v1.3 or more
# > Object Core Movement
# =============================================================================
($imported ||= {})[:Theo_MapProjectile] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.06.29 - Finished script
# =============================================================================
=begin
  
  -----------------------------------------------------------------------------
  Introduction :
  -----------------------------------------------------------------------------
  This script allow you to show projectile on map. Basically, it just show 
  projectile from starting character to target character. It doesn't do
  anything except only showing projectiles. 
  
  The main purpose of this script is for storytelling. Do not expect any Action 
  Battle System or an event triggered when got hit by the projectile.
  
  -----------------------------------------------------------------------------
  How to use :
  -----------------------------------------------------------------------------
  Put this script below material but above main. Don't forget to put my basic
  module as well.
  
  There're two ways to show projectile. By event script call or by move route
  script call.
  
  ---------------------------
  Event script call :
  Put this line in script call
  show_proj(subject, target, duration, anim_id, hit_anim)
  
  Replace the parameter by this following rules :
  *) subject  >> event ID for starting projectile. 0 for player. And put "self"
                 (without quotation) if you want to start projectile from 
                 current event
  *) target   >> event ID for projectile target. 0 for player. And put "self"
                 (without quotation) if you want to current event as the 
                 projectile target
  *) duration >> Travel duration in frame. 60 frames same as 1 second.
  *) anim_id  >> Animation ID which will be played in projectile
  *) hit_anim >> Animation ID which will be played in character once it got
                 hit. Can be ommited if isn't necessary
  
  ---------------------------
  Move route script call :
  Note that move route script call always start projectile from self. Put this 
  line in script call
  
  show_proj(target, duration, anim_id, hit_anim)
  
  Replace the parameter by this following rules :
  *) target   >> event ID for projectile target. 0 for player.
  *) duration >> Travel duration in frame. 60 frames same as 1 second.
  *) anim_id  >> Animation ID which will be played in projectile
  *) hit_anim >> Animation ID which will be played in character once it got
                 hit. Can be ommited if isn't necessary

=end
# =============================================================================
# No configuration. Do not edit pass this line!
# =============================================================================
class Game_Interpreter
  
  def show_proj(subject, target, duration, anim_id, on_hit_anim = 0)
    sub = get_object(subject)
    tar = get_object(target)
    proj = Map_Projectile.new(sub,tar,anim_id,duration,on_hit_anim)
    $game_temp.map_projectiles.push(proj)
  end
  
  def get_object(key)
    obj = key
    obj = $game_map.events[key] if key.is_a?(Numeric)
    obj = $game_player if key == 0
    obj = $game_map.events[@event_id] if key == self
    return obj
  end
  
end

class Game_Character
  
  def show_proj(target, duration, anim_id, on_hit_anim = 0)
    tar = get_object(target)
    proj = Map_Projectile.new(self,tar,anim_id,duration,on_hit_anim)
    $game_temp.map_projectiles.push(proj)
  end
  
  def get_object(key)
    obj = key
    obj = $game_map.events[key] if key.is_a?(Numeric)
    obj = $game_player if key == 0
    return obj
  end
  
end

class Game_Temp
  attr_accessor :map_projectiles
  
  alias theo_mproj_init initialize
  def initialize
    theo_mproj_init
    @map_projectiles = []
  end
  
end

class Map_Projectile
  attr_accessor :sub, :target, :anim_id, :duration, :on_hit_anim
  def initialize(sub, target, anim_id, duration, on_hit_anim)
    @sub = sub 
    @target = target 
    @anim_id = anim_id
    @duration = duration
    @on_hit_anim = on_hit_anim
  end
end

class Sprite_MapProj < Sprite_Base
  
  def initialize(vport, proj_data)
    super(vport)
    @data = proj_data
    set_position
    goto(@data.target.screen_x, @data.target.screen_y - 16, @data.duration)
    start_animation($data_animations[@data.anim_id])
  end
  
  def set_position
    self.x = @data.sub.screen_x
    self.y = @data.sub.screen_y - 16
  end
  
  def end_animation
    @ani_duration = @animation.frame_max * @ani_rate + 1
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
  
  def update_last_coordinate
    @last_x = x
    @last_y = y
  end
  
  def update
    super
    process_dispose if need_dispose?
  end
  
  def update_move
    update_last_coordinate
    super
    move_animation(diff_x, diff_y)
  end
  
  def diff_x
    self.x - @last_x
  end
  
  def diff_y
    self.y - @last_y
  end
  
  def need_dispose?
    !moving?
  end
  
  def process_dispose
    @data.target.animation_id = @data.on_hit_anim
    # To prevent one frameskip on display hit animation
    SceneManager.scene.spriteset.get_character(@data.target).update
    dispose
  end
  
end

class Spriteset_Map
  
  alias theo_mproj_init initialize
  def initialize
    @projectiles = []
    theo_mproj_init
  end
  
  alias theo_mproj_update update
  def update
    theo_mproj_update
    update_projectiles
  end
  
  def update_projectiles
    @projectiles.delete_if do |proj|
      proj.update
      proj.disposed?
    end
    until $game_temp.map_projectiles.empty?
      new_proj = Sprite_MapProj.new(@viewport1, $game_temp.map_projectiles.pop)
      @projectiles.push(new_proj)
    end
  end
  
  alias theo_mproj_dispose dispose
  def dispose
    theo_mproj_dispose
    dispose_projectiles
  end
  
  def dispose_projectiles
    @projectiles.each do |proj|
      proj.dispose
    end
  end
  
  def get_character(game_char)
    @character_sprites.each do |sprite| 
      return sprite if sprite.character == game_char
    end
    return nil
  end
  
end

class Scene_Map
  attr_reader :spriteset
end
