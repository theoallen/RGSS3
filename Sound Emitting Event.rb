#==============================================================================
# TheoAllen - Sound Emitting Event
# Version : 1.0
# Language : English
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> Discord @ Theo#3034
# *> Twitter @ theolized
#==============================================================================
($imported ||= {})[:Theo_SoundEmitEvent] = true
#==============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.08.19 - Finished script
#==============================================================================
=begin

  ===================
  || Introduction ||
  -------------------
  Have you thougt if an event could constantly emitting sound? Like if you 
  getting closer to a firecamp, the BGS get louder. This script could help you 
  to make your dream come true
  
  =================
  || How to use ||
  -----------------
  This script could make an event emitting both SE or BGS.
  To setup the SE, use this following format on event comments
  
  <sound>
  name : filename
  vol : 100
  pitch : 100
  delay : frame
  range : grid
  </sound>
  
  Name, vol, and pitch are self explanatory I guess. Delay is frame delay 
  between SE play. Put the number on it. Keep in mind that by default, 60 frames 
  is same as one second. Range is maximum grid range from event to player. If 
  you put 10 on it. The SE can't be heard if your position is more than 10 grid.
  
  To setup the BGS, use this following format on event comments
  
  <backsound>
  name : filename
  vol : 100
  pitch : 100
  range : grid
  </backsound>
  
  Unlike SE. Since BGS can't be played simultaneously, you could only listen to
  the louder BGS if some events are in player range and all of them are emitting
  BGS
  
  ===================
  || Terms of use ||
  -------------------
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.
  
  This script was a part of VXAN restaff.

=end
#==============================================================================
# End of instruction. I'm not responsible if you edit anything below this line!
#==============================================================================
class Game_Event
#==============================================================================
# Regular Expressions Constant
#------------------------------------------------------------------------------
  SoundEmit_SEStart   = /<sound>/i
  SoundEmit_SEEnd     = /<\/sound>/i
  SoundEmit_BGSStart  = /<backsound>/i
  SoundEmit_BGSEnd    = /<\/backsound>/i
#------------------------------------------------------------------------------
  SoundEmit_Name  = /name\s*:\s*(.+)/i
  SoundEmit_Vol   = /vol\s*:\s*(\d+)/i
  SoundEmit_Pitch = /pitch\s*:\s*(\d+)/i
  SoundEmit_Delay = /delay\s*:\s*(\d+)/i
  SoundEmit_Range = /range\s*:\s*(\d+)/i
#==============================================================================
  attr_reader :bgs_emit
  alias theo_soundemit_setup_page setup_page
  def setup_page(new_page)
    theo_soundemit_setup_page(new_page)
    clear_soundemit_var
    clear_bgsemit_var
    if @list
      load_sound = false
      load_bgs   = false
      @list.select {|list| [108,408].include?(list.code)}.each do |command|
        #=================================
        # Start End tag evaluation
        #---------------------------------
        case command.parameters[0]
        when SoundEmit_SEStart
          load_sound = true
          init_soundemit
          next
        when SoundEmit_BGSStart
          load_bgs = true
          init_bgsemit
          next
        when SoundEmit_SEEnd
          load_sound = false
          next
        when SoundEmit_BGSEnd
          load_bgs = false
          next
        end
        #=================================
        # SE evaluation
        #---------------------------------
        if load_sound
          case command.parameters[0]
          when SoundEmit_Name
            @sound_emit.name = $1.to_s
          when SoundEmit_Vol
            @sound_emit.volume = $1.to_i
          when SoundEmit_Pitch
            @sound_emit.pitch = $1.to_i
          when SoundEmit_Delay
            @sound_delay = $1.to_i
            @sound_remain_delay = rand(@sound_delay)
          when SoundEmit_Range
            @sound_range = $1.to_i
          end 
        end
        #=================================
        # BGS evaluation
        #---------------------------------
        if load_bgs
          case command.parameters[0]
          when SoundEmit_Name
            @bgs_emit.name = $1.to_s
          when SoundEmit_Vol
            @bgs_emit.volume = $1.to_i
          when SoundEmit_Pitch
            @bgs_emit.pitch = $1.to_i
          when SoundEmit_Range
            @bgs_range = $1.to_i
          end
        end
      end # -- each
    end # -- @list
  end # -- setup_page
  
  def clear_soundemit_var
    @sound_emit = nil
    @sound_range = 0
    @sound_delay = 0
    @sound_remain_delay = 0
  end
  
  def clear_bgsemit_var
    @bgs_emit = nil
    @bgs_range = 0
  end
  
  def init_soundemit
    @sound_emit = RPG::SE.new
    @sound_delay = 60
    @sound_range = 7
  end
  
  def init_bgsemit
    @bgs_emit  = RPG::BGS.new
    @bgs_range = 7
  end
  
  def bgs_loud
    vol_reduce = [(@bgs_emit.volume/@bgs_range)*dist_from_player,
      @bgs_emit.volume].min
    return @bgs_emit.volume - vol_reduce
  end
  
  def bgs_play
    return unless @bgs_emit
    bgs = @bgs_emit.clone
    bgs.volume = bgs_loud
    bgs.play
  end
  
  alias theo_soundemit_update update
  def update
    theo_soundemit_update
    update_emiting_sound if @sound_emit
  end
  
  def update_emiting_sound
    @sound_remain_delay -= 1
    return if @sound_remain_delay > 0
    @sound_remain_delay = @sound_delay
    vol_reduce = [(@sound_emit.volume/@sound_range)*dist_from_player,
      @sound_emit.volume].min
    sound = @sound_emit.clone
    sound.volume -= vol_reduce
    sound.play
  end
  
  def dist_from_player
    sx = distance_x_from($game_player.x).abs
    sy = distance_y_from($game_player.y).abs
    return sx + sy
  end
  
end

class Game_Map
  
  alias theo_soundemit_refresh refresh
  def refresh
    theo_soundemit_refresh
    @event_bgs = events.values.select {|ev| !ev.bgs_emit.nil? }
  end
  
  def bgs_emitting_event
    if @event_bgs.nil?
      @event_bgs = events.values.select {|ev| !ev.bgs_emit.nil? }
    end
    @event_bgs.sort {|a,b| b.bgs_loud <=> a.bgs_loud }
  end
  
end

class Game_Player
  
  alias theo_soundemit_incr_step increase_steps
  def increase_steps
    theo_soundemit_incr_step
    play_event_bgs
  end
  
  def play_event_bgs
    event_bgs = $game_map.bgs_emitting_event
    return if event_bgs.empty?
    event_bgs[0].bgs_play
  end
  
end

class Scene_Map
  
  alias theo_soundemit_start start
  def start
    theo_soundemit_start
    $game_player.play_event_bgs
  end
  
  alias theo_soundemit_post_transfer post_transfer
  def post_transfer
    theo_soundemit_post_transfer
    $game_player.play_event_bgs
  end
  
end
