# =============================================================================
# TheoAllen - VX Style Choices
# Version : 1.1
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (English Documentation)
# =============================================================================
($imported ||= {})[:Theo_VXStyleChoices] = true
# =============================================================================
# Change Logs :
# -----------------------------------------------------------------------------
# 2013.11.14 - Compatibility patch with my choice help
#            - Bugfix. Face graphic erased when clearing message box
# 2013.10.14 - Bugfix. Choice isn't displayed if it isn't followed by texts
# 2013.10.12 - Finished script
# =============================================================================
=begin

  Introduction :
  This script allow you to display choices as VX has
  
  How to use :
  Put this script below material but above main
  Use these script calls to activate VX style choice
  
  vx_choice(true)   << to activate
  vx_choice(false)  << to deacitave
  
  Terms of use :
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.
  
=end
# =============================================================================
# No configuration. Just dont edit below this line
# =============================================================================
class Game_Interpreter
  
  def vx_choice(bool)
    $game_message.vx_choice = bool
  end
  
end

class Game_Message
  attr_accessor :vx_choice
  
  alias theo_vxchoice_init initialize
  def initialize
    theo_vxchoice_init
    @vx_choice = true
  end
  
end

class Window_Message < Window_Base
  
  alias theo_vxchoice_init initialize
  def initialize
    theo_vxchoice_init
    init_vxchoice_member
  end
  
  def init_vxchoice_member
    @need_clear = false
    @choice_index = 0
    @choice_y = 0
  end
  
  alias theo_vxchoice_input input_choice
  def input_choice
    return start_vx_choice if $game_message.vx_choice
    return theo_vxchoice_input
  end
  
  alias theo_vxchoice_new_page new_page
  def new_page(text, pos)
    theo_vxchoice_new_page(text, pos)
    @need_clear = ($game_message.texts.size + $game_message.choices.size) >
      visible_line_number
  end
  
  alias theo_vxchoice_new_line process_new_line
  def process_new_line(text, pos)
    theo_vxchoice_new_line(text, pos)
    @choice_y = pos[:y]
  end
  
  def start_vx_choice
    open_and_wait unless open?
    if @need_clear
      input_need_clear
    end
    @choice_index  = 0
    ypos = 0
    $game_message.choices.each do |choice|
      draw_text_ex(new_line_x + padding_x, @choice_y + ypos, choice)
      ypos += line_height
    end
    update_vx_choice(@choice_y)
  end
  
  def padding_x
    return 16
  end
  
  def input_need_clear
    input_pause
    contents.clear
    draw_face($game_message.face_name, $game_message.face_index, 0, 0)
    @choice_y = 0
    @need_clear = false
  end
  
  def update_vx_choice(ypos)
    rect_width = contents.width - new_line_x - rface
    cursor_rect.set(new_line_x, ypos, rect_width, line_height)
    if choice_help?
      @choice_help.open
      update_choice_help
    end
    wait(10)
    until Input.trigger?(:C) || (Input.trigger?(:B) && cancel_enabled?)
      update_choice_cursor
      Fiber.yield
    end
    cursor_rect.empty
    execute_choice
    Input.update
  end
  
  def rface
    ($imported[:Theo_RightSideFace] && !$game_message.face_name.empty? && 
      $game_message.rface) ? 100 : 0
  end
  
  def cancel_enabled?
    $game_message.choice_cancel_type > 0
  end
  
  def update_choice_cursor
    cursor_rect.y = @choice_y + @choice_index * line_height
    change_choice_index(1) if Input.repeat?(:DOWN)
    change_choice_index(-1) if Input.repeat?(:UP)
  end
  
  def change_choice_index(amount)
    Sound.play_cursor
    @choice_index += amount
    wrap_index
    update_choice_help if choice_help?
  end
  
  def wrap_index
    @choice_index = 0 if @choice_index > $game_message.choices.size - 1
    @choice_index = $game_message.choices.size - 1 if @choice_index < 0
  end
  
  def execute_choice
    call_ok_handler if Input.trigger?(:C)
    call_cancel_handler if Input.trigger?(:B)
    if choice_help?
      @choice_help.close
    end
  end
  
  def choice_help?
    $imported[:Theo_ChoiceHelp]
  end
  
  def update_choice_help
    @choice_help.set_text($game_message.choice_helps[@choice_index])
  end
  
  def call_ok_handler
    Sound.play_ok
    $game_message.choice_proc.call(@choice_index)
  end
  
  def call_cancel_handler
    Sound.play_cancel
    $game_message.choice_proc.call($game_message.choice_cancel_type - 1)
  end
  
end
