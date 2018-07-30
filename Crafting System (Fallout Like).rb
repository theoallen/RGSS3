# =============================================================================
# TheoAllen - (Fallout Like) Crafting System
# Version : 1.1
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (English documentation)
# =============================================================================
($imported ||= {})[:Theo_Crafting] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2013.08.25 - Bugfix disable req text isn't working
# 2013.08.22 - Bugfix at amount of item crafting
#            - Added show condition
#            - Added custom name
# 2013.08.20 - Finished script
# 2013.08.19 - Started script
# =============================================================================
=begin
 
  ---------------------------------------------------------------------------
  Introduction :
  This script allow you to craft the item based on its recipes
  
  ---------------------------------------------------------------------------
  How to use :
  ---------------------------------------------------------------------------
  Put this script below material but above main
  To call crafting menu, write down this following line to your script call : 
  
  enter_crafting
  
  ---------------------------------------------------------------------------
  Notetags (For Items/Armors/Weapons):
  ---------------------------------------------------------------------------
  -----------------------------------
  Level : Easy
  -----------------------------------
  <add item recipe: id,amount>
  <add armor recipe: id,amount>
  <add weapon recipe: id,amount>
  ^
  These notetags used to determine the recipes of the item/armor/weapon. Id is
  the recipe id in database. Amount is the minimum item number in player 
  inventory
  
  <craft name: text>
  ^
  This notetag is to change item name temporary. For example, in your crafting
  list, potion will be drawn in "Craft potions". But, after you got the potion,
  the name back to original.
  
  -----------------------------------
  Level : Medium - Hard 
  (Do not try to use if you don't know)
  -----------------------------------
  <craft require>
  script
  </craft require>
  ^
  These notetags are to determine if the item is can be crafted or not. It's
  determined by script. If you're using many lines, it will count as a part of
  one line. I wrote the scripts call instruction elsewhere. Too bad, it is in
  Indonesian
  
  The writing error may causes the game to crash. So. it's better to ask me 
  first or make a RGSSx support thread in RPG Maker Forum. They may help you (if 
  you're lucky)
  
  <craft req text>
  some text here
  </craft req text>
  ^
  These notetags is for representation of script call above. For example, to
  make a certain item is require at least a silver hammer. You could write it
  like this
  
  <craft req text>
  This items need a silver hammer 
  </craft req text>
  
  <craft show eval>
  script
  </craft show eval>
  ^
  These notetags is to determine item whether is shown in the list or not. For
  example, to craft an elixir, you need to learn high level alchemy. So, it
  won't show until you (the player) learn a certain skill
  
  The writing error may causes the game to crash. So. it's better to ask me 
  first or make a RGSSx support thread in RPG Maker Forum. They may help you (if 
  you're lucky)
  
  ---------------------------------------------------------------------------
  Terms of Use :
  ---------------------------------------------------------------------------
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.

=end
# =============================================================================
# Configurations :
# =============================================================================
module THEO
  module Craft
  
  # --------------------------------------------------------------------------
  # General Settings (true/false)
  # --------------------------------------------------------------------------
    MainMenu        = true
  # Set true if the crafting menu can be accessed in main menu
  
    DisplayReqText  = true
  # For you who do not need the requirement text. You could disable it here
  
  # --------------------------------------------------------------------------
  # Vocab Settings (Text/String)
  # --------------------------------------------------------------------------
    VocabMenu      = "Craft"          # Main Menu crafting command
    VocabNoReq     = "- None -"       # If there's no special requirement
    VocabRequire   = "Requirement :"  # Requirement Vocab
    VocabRecipes   = "Recipes : "     # Recipe Vocab
    VocabInventory = "Inventory: "    # Vokab for inventory
    
  # --------------------------------------------------------------------------
  # Miscs (Numeric / 0123456789)
  # --------------------------------------------------------------------------
    Text_Buffer_x = 12
  # Additional text distance from left side
  
    AmountSize = 250
  # Width of amount window
  
  end
end
# =============================================================================
# End of config. Do not try to touch my private material pass this line
# =============================================================================
module THEO
  module Craft
    def self.items
      items = $data_items + $data_armors + $data_weapons
      items.compact!
      items.select {|item| item.can_be_crafted? }
    end
  end
end

class RPG::BaseItem
  attr_accessor :item_recipes
  attr_accessor :armor_recipes
  attr_accessor :weapon_recipes
  attr_accessor :enable_cond
  attr_accessor :enable_text
  attr_accessor :show_cond
  attr_accessor :craft_name
  attr_accessor :craft_key  # For future planned feature
  
  def load_recipes
    @item_recipes = {}
    @armor_recipes = {}
    @weapon_recipes = {}
    @show_cond = @enable_cond = "true"
    @enable_text = []
    @craft_name = ""
    @craft_key = ""
    read_craft_cond = read_craft_txt = read_craft_show = false
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when /<(?:ADD_ITEM_RECIPE|add item recipe): (.*)>/i
        str = $1.scan(/\d+/)
        @item_recipes[str[0].to_i] = str[1].to_i
      when /<(?:ADD_ARMOR_RECIPE|add armor recipe): (.*)>/i
        str = $1.scan(/\d+/)
        @armor_recipes[str[0].to_i] = str[1].to_i
      when /<(?:ADD_WEAPON_RECIPE|add WEAPON recipe): (.*)>/i
        str = $1.scan(/\d+/)
        @weapon_recipes[str[0].to_i] = str[1].to_i
      when /<(?:CRAFT_REQUIRE|craft require)>/i
        read_craft_cond = true
        @enable_cond = ""
      when /<\/(?:CRAFT_REQUIRE|craft require)>/i
        read_craft_cond = false
      when /<(?:CRAFT_REQ_TEXT|craft req text)>/i
        read_craft_txt = true
      when /<\/(?:CRAFT_REQ_TEXT|craft req text)>/i
        read_craft_txt = false
      when /<(?:CRAFT_SHOW_EVAL|craft show eval)>/i
        read_craft_show = true
        @show_cond = ""
      when /<\/(?:CRAFT_SHOW_EVAL|craft show eval)>/i
        read_craft_show = false
      when /<(?:CRAFT_NAME|craft name): (.*)>/i
        @craft_name = $1.to_s
      when /<(?:CRAFT_KEY|craft key): [ ]*(.*)>/i
        @craft_key = $1.to_s
      else
        if read_craft_cond
          @enable_cond += line
        end
        if read_craft_txt
          @enable_text.push(line)
        end
        if read_craft_show
          @show_cond += line
        end
      end
    end
  end
  
  def recipes
    [@item_recipes, @armor_recipes, @weapon_recipes]
  end
  
  # ---------------------------------------------------------------------------
  # If the error is directed you to this line. It's possible that you wrote
  # craft requirement formula in a wrong way. Not this script mistake
  # ---------------------------------------------------------------------------
  def craft_possible?
    return eval(@enable_cond) && can_be_crafted?
  end
  
  def show_possible?
    return eval(@show_cond)
  end
  # ---------------------------------------------------------------------------
  # Determine if item can be crafted
  # ---------------------------------------------------------------------------
  def can_be_crafted?
    recipes.any? {|recipe| !recipe.empty?} && show_possible?
  end
  
end

class << DataManager
  
  alias theo_recipe_craft_load_db load_database
  def load_database
    theo_recipe_craft_load_db
    load_item_recipes
  end
  
  def load_item_recipes
    ($data_items+$data_armors+$data_weapons).compact.each do |db|
      db.load_recipes
    end
  end
  
end

class Window_CraftList < Window_ItemList
  
  def initialize(x,y,w,h,key)
    @key = key
    super(x,y,w,h)
    refresh
  end
  
  def col_max
    return 1
  end
  
  def status_window=(window)
    @status_window = window
    update_help
  end
  
  def item_number_window=(window)
    @inum_window = window
    update_help
  end
  
  def update_help
    super
    @status_window.set_item(item) if @status_window
    @inum_window.set_item(item) if @inum_window
  end
  
  def make_item_list
    @data = []
    items = THEO::Craft.items
    items.each do |item|
      @data.push(item) if @key.empty? || item.craft_key == @key
    end
  end
  
  def enable?(item)
    item.craft_possible? && has_recipes?(item) && has_free_slot?(item)
  end
  
  def has_free_slot?(item)
    $game_party.item_number(item) < $game_party.max_item_number(item)
  end
  
  def has_recipes?(item)
    result1 = check_recipe(item.recipes[0], $data_items)
    result2 = check_recipe(item.recipes[1], $data_armors)
    result3 = check_recipe(item.recipes[2], $data_weapons)
    return result1 && result2 && result3
  end
  
  def check_recipe(recipes, data)
    return true if recipes.empty?
    return recipes.all? {|recipe| 
      $game_party.item_number(data[recipe[0]]) >= recipe[1]} 
  end
  
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    name = item.craft_name.empty? ? item.name : item.craft_name
    draw_text(x + 24, y, width, line_height, name)
  end
  
  def draw_item_number(rect, item)
    return unless $imported[:Theo_LimInventory]
    return unless THEO::LimInv::Display_ItemSize
    draw_text(rect, sprintf(":%2d", item.inv_size), 2)
  end
  
end

class Window_CraftStatus < Window_Base
  
  def set_item(item)
    @item = item
    refresh
  end
  
  def refresh
    contents.clear
    return unless @item
    @line_count = 0
    draw_requirement
    draw_recipes
  end
  
  def draw_requirement
    return unless THEO::Craft::DisplayReqText
    change_color(system_color)
    draw_text(line_rect(4),THEO::Craft::VocabRequire)
    increase_line_count
    if !@item.enable_text.empty?
      change_color(normal_color, @item.craft_possible?)
      @item.enable_text.each do |text|
        draw_text(line_rect(buff_x),text)
        increase_line_count
      end
      increase_line_count
    else
      change_color(normal_color)
      draw_text(line_rect(buff_x),THEO::Craft::VocabNoReq)
      2.times { increase_line_count }
    end
  end
  
  def draw_recipes
    change_color(system_color)
    draw_text(line_rect(4),THEO::Craft::VocabRecipes)
    change_color(normal_color)
    increase_line_count
    draw_recipe(@item.recipes[0], $data_items)
    draw_recipe(@item.recipes[1], $data_armors)
    draw_recipe(@item.recipes[2], $data_weapons)
  end
  
  def draw_recipe(hash, items)
    hash.each do |id,amount|
      item_num = $game_party.item_number(items[id])
      enable = item_num >= amount
      change_color(normal_color, enable)
      rect = line_rect(buff_x + 24)
      text = sprintf("%s (%d/%d)",items[id].name, item_num, amount)
      draw_text(rect, text)
      draw_icon(items[id].icon_index, buff_x, @line_count, enable)
      increase_line_count
    end
  end  
  
  def line_rect(xpos = 0)
    Rect.new(xpos,@line_count,contents.width-xpos,line_height)
  end
  
  def increase_line_count
    @line_count += line_height
  end
  
  def buff_x
    THEO::Craft::Text_Buffer_x
  end
  
end

class Window_CraftAmount < Window_Base
  attr_accessor :inv_window
  attr_accessor :ok_handler
  attr_accessor :cancel_handler
  attr_reader :amount
  
  def initialize
    super(0,0,window_width,fitting_height(1))
    self.openness = 0
    to_center
    @amount = 0
    @max = 0
    @item = nil
  end
  
  def window_width
    return THEO::Craft::AmountSize
  end
  
  def to_center
    self.x = (Graphics.width - width)/2
    self.y = (Graphics.height - height)/2
  end
  
  def set(item, max)
    change_amount(0,true)
    @item = item
    @max = max
    open
    refresh
  end
  
  def refresh
    contents.clear
    return unless @item
    draw_item_name(@item,0,0,true,contents.width)
    draw_amount
  end
  
  def draw_amount
    text = sprintf("%d/%d",@amount,@max)
    draw_text(0,0,contents.width,line_height,text,2)
  end
  
  def update
    super
    if open?
      change_amount(1) if Input.repeat?(:RIGHT)
      change_amount(-1) if Input.repeat?(:LEFT)
      change_amount(10) if Input.repeat?(:UP)
      change_amount(-10) if Input.repeat?(:DOWN)
      call_ok if Input.trigger?(:C)
      call_cancel if Input.trigger?(:B)
    end
  end
  
  def change_amount(number, instant = false)
    if instant
      @amount = number
    else
      Sound.play_cursor
      @amount = [[@amount + number,0].max,@max].min
    end
    refresh
    @inv_window.amount = @amount if @inv_window
  end
  
  def call_ok
    Sound.play_ok
    ok_handler.call
    change_amount(0,true)
    close
  end
  
  def call_cancel
    Sound.play_cancel
    cancel_handler.call
    change_amount(0,true)
    close
  end
  
end

class Window_CraftFooter < Window_Base
  
  def initialize
    super(0,0,Graphics.width,fitting_height(1))
    self.y = Graphics.height - height
    @amount = 0
    @item = nil
    refresh
  end
  
  def amount=(amount)
    @amount = amount
    refresh
  end
  
  def refresh
    contents.clear
    change_color(system_color)
    draw_text(0,0,contents.width,line_height,THEO::Craft::VocabInventory)
    change_color(normal_color)
    return unless @item
    if $imported[:Theo_LimInventory]
      draw_inv_slot(0,0)
    else
      draw_item_number
    end
  end
  
  def draw_inv_slot(x,y,width = contents.width,align = 2)
    total = $game_party.total_inv_size + @amount*@item.inv_size
    total -= calculate_lose_item
    txt = sprintf("%d/%d", total, $game_party.inv_max)
    color = THEO::LimInv::NearMaxed_Color
    near_max = total.to_f/$game_party.inv_max >= 
      (100 - THEO::LimInv::NearMaxed_Percent).to_f / 100 
    if near_max
      change_color(text_color(color))
    else
      change_color(normal_color)
    end
    draw_text(x,y,width,line_height,txt,align)
    change_color(normal_color)
  end
  
  def draw_item_number
    txt = sprintf("%d/%d",@amount + $game_party.item_number(@item),
      $game_party.max_item_number(@item))
    draw_text(0,0,contents.width,line_height,txt,2)
  end
  
  def set_item(item)
    @item = item
    refresh
  end
  
  def calculate_lose_item
    result = 0
    @item.recipes[0].each do |id,amount|
      data = $data_items[id]
      amount *= @amount
      result += amount
    end
    @item.recipes[1].each do |id,amount|
      data = $data_armors[id]
      amount *= @amount
      result += amount
    end
    @item.recipes[2].each do |id,amount|
      data = $data_weapons[id]
      amount *= @amount
      result += amount
    end
    return result
  end
  
end

class Game_Interpreter
  
  # ----------------------------------------------
  # key is just for my future planned feature
  # ----------------------------------------------
  def enter_crafting(key = "")
    SceneManager.call(Scene_ItemCrafting)
    SceneManager.scene.prepare(key)
    Fiber.yield
  end
  
end

class Window_MenuCommand < Window_Command
  
  alias theo_craft_ori_cmd add_original_commands
  def add_original_commands
    theo_craft_ori_cmd
    return unless THEO::Craft::MainMenu
    add_command(THEO::Craft::VocabMenu, :craft)
  end
  
end

class Scene_Menu < Scene_MenuBase
  
  alias theo_craft_cmnd_window create_command_window
  def create_command_window
    theo_craft_cmnd_window
    @command_window.set_handler(:craft, method(:enter_crafting))
  end
  
  def enter_crafting
    SceneManager.call(Scene_ItemCrafting)
    SceneManager.scene.prepare("")
  end
  
end

class Scene_ItemCrafting < Scene_MenuBase
  
  def prepare(key)
    @key = key
  end
  
  def start
    super
    create_help_window
    create_craftfooter_window
    create_craftlist_window
    create_craftstatus_window
    create_craftamount_window
  end
  
  def create_craftfooter_window
    @craft_footer = Window_CraftFooter.new
  end
  
  def create_craftlist_window
    wy = @help_window.height
    ww = Graphics.width/2
    wh = Graphics.height - wy - @craft_footer.height
    @craft_list = Window_CraftList.new(0,wy,ww,wh,@key)
    @craft_list.set_handler(:ok, method(:on_craft_ok))
    @craft_list.set_handler(:cancel, method(:return_scene))
    @craft_list.help_window = @help_window
    @craft_list.item_number_window = @craft_footer
    @craft_list.activate
    @craft_list.select(0)
  end
  
  def create_craftstatus_window
    wx = @craft_list.width
    wy = @craft_list.y
    ww = @craft_list.width
    wh = @craft_list.height
    @craft_status = Window_CraftStatus.new(wx,wy,ww,wh)
    @craft_list.status_window = @craft_status
  end
  
  def create_craftamount_window
    @craft_amount = Window_CraftAmount.new
    @craft_amount.ok_handler = method(:on_amount_ok)
    @craft_amount.cancel_handler = method(:on_amount_cancel)
    @craft_amount.inv_window = @craft_footer
  end
  
  def on_craft_ok
    @craft_amount.set(item, item_max)
  end
  
  def on_amount_ok
    $game_party.gain_item(item, @craft_amount.amount)
    lose_recipes
    @craft_status.refresh
    @craft_list.refresh
    @craft_list.activate
  end
  
  def on_amount_cancel
    @craft_list.activate
  end
  
  def item
    @craft_list.item
  end
  
  def item_max
    ary = []
    item.recipes[0].each do |id,amount|
      data = $data_items[id]
      ary.push($game_party.item_number(data)/amount)
    end
    item.recipes[1].each do |id,amount|
      data = $data_armors[id]
      ary.push($game_party.item_number(data)/amount)
    end
    item.recipes[2].each do |id,amount|
      data = $data_weapons[id]
      ary.push($game_party.item_number(data)/amount)
    end
    max_item = $game_party.max_item_number(item)
    inum = $game_party.item_number(item)
    return [ary.min , max_item - inum].min
  end
  
  def lose_recipes
    item.recipes[0].each do |id,amount|
      data = $data_items[id]
      amount *= @craft_amount.amount
      $game_party.lose_item(data,amount)
    end
    item.recipes[1].each do |id,amount|
      data = $data_armors[id]
      amount *= @craft_amount.amount
      $game_party.lose_item(data,amount)
    end
    item.recipes[2].each do |id,amount|
      data = $data_weapons[id]
      amount *= @craft_amount.amount
      $game_party.lose_item(data,amount)
    end
  end
  
end
