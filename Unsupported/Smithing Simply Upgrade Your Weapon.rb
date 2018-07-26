# =============================================================================
# Smithing -- Simply Upgrade Your Weapon
# By : TheoAllen feat richter_h
# -----------------------------------------------------------------------------
# Version : 1.1b
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (English Documentation)
# =============================================================================
($imported ||= {})[:Theo_Smithing] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2013.09.08 - Bugfix at attack animation
# 2013.08.18 - Raise compatibility among various script
# 2013.08.16 - Finished script
# 2013.08.15 - Started script
# =============================================================================
=begin
  # --------------------------------------------------------------------------
  Prelude :
  I heard you guys are really obsessed with richter_h's upgrade weapon script
  for RMVX / RGSS2. One of you are desperately bumping the thread request in a 
  countless time. Well, I hope with this script may solve your life problems :P
  
  # --------------------------------------------------------------------------
  Introduction :
  This script allow you to upgrade your equipped weapon just like suikoden.
  Well, at least my friend, richter_h said so. I never played suikoden actually
  
  # --------------------------------------------------------------------------
  What are inside this script?
  - Add basic parameter for every weapon in each level. You may change ATK, 
    DEF, or even MHP.
  - Change your weapon's name from a simple "Short sword" into "Shorter Sword",
    "Bodycleaver", "Excalibur", or even "Super Awesome Sword"? your choice.
  - Different name means that it also need a different icon and description,
    isn't it? Who knows if a wooden sword suddenly turned into a great hammer
    after upgrade it?
  - Highly customizable vocab. You may change every quotes to your language
  - Customizable color composition.
  - Customizable price formula
  
  # --------------------------------------------------------------------------
  How to use?
  Put this script below material but above main
  To call the smithing menu, write down this following line to script call
  SceneManager.call(Scene_Smith)
  
  Don't forget to edit the extra configurations. 
  
  # --------------------------------------------------------------------------
  Terms of use :
  Credit me, TheoAllen. Because rewrite this script for RGSS3 is not that 
  simple if you know. And don't forget to credit richter_h as well. He provides 
  the basic workflows, so I can rewrite this script for RGSS3.
  
  # --------------------------------------------------------------------------
  Questions :
  Q : Can I add some features for the next upgraded weapon?
  A : No, you can't. I just have no idea how to make user-friendly 
      configuration for that feature
  Q : Where's the socket?
  A : After my friend's, richter_h made them for his RGSS2 script, I'll also 
      update my script as well.
  Q : Where's the SEs configuration?
  A : Personally, I don't like those SEs when the upgrading is in progress. So
      I remove them. Add by yourself if you dare :v
  
=end
# =============================================================================
# Extra Configurations. Brace yourself, there're a lot of works to do
# =============================================================================
module THEO
  module Smith
  # =========================================================================
  # General settings
  # -------------------------------------------------------------------------
    MenuActor_Size    = 125   # Menu actor width
    GoldWindow_Size   = 125   # Gold window width
    Confirm_Width     = 80    # Yes/No confirmation width
    NotifShowDuration = 200   # Duration for showing notification
  # =========================================================================
    
  # =========================================================================
  # Price Settings
  # -------------------------------------------------------------------------
  # These settings are for price. You may use your custom formula to optimize
  # your upgraded weapon price. 
  #
  # The price formula divided by two. 
  # - PriceUpgrade = The cost requirement for upgrading the weapon
  # - PriceTrade = The cost formula for shop processing
  #
  # These are provided variables
  # - item_price = the original item price in database
  # - base_price = same as PriceBase
  # - level = The upgraded weapon level
  #
  # Beware, the false formula may causes an error
  # -------------------------------------------------------------------------
    PriceBase     = 10
    PriceUpgrade  = "item_price/2 + (base_price * level)"
    PriceTrade    = "item_price + ((item_price/2) * level)"
  # =========================================================================
  
  # =========================================================================
  # Color Settings :
  # These are for color setting. The color code is same as \C[n] in message
  # -------------------------------------------------------------------------
    module Colour
      Level       = 6   # Level color
      Maxout      = 21  # Maxout color
      Upgradable  = 24  # Upgradable color
    end
  # =========================================================================
  # Smithing Vocabs list :
  # Wanna translate to your languange? Do not hesitate to change these 
  # settings.
  # -------------------------------------------------------------------------
    module SVocab
      Cost        = "Cost: "
      Level       = "Lv.%d"
      Upgradable  = "Upgradable"
      Maxout      = "Maxed Out"
      Yes_Confirm = "Yes"
      No_Confirm  = "No"
      
      Select_Weapon   = "Whose weapon will be upgraded?"
      Decide_Weapon   = "Upgrade this weapon?"
      Upgraded_Quote  = "Upgrade complete"
      
      NotifNameChange = "Weapon changed to %s"
      NotifNormal     = "Weapon Improved"
    end
  # ==========================================================================
  # Weapon Upgrade Table (Main Configuration)
  # This is the main course for this script. You may called this an 
  # "Upgrade Tree" or "Weapon tree".
  #
  # You must follow the instruction to make sure the script will work.
  # --------------------------------------------------------------------------
    
    W_Upgrade_Table = { # <-- Do not touch this at all cost!
    
    # ------------------------------------------------------------------------
    # Upgrade tree format. 
    # ------------------------------------------------------------------------
    # ID => [ <-- opening
    #
    #       [{:symbol => num}, icon_index, name, description],  # Level 2
    #       [{:symbol => num}, icon_index, name, description],  # Level 3
    #       [ <add more here for the next level> ],             # Level 4
    #
    #       ], <-- ending (do not forget to add comma!)
    # ------------------------------------------------------------------------
    # Just a quick guide won't kill yourself :)
    # ------------------------------------------------------------------------
    # ID                = Weapon ID in database.
    #
    # {:symbol => num } = Once you've upgrade your weapon, the parameter will
    #                     change whether it's up or down. Use the symbol to
    #                     represent the status. Here's the list:
    #                     ---------------------------------------------------
    #                     :atk = attack     || :def = defense
    #                     :mat = magic atk  || :mdf = magic defense
    #                     :agi = agility    || :luk = luck
    #                     :mhp = Max HP     || :mmp = Max MP
    #                     ---------------------------------------------------
    #                     And "num" is a number represent to parameter change
    #
    # icon_index        = Represent as icon index. You may look the icon
    #                     index when you open the icon window dialog box and
    #                     see to the bottom left of that window. Use -1 if you
    #                     don't want to change weapon's icon once upgraded.
    #
    # name              = The new name of upgraded weapon. Leave it blank ("")
    #                     if you wanna keep the original name
    #
    # description       = The new description of upgraded weapon. Leave it
    #                     blank ("") if you wanna keep the original description
    #
    # Here's the example :
    # ------------------------------------------------------------------------
      1  => [
            [{:atk => 2,:luk => 2},-1,"",""], # dont forget comma
            [{:atk => 2},-1,"Iron Ax","Upgrade version of Hand ax"], 
            [{:atk => 2},-1,"Silver Ax",""],
            ], # dont forget comma
            
     13  => [
            [{:atk => 4, :def => 1 },-1,"Fine Spear","Upgrade version of spear"],
            [{:atk => 10, :def => 10 },-1,"Awesome Spear","It's super awesome"],
            ],
            
     19  => [
            [{:atk => 1, :agi => 3},-1,"Shorter Sword","The shorter version of short sword"],
            [{:atk => 2, :agi => 10},150,"Dagger",""],
            ],
            
    # add more here if it's necessary
    
    # ------------------------------------------------------------------------
    } # <-- Do not touch this at all cost!
# ============================================================================
# Do not ever touch anything pass this line or the risk is yours
# ============================================================================
    Key = {
      :mhp => 0,
      :mmp => 1,
      :atk => 2,
      :def => 3,
      :mat => 4,
      :mdf => 5,
      :agi => 6,
      :luk => 7,
    }
  end
end

class RPG::Weapon < RPG::EquipItem
  attr_accessor :level
  
  alias theo_smith_upgrade_init initialize
  def initialize
    theo_smith_upgrade_init
    @level = 1
  end
  
  def clone_data
    original = self
    cloned = RPG::UpgradedWeapon.new
    self.instance_variables.each do |varsym|
      ivar_name = varsym.to_s.gsub(/@/) {""}
      eval("
      if cloned.respond_to?(\"#{ivar_name}\")
        begin
          cloned.#{ivar_name} = original.#{ivar_name}.clone 
        rescue 
          cloned.#{ivar_name} = original.#{ivar_name} 
        end
      end")
    end
    return cloned
  end
  
  def next_weapon
    next_weapon_exist? ? $upgraded_weapons[upgrade_key] : nil
  end
  
  def next_weapon_exist?
    !$upgraded_weapons[upgrade_key].nil?
  end
  
  
  def upgrade_key
    self.id * 100 + (level+1)
  end
  
  def level
    @level ||= 1
  end
  
end

class RPG::UpgradedWeapon < RPG::Weapon
  attr_accessor :ori_id
  attr_accessor :upgrade_price
  
  def upgrade_key
    self.ori_id * 100 + (level+1)
  end
  
  def make_price
    item_price = @price
    base_price = THEO::Smith::PriceBase
    @upgrade_price = eval(THEO::Smith::PriceUpgrade)
    @price = eval(THEO::Smith::PriceTrade)
  end
  
end

class << DataManager
  
  alias theo_upgrade_smith_game_obj create_game_objects
  def create_game_objects
    theo_upgrade_smith_game_obj
    init_upgraded_weapons
  end
  
  def init_upgraded_weapons
    $upgraded_weapons = {}
    THEO::Smith::W_Upgrade_Table.each do |id, table|
      table.each_with_index do |data,level|
        gen_id = (id*100) + (level+1) # Generated ID
        weapon_check = $upgraded_weapons[gen_id]
        result = nil
        if (level + 1) != 1 && !weapon_check.nil?
          result = weapon_check.clone_data
        else
          result = $data_weapons[id].clone_data
        end
        result.level = level+2
        data[0].each do |param,value|
          param_id = THEO::Smith::Key[param]
          result.params[param_id] += value
        end
        if data[1] > -1
          result.icon_index = data[1]
        end
        result.name = data[2].empty? ? result.name : data[2]
        result.description = data[3].empty? ? result.description : data[3]
        result.ori_id = id
        result.make_price
        gen_id = (id*100) + (level+2)
        result.id = gen_id # Generated ID
        $upgraded_weapons[gen_id] = result
      end
    end
  end
  
end

class Game_BaseItem
  
  def upgraded_weapon?
    @class == RPG::UpgradedWeapon
  end
  
  alias theo_smt_upgrade_object object
  def object
    return $upgraded_weapons[@item_id] if upgraded_weapon?
    return theo_smt_upgrade_object
  end
  
end

class Game_Party < Game_Unit
  
  alias theo_smith_init_item init_all_items
  def init_all_items
    theo_smith_init_item
    @upgraded_weapons = {}
  end
  
  alias theo_smith_item_container item_container
  def item_container(item_class)
    return @upgraded_weapons if item_class == RPG::UpgradedWeapon
    return theo_smith_item_container(item_class)
  end
  
  alias theo_smith_weapon weapons
  def weapons
    theo_smith_weapon + upgraded_weapons
  end
  
  def upgraded_weapons
    @upgraded_weapons.keys.sort.collect {|id| $upgraded_weapons[id]}
  end
  
end

class Window_Base < Window
  SText_Format = "\\C[16]%s\\C[0] : %d → \\C[24]%d\\C[0]"
  def obtain_params_change
    result = []
    @weapon.params.each_with_index do |param,id|
      next_param = @weapon.next_weapon.params[id]
      next if param == next_param
      text = sprintf(SText_Format,Vocab.param(id),param,next_param)
      result.push(text)
    end if @weapon
    return result
  end
end

class Window_SmithGold < Window_Gold
  def window_width
    return THEO::Smith::GoldWindow_Size
  end
end

class Window_SmithMenu < Window_Selectable
  
  def initialize(x,y)
    super(x,y,window_width,window_height)
    refresh
  end
  
  def window_width
    THEO::Smith::MenuActor_Size
  end
  
  def window_height
    fitting_height(item_max)
  end
  
  def item_max
    $game_party.members.size
  end
  
  def draw_item(index)
    actor = $game_party.members[index]
    color = normal_color
    color.alpha = enable?(index) ? 255 : translucent_alpha
    change_color(color)
    draw_text(item_rect(index),actor.name,alignment)
  end
  
  def alignment
    return 0
  end
  
  def weapon
    $game_party.members[index].equips[0]
  end
  
  def update_help
    @help_window.refresh(weapon)
  end
  
  def enable?(index)
    actor = $game_party.members[index]
    return false if actor.equips[0].nil?
    return actor.equips[0].next_weapon_exist? &&
      $game_party.gold >= actor.equips[0].next_weapon.upgrade_price
  end
  
  def current_item_enabled?
    enable?(index)
  end
  
end

class Window_SmithResult < Window_Base
  include THEO::Smith
  
  def next_weapon
    @weapon.next_weapon
  end
  
  def refresh(weapon)
    contents.clear
    @weapon = weapon
    return unless @weapon
    reset_font_settings
    draw_weapon_name
    if @weapon.next_weapon_exist?
      draw_next_weapon
    else
      draw_maxed_out
    end
  end
  
  def draw_weapon_name
    draw_item_name(@weapon,0,0)
    level = sprintf(SVocab::Level,@weapon.level)
    change_color(text_color(Colour::Level))
    draw_text(0,0,contents.width,line_height,level,2)
    contents.fill_rect(0,24,contents.width,2,Color.new(255,255,255,128))
  end
  
  def draw_next_weapon
    ypos = 28
    rect = Rect.new(0,ypos,contents.width,line_height)
    contents.font.size -= 4
    change_color(text_color(Colour::Upgradable))
    draw_text(rect,SVocab::Upgradable,2)
    change_color(system_color)
    draw_text(rect,SVocab::Cost)
    rect.x += text_size(SVocab::Cost).width
    change_color(normal_color)
    draw_text(rect,@weapon.next_weapon.upgrade_price)
    texts = obtain_params_change
    ypos += line_height
    texts.each do |txt|
      draw_text_ex(0,ypos,txt)
      ypos += line_height
    end
  end
  
  def draw_maxed_out
    ypos = 28
    rect = Rect.new(0,ypos,contents.width,line_height)
    contents.font.size -= 4
    change_color(text_color(Colour::Maxout))
    draw_text(rect,SVocab::Maxout,2)
  end
  
end

class Window_SmithNotif < Window_Base
  
  def initialize(width,menu_actor,help_window)
    super(0,0,width,0)
    self.openness = 0
    update_placement
    @show_count = -1
    @menu_actor = menu_actor
    @help_window = help_window
  end
  
  def update_placement
    self.x = Graphics.width/2 - self.width/2
    self.y = Graphics.height/2 - self.height/2
  end
  
  def height=(height)
    super
    update_placement
    create_contents
  end
  
  def show_weapon(weapon)
    @weapon = weapon
    @texts = obtain_params_change
    update_height
    refresh
    @show_count = THEO::Smith::NotifShowDuration
  end
  
  def update_height
    self.height = fitting_height(@texts.size + 1)
  end
  
  def refresh
    contents.clear
    rect = Rect.new(0,0,contents.width,line_height)
    next_name = @weapon.next_weapon.name
    if next_name != @weapon.name
      text = sprintf(THEO::Smith::SVocab::NotifNameChange,next_name)
      draw_text(rect,text)
    else
      text = THEO::Smith::SVocab::NotifNormal
      draw_text(rect,text)
    end
    ypos = line_height
    contents.fill_rect(0,ypos-1,contents.width,2,Color.new(255,255,255,128))
    @texts.each do |txt|
      draw_text_ex(0,ypos,txt)
      ypos += line_height
    end
  end
  
  def update
    super
    update_close_input
    if @show_count > 0
      open
    elsif @show_count == 0
      close
    end
  end
  
  def update_close_input
    @show_count -= 1
    @show_count = 0 if Input.trigger?(:C)
  end
  
  def open
    super
    @menu_actor.deactivate
    @help_window.set_text(THEO::Smith::SVocab::Upgraded_Quote)
  end
  
  def close
    super
    @menu_actor.activate
    @help_window.set_text(THEO::Smith::SVocab::Select_Weapon)
  end
  
end

class Window_SmithConfirm < Window_Command
  
  def initialize
    super(0,0)
    self.openness = 0
  end
  
  def make_command_list
    vocab = THEO::Smith::SVocab
    add_command(vocab::Yes_Confirm, :yes)
    add_command(vocab::No_Confirm, :no)
  end
  
  def window_width
    return THEO::Smith::Confirm_Width
  end
  
end

class Scene_Smith < Scene_MenuBase
  include THEO::Smith::SVocab
  
  def start
    super
    create_help_window
    create_actor_menu
    create_gold_window
    create_smith_result
    create_notif_smith
    create_confirm_window
  end
  
  def create_help_window
    @help_window = Window_Help.new(1)
    @help_window.set_text(Select_Weapon)
  end
  
  def create_actor_menu
    y = @help_window.height
    @menu_actor = Window_SmithMenu.new(0,y)
    @menu_actor.set_handler(:cancel, method(:return_scene))
    @menu_actor.set_handler(:ok, method(:on_actor_ok))
    @menu_actor.activate
    @menu_actor.select(0)
  end
  
  def create_smith_result
    x = @menu_actor.width
    y = @help_window.height
    w = Graphics.width - @menu_actor.width - @gold_window.width
    h = 24 * 9 + 4
    @smith_result = Window_SmithResult.new(x,y,w,h)
    @menu_actor.help_window = @smith_result
  end
  
  def create_gold_window
    @gold_window = Window_SmithGold.new
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = @help_window.height
  end
  
  def create_notif_smith
    @notif_smith = Window_SmithNotif.new(300,@menu_actor,@help_window)
  end
  
  def create_confirm_window
    @confirm =  Window_SmithConfirm.new
    @confirm.set_handler(:yes, method(:craft_weapon))
    @confirm.set_handler(:no, method(:confirm_no))
    @confirm.set_handler(:cancel, method(:confirm_no))
    @confirm.x = @smith_result.x + @smith_result.width - @confirm.width
    @confirm.y = @smith_result.y + @smith_result.height - @confirm.height
  end
  
  def on_actor_ok
    @confirm.open
    @confirm.activate
    @help_window.set_text(Decide_Weapon)
  end
  
  def confirm_no
    @confirm.close
    @menu_actor.activate
    @help_window.set_text(Select_Weapon)
  end
  
  def craft_weapon
    @confirm.close
    @confirm.deactivate
    $game_party.gain_item(next_weapon,1)
    $game_party.lose_gold(next_weapon.upgrade_price)
    last_equip = item_to_lose
    @notif_smith.show_weapon(last_equip)
    actor.change_equip(0,next_weapon)
    $game_party.lose_item(last_equip,1)
    @menu_actor.update_help
    @menu_actor.activate
    @menu_actor.refresh
    @gold_window.refresh
  end
  
  def next_weapon
    @smith_result.next_weapon
  end
  
  def actor
    $game_party.members[@menu_actor.index]
  end
  
  def item_to_lose
    actor.equips[0]
  end
  
end

class Game_Actor < Game_Battler
  def weapons
    @equips.select {|item| item.is_weapon? ||
    item.upgraded_weapon? }.collect {|item| item.object }
  end
end
