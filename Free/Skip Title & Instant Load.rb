=begin
  
  A simple script to pass the title screen
  _(:3JL)_
  
=end
module Theo
  
  SKIP_TITLE    = true        # Activation flag
  JUMP_TO       = Scene_Map   # Where you want to jump?
  LOAD_GAME     = 1           # Instant load game
  NO_TRANSITION = true        # Remove transition
  
end

module SceneManager
  class << self
    alias not_skip_title_scene first_scene_class
  end
  
  def self.first_scene_class
    return Scene_Battle if $BTEST
    return skip_title if Theo::SKIP_TITLE #|| !DataManager.save_file_exists?
    return Scene_Title
  end
  
  def self.skip_title
    if Theo::LOAD_GAME && Theo::LOAD_GAME > 0
      if DataManager.load_game(Theo::LOAD_GAME - 1)
        $game_system.on_after_load
        return Theo::JUMP_TO
      end
    end
    DataManager.setup_new_game
    $game_map.autoplay
    return Theo::JUMP_TO
  end
  
end

if Theo::NO_TRANSITION

class Scene_Base
  
  def transition_speed
    return 5
  end
  
end

class Scene_Map
  
  def transition_speed
    return 0
  end
  
end

class Scene_Title
  
  def transition_speed
    return 0
  end
  
end

end
