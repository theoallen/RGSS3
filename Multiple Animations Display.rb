# =============================================================================
# TheoAllen - Multiple Animations Display
# Version : 1.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (English Documentation)
# -----------------------------------------------------------------------------
# Requested by : LadyMinerva
# =============================================================================
($imported ||= {})[:Theo_MultiAnime] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.06.25 - Ported from TSBS addons. Now can be used independently
#            - Got rid some unused codes
# 2014.06.23 - Multiple animation on animation guard
# 2014.05.13 - Fixed wrong animation flash target
# 2014.05.02 - Finished script
# =============================================================================
=begin

  -------------------------------------------------------------------
  Introduction :
  By default, the animation only can hold up to 16 pictures. It's sometimes
  prevent you to do some crazy animations. By adding this script, now you can
  merge two different animations, mix them in a single animation call. However,
  you still can not see them in editor at once. So, use your imagination =D
  
  -------------------------------------------------------------------
  How to use :
  Put this script below material but above main.
  
  There're two ways to setting up animation. The first way is to deal with
  the configuration below. The second one is to add notetag in animation name
  since there's no notebox in animation database.
  
  The notetag is
  <link: id,id,id>
  
  id is an animation id that will be linked / merged to current animation. You
  may add it as many as you want.
  
  -------------------------------------------------------------------
  Terms of use :
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.  

=end
# =============================================================================
# Configuration
# =============================================================================
module Theo
  module MultiAnime
    # ------------------------------------------------------------------------
    # In script configuration. Record the animation links here. You make put
    # multiple animation link by put them in array / inside [].
    # 
    # Format :
    # anim_id => link,
    # anim_id => [link1, link2, link3],
    #
    # Anim_id is animation in database as a base which hold animation links
    # to call other animation. Don't forget to add comma!
    # ------------------------------------------------------------------------
      AnimeList = {    
        89 => 92,
        # Add more here
        
      } # <-- dont touch
    # ------------------------------------------------------------------------
    
    # ------------------------------------------------------------------------
    # Regular expression to read the notetag in animation name in database.
    # Do not touch if you don't understand Ruby REGEXP
      Regex = /<link\s*:\s*(.+)>/i
    # ------------------------------------------------------------------------
  end
end
# =============================================================================
# End Configuration
# =============================================================================
class RPG::Animation
  
  def anime_links
    return @anime_links if @anime_links
    @anime_links = []
    if name[Theo::MultiAnime::Regex]
      $1.split(/,/).each do |anim_id|
        @anime_links.push(anim_id.to_i)
      end
    end
    return @anime_links
  end
  
end
# -----------------------------------------------------------------------------
# Sprite multiple animation
# -----------------------------------------------------------------------------
class Sprite_MultiAnime < Sprite_Base
  
  def initialize(viewport, ref_sprite, anime, flip = false)
    super(viewport)
    @ref_sprite = ref_sprite
    update_reference_sprite
    start_animation(anime, flip)
  end
  
  def update
    update_reference_sprite
    super
    dispose if !animation?
  end
  
  def update_reference_sprite
    src_rect.set(@ref_sprite.src_rect)
    self.ox = @ref_sprite.ox
    self.oy = @ref_sprite.oy
    self.x = @ref_sprite.x
    self.y = @ref_sprite.y
    self.z = @ref_sprite.z
  end
  # Overwrite animation process timing
  def animation_process_timing(timing)
    timing.se.play unless @ani_duplicated
    case timing.flash_scope
    when 1
      @ref_sprite.flash(timing.flash_color, timing.flash_duration * @ani_rate)
    when 2
      if viewport && !@ani_duplicated
        viewport.flash(timing.flash_color, timing.flash_duration * @ani_rate)
      end
    when 3
      @ref_sprite.flash(nil, timing.flash_duration * @ani_rate)
    end
  end
  
end
# -----------------------------------------------------------------------------
# Sprite Battler
# -----------------------------------------------------------------------------
class Sprite_Battler
  attr_reader :multianimes
  
  alias theo_multianim_init initialize
  def initialize(viewport, battler = nil)
    @multianimes = []
    theo_multianim_init(viewport, battler)
  end
  
  alias theo_multianime_start_anim start_animation
  def start_animation(anime, flip = false)
    if @animation
      spr_anim = Sprite_MultiAnime.new(viewport, self, anime, flip)
      multianimes.push(spr_anim)
    else
      theo_multianime_start_anim(anime, flip)
      multianime = @animation.anime_links
      check_multi = Theo::MultiAnime::AnimeList[@animation.id]
      if check_multi.is_a?(Array)
        multianime += check_multi
      elsif check_multi
        multianime += [check_multi]
      end
      multianime.each do |ma|
        start_animation($data_animations[ma], flip)
      end
    end
  end
  
  alias theo_multianim_update update
  def update
    theo_multianim_update
    multianimes.delete_if do |anime|
      anime.update
      anime.disposed?
    end
  end
  
  alias theo_multianim_dispose dispose
  def dispose
    theo_multianim_dispose
    multianimes.each do |anime|
      anime.dispose
    end
  end
  
  def animation?
    @animation || !multianimes.empty?
  end
  
  alias theo_multianime_update_anim update_animation
  def update_animation
    return unless @animation
    theo_multianime_update_anim
  end
  
end
# -----------------------------------------------------------------------------
# Sprite Character
# -----------------------------------------------------------------------------
class Sprite_Character
  attr_reader :multianimes
  
  alias theo_multianim_init initialize
  def initialize(viewport, char = nil)
    @multianimes = []
    theo_multianim_init(viewport, char)
  end
  
  alias theo_multianime_start_anim start_animation
  def start_animation(anime, flip = false)
    if @animation
      spr_anim = Sprite_MultiAnime.new(viewport, self, anime, flip)
      multianimes.push(spr_anim)
    else
      theo_multianime_start_anim(anime, flip)
      multianime = @animation.anime_links
      check_multi = Theo::MultiAnime::AnimeList[@animation.id]
      if check_multi.is_a?(Array)
        multianime += check_multi
      elsif check_multi
        multianime += [check_multi]
      end
      multianime.each do |ma|
        start_animation($data_animations[ma], flip)
      end
    end
  end
  
  alias theo_multianim_update update
  def update
    theo_multianim_update
    multianimes.delete_if do |anime|
      anime.update
      anime.disposed?
    end
  end
  
  alias theo_multianim_dispose dispose
  def dispose
    theo_multianim_dispose
    multianimes.each do |anime|
      anime.dispose
    end
  end
  
  def animation?
    @animation || !multianimes.empty?
  end
  
  alias theo_multianime_update_anim update_animation
  def update_animation
    return unless @animation
    theo_multianime_update_anim
  end
  
end
