#===============================================================================
# Peeking System
# By : TheoAllen
#-------------------------------------------------------------------------------
# WHAT IS THIS?
#-------------------------------------------------------------------------------
# Want to take a look at surrounding?
#
# You press the key (adjustable in config)
# And the game will look further in your map
#
# This script was used in my IGMC entry at 2017
# https://richter-h.itch.io/sample09
#-------------------------------------------------------------------------------
# IMPORTANT NOTE
#-------------------------------------------------------------------------------
# Map looping may not work. If you have a looping map in your game, 
# unfortunately you either have to let this script go or ditch your looping map.
#-------------------------------------------------------------------------------
# TERMS
#-------------------------------------------------------------------------------
# Credit me, TheoAllen. You are free to edit this script by your own. As long 
# as you don't claim it's yours. For commercial purpose, don't forget to give me
# a free copy of the game.
#===============================================================================
class Game_Map  # <-- don't touch this
  #=============================================================================
  # Configuration
  #-----------------------------------------------------------------------------
    DURATION = 100      # Duration of the moving camera
    CAM_X = 7.0         # How far the camera will look further in X axis?
    CAM_Y = 5.0         # How far the camera will look further in Y axis?
    PEEK_SWITCH = 10    # ON = disable
    PEEK_BUTTON = :Z    # What to press?
  #-----------------------------------------------------------------------------
  # Ok, do not edit pass this line
  #=============================================================================
  alias mapcam_init initialize
  def initialize
    mapcam_init
    @cam_x = 0.0
    @cam_y = 0.0
    @last_peek = @peeking = false
  end
  
  def display_x
    rx = $game_player.real_x
    dx = rx - 8
    dx = dx + @cam_x
    dx = [dx, 0].max
    dx = [dx, $game_map.width - Graphics.width/32].min
    return dx
  end
  
  def display_y
    ry = $game_player.real_y
    dy = ry - 6
    dy = dy + @cam_y
    dy = [dy, 0].max
    dy = [dy, $game_map.height - Graphics.height/32].min
    return dy
  end
  
  alias mapcam_update update
  def update(main = false)
    mapcam_update(main)
    update_cam
  end
  
  def update_cam
    @peeking = Input.press?(PEEK_BUTTON)
    @fiber.resume if @fiber
    @last_dir = $game_player.direction unless @last_dir
    return if peeking_disabled?
    if @peeking == true && (@last_dir != $game_player.direction || @last_peek !=
        @peeking)
      @last_peek = @peeking
      @last_dir = $game_player.direction
      @last_cam_x = @cam_x
      @last_cam_y = @cam_y
      case $game_player.direction
      when 2 # DOWN
        @target_cam_x = 0.0
        @target_cam_y = CAM_Y
      when 4 # LEFT
        @target_cam_x = -CAM_X
        @target_cam_y = 0.0
      when 6 # RIGHT
        @target_cam_x = CAM_X
        @target_cam_y = 0.0
      when 8 # UP
        @target_cam_x = 0.0
        @target_cam_y = -CAM_Y
      else
        @target_cam_x = 0.0
        @target_cam_y = 0.0
      end
      @fiber = Fiber.new do
        DURATION.times do |t|
          @cam_x = move_cam(t, @last_cam_x, @target_cam_x-@last_cam_x, DURATION)
          @cam_y = move_cam(t, @last_cam_y, @target_cam_y-@last_cam_y, DURATION)
          Fiber.yield
        end
        @cam_x = @target_cam_x
        @cam_y = @target_cam_y
        @fiber = nil
      end
    elsif @last_peek != @peeking && @peeking == false
      @last_peek = @peeking
      @last_cam_x = @cam_x
      @last_cam_y = @cam_y
      @fiber = Fiber.new do
        DURATION.times do |t|
          @cam_x = move_cam(t, @last_cam_x, 0.0-@last_cam_x, DURATION)
          @cam_y = move_cam(t, @last_cam_y, 0.0-@last_cam_y, DURATION)
          Fiber.yield
        end
        @cam_x = 0.0
        @cam_y = 0.0
        @fiber = nil
      end
    end
  end
  
  # Linear
  def move_caml(time, start, change, total_time)
    return change * time / total_time + start
  end
  
  # Smooth
  def move_cam(time, start, change, total_time)
    time /= total_time.to_f
    time -= 1
    return change*(time*time*time + 1) + start
  end
  
  def peeking_disabled?
    $game_switches[PEEK_SWITCH]
  end
  
  # Overwrite
  def parallax_ox(bitmap)
    return 0 unless bitmap
    w1 = [bitmap.width - Graphics.width, 0].max
    w2 = [width * 32 - Graphics.width, 1].max
    display_x * 32 * w1 / w2
  end
  
  # Overwrite
  def parallax_oy(bitmap)
    return 0 unless bitmap
    h1 = [bitmap.height - Graphics.height, 0].max
    h2 = [height * 32 - Graphics.height, 1].max
    display_y * 32 * h1 / h2
  end
  
end

class Game_CharacterBase
  
  # Overwrite
  def screen_x
    (@real_x - $game_map.display_x) * 32 + 16
  end
  
  # Overwrite
  def screen_y
    (@real_y - $game_map.display_y) * 32 + 32 - shift_y - jump_height
  end
  
end

class Game_Player
  
  # Overwrite
  def move_by_input
    return if !movable? || $game_map.interpreter.running?
    return unless Input.dir4 > 0
    if Input.press?(Game_Map::PEEK_BUTTON)
      set_direction(Input.dir4)
    else
      move_straight(Input.dir4)
    end
  end
  
end
