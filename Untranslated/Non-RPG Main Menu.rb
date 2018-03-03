# =============================================================================
# TheoAllen - Non RPG Main Menu
# Version : 0.8 (In development)
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# -----------------------------------------------------------------------------
# Requires :
# >> Theo - Object Core Movement (can be found in Theo - Basic Modules)
# =============================================================================
# Change Logs :
# -----------------------------------------------------------------------------
# 2013.07.23 - Finished script
# =============================================================================
=begin

  Perkenalan :
  Script ini didesain untuk game non-RPG yang hanya berisi item, load, save
  dan game end
  
  Cara penggunaan :
  Pasang dibawah material namun diatas main
  Edit konfigurasinya kalo perlu
  
  Terms of Use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

  Note :
  1. Kalo kamu pengen menumu ada show location dan playtime, gunakan juga 
     script gw yg namanya Theo - Simple Menu Info
  2. Karena gw ga tau apa aja yg dibutuhin di game non-RPG, jadi kalo ada
     saran-saran untuk perkembangan script ini, kasi tau gw
  3. Kalo kamu pake script gw yg Theo - Non-RPG Actor Biography, taruh script
     ini dibawahnya.

=end
# =============================================================================
# Konfigurasi :
# =============================================================================
module THEO
  module NONRPG
    
    # Deskripsi help untuk command
    Command_Helps = {
      "Items"     => "Check Your Inventory",
      "Load"      => "Load Game",
      "Save"      => "Save Game",
      "Game End"  => "End the Game",
    }
    
    Load_Vocab = "Load"
    
    ItemWindow_DisplayAmount  = true # Kalo true, item ditampilin jumlahnya
    ItemWindow_DisplayOnly    = false # Kalo true, item ga bisa digunain
    ItemWindow_Width          = 200 # Lebar item window
    
    Display_HelpWindow  = true # Centang true kalo pengen nampilih help window
    HelpWindow_ItemOnly = true # Help window hanya untuk item
    HelpWindow_BackType = 2 # Tipe background help window (0,1,2)
    # 0 = Windowskin Biasa
    # 1 = Dim Background
    # 2 = Transparan background
    
  end
end
# =============================================================================
# Akhir dari konfigurasi
# =============================================================================
if ($imported ||= {})[:Theo_Movement]
$imported[:Theo_NonRPGMenu] = true
class Window_MenuCommand < Window_Command
  
  # Overwrite Command List
  def make_command_list
    add_main_commands
    add_original_commands
    add_load_command
    add_save_command
    add_game_end_command
  end
  
  def add_main_commands
    add_command(Vocab::item, :item, main_commands_enabled)
    if $imported[:Theo_NonRPGBioGraphy]
      add_command(Vocab::status,:status,main_commands_enabled) 
    end
  end
  
  def add_load_command
    add_command(THEO::NONRPG::Load_Vocab, :continue, continue_enabled)
  end
  
  def continue_enabled
    DataManager.save_file_exists?
  end
  
  def update_help
    help = THEO::NONRPG::Command_Helps[command_name(index)]
    @help_window.set_text(help)
  end
  
end

class Window_MenuHelp < Window_Help
  
  def initialize(line_number = 2)
    super(line_number)
    self.opacity = 0 if THEO::NONRPG::HelpWindow_BackType > 0
    self.openness = THEO::NONRPG::HelpWindow_ItemOnly ? 0 : 255
    create_background
    check_visibility
  end
  
  def create_background
    create_back_bitmap
    create_back_sprite
  end
  
  def create_back_bitmap
    @back_bitmap = Bitmap.new(width, height)
    rect1 = Rect.new(0, 0, width, 12)
    rect2 = Rect.new(0, 12, width, height - 24)
    rect3 = Rect.new(0, height - 12, width, 12)
    @back_bitmap.gradient_fill_rect(rect1, back_color2, back_color1, true)
    @back_bitmap.fill_rect(rect2, back_color1)
    @back_bitmap.gradient_fill_rect(rect3, back_color1, back_color2, true)
  end
  
  def back_color1
    Color.new(0, 0, 0, 160)
  end
  
  def back_color2
    Color.new(0, 0, 0, 0)
  end
  
  def create_back_sprite
    @back_sprite = Sprite.new
    @back_sprite.bitmap = @back_bitmap if THEO::NONRPG::HelpWindow_BackType == 1
  end
  
  def check_visibility
    @back_sprite.visible = self.visible = THEO::NONRPG::Display_HelpWindow
  end
  
  def dispose
    @back_sprite.dispose
    @back_bitmap.dispose
    super
  end
  
end

class Window_MenuItem < Window_ItemList
  
  def initialize(*args)
    super(*args)
    self.category = :item
  end
  
  def draw_item_number(rect, item)
    super if THEO::NONRPG::ItemWindow_DisplayAmount
  end
  
  def col_max
    return 1
  end
  
  def update_open
    self.openness += 20
    @opening = false if open?
  end
  
  def update_close
    self.openness -= 20
    @closing = false if close?
  end
  
end

class Scene_Menu < Scene_MenuBase
  
  include THEO::NONRPG
  
  alias theo_non_rpg_menu_start start
  def start
    theo_non_rpg_menu_start
    create_menu_help
    create_item_window
    create_windows_notify
    update_windows_placement
  end
  
  alias theo_nonrpg_command_window create_command_window
  def create_command_window
    theo_nonrpg_command_window
    @command_window.set_handler(:continue, method(:on_load_ok))
  end
  
  def update_windows_placement
    @command_window.x = (Graphics.width - @command_window.width)/2
    @command_window.y = Graphics.height/2 - (@command_window.height/2 + 
      @gold_window.height/2)
    update_gold_window_placement
    update_item_window_position
  end
  
  def create_menu_help
    @help_window = Window_MenuHelp.new
    @command_window.help_window = @help_window
  end
  
  def create_item_window
    width = THEO::NONRPG::ItemWindow_Width
    height = @command_window.height + @gold_window.height
    @item_window = Window_MenuItem.new(0,0,width,height)
    @item_window.set_handler(:ok, method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @item_window.help_window = @help_window
    @item_window.openness = 0
  end
  
  def create_windows_notify
  end
  
  def update_gold_window_placement
    @gold_window.x = @command_window.x
    @gold_window.y = @command_window.y + @command_window.height
  end
  
  def update_item_window_position
    @item_window.x = @command_window.x + @command_window.width
    @item_window.y = @command_window.y
  end
  
  def command_item
    @help_window.open if HelpWindow_ItemOnly
    xpos = Graphics.width/2 - (@command_window.width/2 + @item_window.width/2)
    ypos = @command_window.y
    @command_window.goto(xpos,ypos,10)
    @item_window.activate
    @item_window.select(0)
    @item_window.open
  end
  
  def on_item_ok
    if ItemWindow_DisplayOnly
      @item_window.activate
      return
    end
    play_se_for_item
    $game_party.members[0].use_item(@item_window.item)
    check_common_event
    check_gameover
    @item_window.activate
    @item_window.refresh
  end
  
  def on_item_cancel
    @help_window.openness = 0 if HelpWindow_ItemOnly
    if @command_window.moving?
      @item_window.activate
      return
    end
    xpos = (Graphics.width - @command_window.width)/2
    ypos = @command_window.y
    @command_window.goto(xpos,ypos,10)
    @command_window.activate
    @item_window.close
    @item_window.unselect
  end
  
  def on_load_ok
    SceneManager.call(Scene_Load)
  end
  
  # Overwrite command personal
  def command_personal
    SceneManager.call(Scene_Status)
  end
  
  alias theo_non_rpg_menu_update update
  def update
    theo_non_rpg_menu_update
    update_gold_window_placement
    update_item_window_position
  end
  
  # Delete Status Window
  def create_status_window
  end
  
  def check_common_event
    SceneManager.goto(Scene_Map) if $game_temp.common_event_reserved?
  end
  
  def play_se_for_item
    Sound.play_use_item
  end
  
end
else
  msgbox "Theo - Non-RPG Main Menu Requires Theo - Core Movement \n" +
    "It can be found in Theo - Basic Modules \n" +
    "Please visit http://theolized.blogspot.com"
end
