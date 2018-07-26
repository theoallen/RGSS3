# =============================================================================
# TheoAllen - Animated Battleback
# Version : 1.0c
# Contact : Discord @ Theo#3034
# =============================================================================
($imported ||= {})[:Theo_AnimBattleBack] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2018.07.26 - Translated + Added handler
# 2014.07.15 - Fixed bug where you couldn't put unanimated battleback
# 2013.10.28 - Finished script
# =============================================================================
=begin
  
  ------------------------------------------------------------------------
  Introduction :
  ------------------------------------------------------------------------
  Want an animated battle back? This script might be the one you're looking for
  
  ------------------------------------------------------------------------
  How to use :
  ------------------------------------------------------------------------
  Put this script under Materials.
  Create a folder, named "AnimBattleBack" inside folder Graphics. 
  
  Prepare your background image using this naming pattern "filename_01.png".
  Next image goes the same except increasing the index like "filename_02.png".
  You may put as many frame as you want. As long as you're keeping the index
  like "_03.png", "_04.png", and so on.
  
  To use animated battleback for a certain map, use map notetag
  <anim bb: anim_key>, where "anim_key" is a "key" that is defined in the 
  configuration below. 
  
  ------------------------------------------------------------------------
  Terms of use :
  ------------------------------------------------------------------------
  > Credit goes to TheoAllen.
  > Free for non-commercial. Give free copy if commercial..

=end
# =============================================================================
# Configuration
# =============================================================================
module Theo
  module AnimBB
  # --------------------------------------------------------------------------
  # Animated Battleback Database
  # --------------------------------------------------------------------------
  # Config instruction :
  #
  # Key     --> Keyword to be used in notetag on map properties
  # Name    --> Basic file name (not including its index like "_01.png")
  # Frame   --> Maximum frame index
  # Rate    --> Refresh rate. The lower, the faster it will be
  # --------------------------------------------------------------------------
    List = {
  # "Key"     => ["Name"      , Frame, Rate],
    "mansion" => ["mansion"   ,     8,    4],
    "dtown"   => ["deserttown",     7,   10],
  
  # Add yourself
    } # <-- For a sake of god, please don't accidentally delete this!
    
  end
end
# =============================================================================
# End of config
# =============================================================================
class << Cache
  
  def animbattleback(filename, index)
    file = filename + sprintf("_%02d", index)
    load_bitmap("Graphics/AnimBattleBack/", file)
  end
  
end

class Game_System
  attr_accessor :anim_bb
  
  alias theo_animbb_init initialize
  def initialize
    theo_animbb_init
    @anim_bb = ""
  end
  
end

class Game_Map
  
  alias theo_animbb_setup setup
  def setup(map_id)
    theo_animbb_setup(map_id)
    setup_animbb
  end
  
  def setup_animbb
    $game_system.anim_bb = ""
    @map.note.split(/[\r\n]+/).each do |line|
      if line =~ /<(?:anim bb|anim_bb):[ ]*(.+)>/i
        $game_system.anim_bb = $1.to_s
      end
    end
  end
  
end

class AnimBB < Sprite
  attr_reader :name
  attr_reader :index
  
  def initialize(viewport)
    super(viewport)
    init_member
  end
  
  def init_member
    @name = $game_system.anim_bb
    @count = 0
    @index = 1
    refresh_bitmap
  end
  
  def refresh_bitmap
    if name.empty?
      self.bitmap = Cache.empty_bitmap
    else
      self.bitmap = Cache.animbattleback(file, index)
    end
  end
  
  def file
    check_validity(name)
    Theo::AnimBB::List[name][0]
  end
  
  def max_index
    Theo::AnimBB::List[name][1]
  end
  
  def rate
    Theo::AnimBB::List[name][2]
  end
  
  def need_refresh?
    @count % rate == 0 && !name.empty?
  end
  
  def change_index
    @index += 1
    if @index == max_index
      @index = 1
    end
    refresh_bitmap
  end
  
  def update
    super
    return if name.empty?
    @count += 1
    change_index if need_refresh?
  end
  
  def check_validity(name)
    pic = Theo::AnimBB::List[name]
    if pic.nil?
      Sound.play_buzzer
      msgbox "Animated Battleback: \n\nUndefined key \"#{name}\" on the config"+ 
      "\nThis is not script error. You need to double check it"
      exit
    end
  end
  
end

class Spriteset_Battle
  
  alias theo_animbb_create_viewports create_viewports
  def create_viewports
    theo_animbb_create_viewports
    create_animbb
  end
  
  def create_animbb
    @animbb = AnimBB.new(@viewport1)
    @animbb.z = 5
    center_sprite(@animbb)
  end
  
  alias theo_animbb_update update
  def update
    theo_animbb_update
    @animbb.update
  end
  
  alias theo_animbb_dispose dispose
  def dispose
    theo_animbb_dispose
    @animbb.dispose
  end
  
end
