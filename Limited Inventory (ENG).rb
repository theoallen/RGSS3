# =============================================================================
# TheoAllen - Limited Inventory
# Version : 1.4
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (English Documentation)
# =============================================================================
($imported ||= {})[:Theo_LimInventory] = true
# =============================================================================
# Change logs:
# -----------------------------------------------------------------------------
# 2015.02.02 - Added slowdown penalty when the inventory is full
#            - Added disable dash when the inventory is full
#            - Added force gain item to supports those newly added features
# 2014.09.22 - Bugfix. Negative number appear when use item and inventory 
#              reached its limit.
#            - Compatibility patch with YEA Menu Cursor
#            - Compatibility patch with MOG Menu Cursor as well
# 2014.02.25 - Add limited inventory eval formula to provide flexibility
#            - Change notetag constant to provide flexibility
# 2014.02.16 - Base Inventory slot of an actor can be changed using script call
# 2014.02.11 - Bugfix. Unequip item causes lose the item if inventory is full
# 2013.10.07 - Bugfix. Item doesn't removed when discarded
#            - Bugfix. Inventory amount not refreshed when item is discarded
# 2013.10.04 - Compatibility fix with chest system
# 2013.08.30 - Now unable to discard key item
# 2013.08.22 - Bugfix. Item size notetag isn't working
# 2013.08.19 - Bugfix when gained item
#            - Bugfix when disable display item size in shop menu
# 2013.08.18 - Finished script
# =============================================================================
=begin

  ---------------------------------------------------------------------------
  Introduction :
  This script allow you to limit your inventory by overall possesed items
  instead of individual items
  
  ---------------------------------------------------------------------------
  How to Use :
  Put this script below material but above main
  If you're using YEA - Shop Option, put it below that script
  Edit configurations and the notetags as described below
  
  ---------------------------------------------------------------------------
  Notetags :
  write down these notetags to the notebox in your database
  
  <inv size: n>
  Use this notetag where the n is a numeric value which is determine the size 
  of item. Use 0 for unlimited item. Only works for item and equipment such as 
  weapon or armor.
  
  <inv plus: n>
  Use this notetag to determine the additional avalaible free inventory slot.
  This notetag avalaible for Actor, Class, Equip, and States. If it's for 
  actor, avalaible inventory slot will increase when a new actor entered party. 
  If it's for equip, the avalaible slot will be increase if the certain equip 
  is equipped. And so do states.
  
  This value can be changed by script call during the game. Just check the
  script call instruction.
  
  <inv minus: n>
  Inverse of <inv plus>. It will decrease the avalaible inventory slot. Pretty
  clear I think.
  
  <inv formula>
  script
  </inv formula>
  This notetag is used to determine inventory limit based on your own formula
  For example, inventory limit for an actor is based on its agility or even
  its level. It can be used inside actor or class notebox.
  
  Inventory formula is automatically accumulated with base inventory. I mean,
  if you're going to add <inv plus: 100> and your formula. Then, the result is
  ==> 100 + your formula
  
  Example :
  <inv formula>
  level * 100
  </inv formula>
  By using this formula it means that each actor has leveled up, its base
  inventory will be increase by 100. If you're using multiple lines, it will be
  considered as a one line. You can also using these parameters to determine 
  your own formula.
  
  - mhp
  - mmp
  - atk
  - def
  - mat
  - mdf
  - agi
  - luk
  - $game_variables[id]
  
  Note :
  - A false formula may produce an error. So, make sure you write the correct 
    formula. Alternatively, you can ask ppl out there to help you out.
  - For scripter, the formula eval is evaled inside Game_Actor

  ---------------------------------------------------------------------------
  Script call :
  If you want to force gain an item even the inventory is full, you can do it
  by script call. Just write this following line
  
  force_gain_item($data_items[id],amount)
  id is an item id in your database
  
  To change base inventory for an actor, use these script call
  $game_actors[id].base_inv = value     << Set
  $game_actors[id].base_inv += value    << Add
  $game_actors[id].base_inv -= value    << Substract
  
  If you set dynamic slot as false, you can change inventory limit by using
  this script call.
  $game_party.base_inv = value
  
  ---------------------------------------------------------------------------
  Terms of use :
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.

=end
# =============================================================================
# Configurations :
# =============================================================================
module Theo
  module LimInv
  
  # --------------------------------------------------------------------------
  # General Settings (just put true / false)
  # --------------------------------------------------------------------------
  
    DynamicSlot       = true
  # Total avalaible inventory slot depends on actor, states, total party 
  # members, etc ...
  
    Display_ItemSize  = true
  # Diplay item size in item menu
  
    Include_Equip     = false
  # Total used inventory slot will also include actor equipment.
  
    DrawTotal_Size    = true
  # If true, item size window will show total weight of specified item. For 
  # example, you have 10 potions. And each potion has 3 size/weight. The window 
  # will show 30 instead of 3
  
    ForceGain         = true
  # Keep force to gain item when the item is full. Please set some penalties
  # when the inventory is full below to serve the purpose of this script
  # This overwrite the method gain item from default script. There is a chance 
  # of incompatibility between different script which also use the same method
    
    Full_DisableDash  = true
  # Disable dash when the inventory is full. Should be used when ForceGain
  # is set to true. If use together with YEA System Option, please put this
  # script below the YEA system option, unless you get rid completely the
  # autodash config in Yanfly's script
  
    Full_SlowDown     = true
  # Slowdown the player movement by 1 when the inventory is full Should be
  # used when ForceGain is set to true
  
  # --------------------------------------------------------------------------
  # Numeric Settings
  # --------------------------------------------------------------------------
  
    Default_FreeSlot  = 20
  # Default values which is provided each actor. Of course, you may change
  # it by notetag. If DynamicSlot is set to false, it will be used as the total
  # avalaible slot
  
    NearMaxed_Percent = 25
  # Remain avalaible slot percentage to determine if the inventory is almost 
  # maxed out or not.
  
    NearMaxed_Color   = 21
  # If inventory is almost maxed out, the inventory window will be drawn in
  # different color. The color code is same as \C[n] in message
  
    UseCommand_Size   = 200    
  # The width of use item command window
  
  # --------------------------------------------------------------------------
  # Vocab Settings (Self-explanatory I think)
  # --------------------------------------------------------------------------
  
    InvSlotVocab    = "Inventory: "   # Inventory Vocab
    InvSizeVocab    = "Item Size: "   # Item size / weight
    SlotVocabShort  = "Inv:"          # Abbreviation for Inventory
    UseVocab        = "Use item"      # Use item
    DiscardVocab    = "Discard item"  # Discard Item
    CancelVocab     = "Cancel"        # Cancel
    
  end
end
# ============================================================================
# Do not touch anything pass this line.
# ============================================================================
=begin
  -----------------------------------------------------------------------------
  Compatibility info :
  -----------------------------------------------------------------------------
  This script overwrite these methods :
  Game_Actor  >> trade_item_with_party
  Game_Party  >> max_item_number
  Game_Party  >> item_max?
  Game_Party  >> lose_item
  
  -----------------------------------------------------------------------------
  This script aliased these methods :
  DataManager >> load_database
  Game_Actor  >> setup
  Game_Party  >> initialize
  Scene_Menu  >> start
  Scene_Item  >> start
  Scene_Item  >> use_item
  Scene_Shop  >> on_buy_ok
  Scene_Shop  >> on_sell_ok

=end
# =============================================================================
# Altered built in modules and classes
# =============================================================================
# =============================================================================
# ▼ DataManager
# =============================================================================
class << DataManager
  
  alias theo_limited_item_load_db load_database
  def load_database
    theo_limited_item_load_db
    load_limited_slot
  end
  
  def load_limited_slot
    database = $data_actors + $data_classes + $data_weapons + $data_armors + 
      $data_states + $data_items
    database.compact.each do |db|
      db.load_limited_inv
    end
  end
end
# =============================================================================
# ▼ RPG::BaseItem
# =============================================================================
class RPG::BaseItem
  attr_accessor :inv_size # Item inventory size
  attr_accessor :inv_mod  # Inventory slot modifier
  attr_accessor :inv_eval # Inventory eval modifier
  
  InvSizeREGX     = /<inv[\s_]+size\s*:\s*(\d+)>/i
  InvPlusREGX     = /<inv[\s_]+plus\s*:\s*(\d+)>/i
  InvMinusREGX    = /<inv[\s_]+minus\s*:\s*(\d+)/i
  InvFormSTART    = /<inv[\s_]+formula>/i
  InvFormEND      = /<\/inv[\s_]+formula>/i
  
  def load_limited_inv
    load_eval = false
    @inv_size = 1
    @inv_eval = '0'
    @inv_mod = self.is_a?(RPG::Actor) ? Theo::LimInv::Default_FreeSlot : 0
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when InvSizeREGX
        @inv_size = $1.to_i
      when InvPlusREGX
        @inv_mod = $1.to_i
      when InvMinusREGX
        @inv_mod = -$1.to_i
      when InvFormSTART
        load_eval = true
        @inv_eval = ''
      when InvFormEND
        load_eval = false
      else
        @inv_eval += line if load_eval
      end
    end
  end
  
end
# =============================================================================
# Data structures and workflows goes here
# =============================================================================
# =============================================================================
# ▼ Game_Actor
# =============================================================================
class Game_Actor < Game_Battler
  attr_accessor :base_inv
  
  alias theo_liminv_setup setup
  def setup(actor_id)
    theo_liminv_setup(actor_id)
    @base_inv = $data_actors[id].inv_mod
  end
  
  def equip_size
    return 0 unless Theo::LimInv::Include_Equip
    equips.compact.inject(0) {|total,equip| total + equip.inv_size}
  end
  
  def inv_max
    result = base_inv
    result += $data_classes[class_id].inv_mod
    result += states.inject(0) {|total,db| total + db.inv_mod}
    result += equips.compact.inject(0) {|total,db| total + db.inv_mod}
    result += eval(actor.inv_eval)
    result += eval(self.class.inv_eval)
    result
  end
  # --------------------------------------------------------------------------
  # Overwrite : Trade item with party
  # --------------------------------------------------------------------------
  def trade_item_with_party(new_item, old_item)
    return false if new_item && !$game_party.has_item?(new_item)
    $game_party.force_gain_item(old_item, 1)
    $game_party.force_gain_item(new_item, -1)
    return true
  end
  
end
# =============================================================================
# ▼ Game_Party
# =============================================================================
class Game_Party < Game_Unit
  attr_accessor :base_inv
  
  alias theo_liminv_init initialize
  def initialize
    @base_inv = (Theo::LimInv::DynamicSlot ? 0 : Theo::LimInv::Default_FreeSlot)
    theo_liminv_init
  end
  
  def inv_max
    return @base_inv unless Theo::LimInv::DynamicSlot
    return members.inject(0) {|total,member| total + member.inv_max} + @base_inv
  end
  
  def inv_maxed?
    inv_max <= total_inv_size
  end
  
  def total_inv_size
    result = all_items.inject(0) {|total,item| total + 
      (item_number(item) * item.inv_size)}
    result += members.inject(0) {|total,member| total + member.equip_size}
    result
  end
  
  alias theo_liminv_max_item max_item_number
  def max_item_number(item)
    $BTEST ? theo_liminv_max_item(item) : inv_max_item(item) + item_number(item)
  end
  
  def inv_max_item(item)
    return 9999999 if item.nil? || item.inv_size == 0
    free_slot / item.inv_size
  end
  
  def free_slot
    inv_max - total_inv_size
  end
  
  alias theo_liminv_item_max? item_max?
  def item_max?(item)
    $BTEST ? theo_liminv_item_max?(item) : inv_maxed?
  end
  
  def near_maxed?
    free_slot.to_f / inv_max <= Theo::LimInv::NearMaxed_Percent/100.0
  end
  
  def item_size(item)
    return 0 unless item
    item.inv_size * item_number(item)
  end
  
  def force_gain_item(item, amount, include_equip = false)
    container = item_container(item.class)
    return unless container
    last_number = item_number(item)
    new_number = last_number + amount
    container[item.id] = [new_number, 0].max
    container.delete(item.id) if container[item.id] == 0
    if include_equip && new_number < 0
      discard_members_equip(item, -new_number)
    end
    $game_map.need_refresh = true
  end
  
  def lose_item(item, amount, include_equip = false)
    force_gain_item(item, -amount, include_equip)
  end
  
  alias theo_liminv_gain_item gain_item
  def gain_item(item, amount, include_equip = false)
    if Theo::LimInv::ForceGain
      force_gain_item(item, amount, include_equip)
    else
      theo_liminv_gain_item(item, amount, include_equip)
    end
  end
  
end
# =============================================================================
# ▼ Game_Player
# =============================================================================
class Game_Player
  
  alias theo_liminv_dash? dash?
  def dash?
    return false if Theo::LimInv::Full_DisableDash && $game_party.inv_maxed?
    return theo_liminv_dash?
  end
  
  alias theo_liminv_real_move_speed real_move_speed
  def real_move_speed
    theo_liminv_real_move_speed - move_penalty
  end
  
  def move_penalty
    Theo::LimInv::Full_SlowDown && $game_party.inv_maxed? ? 1 : 0
  end
  
end
# =============================================================================
# ▼ Game_Interpreter
# =============================================================================
class Game_Interpreter
  def force_gain_item(item, amount)
    $game_party.force_gain_item(item, amount)
  end
end
# =============================================================================
# Window related class goes here
# =============================================================================
# =============================================================================
# ▼ Window_Base
# =============================================================================
class Window_Base < Window
  def draw_inv_slot(x,y,width = contents.width,align = 2)
    txt = sprintf("%d/%d",$game_party.total_inv_size, $game_party.inv_max)
    color = Theo::LimInv::NearMaxed_Color
    if $game_party.near_maxed?
      change_color(text_color(color))
    else
      change_color(normal_color)
    end
    draw_text(x,y,width,line_height,txt,align)
    change_color(normal_color)
  end
  
  def draw_inv_info(x,y,width = contents.width)
    change_color(system_color)
    draw_text(x,y,width,line_height,Theo::LimInv::InvSlotVocab)
    change_color(normal_color)
    draw_inv_slot(x,y,width)
  end
  
  def draw_item_size(item,x,y,total = true,width = contents.width)
    rect = Rect.new(x,y,width,line_height)
    change_color(system_color)
    draw_text(rect,Theo::LimInv::InvSizeVocab)
    change_color(normal_color)
    number = (Theo::LimInv::DrawTotal_Size && total) ? 
      $game_party.item_size(item) : item.nil? ? 0 : item.inv_size
    draw_text(rect,number,2)
  end
end
# =============================================================================
# ▼ New Class : Window_MenuLimInv
# =============================================================================
class Window_MenuLimInv < Window_Base
  
  def initialize(width)
    super(0,0,width,fitting_height(1))
    refresh
  end
  
  def refresh
    contents.clear
    change_color(system_color)
    txt = Theo::LimInv::SlotVocabShort
    draw_text(0,0,contents.width,line_height,txt)
    draw_inv_slot(0,0)
  end
  
end
# =============================================================================
# ▼ New Class : Window_ItemSize
# =============================================================================
class Window_ItemSize < Window_Base
  
  def initialize(x,y,width)
    super(x,y,width,fitting_height(1))
  end
  
  def set_item(item)
    @item = item
    refresh 
  end
  
  def refresh
    contents.clear
    draw_item_size(@item,0,0)
  end
  
end
# =============================================================================
# ▼ New Class : Window_FreeSlot
# =============================================================================
class Window_FreeSlot < Window_Base
  def initialize(x,y,width)
    super(x,y,width,fitting_height(1))
    refresh
  end
  
  def refresh
    contents.clear
    draw_inv_info(0,0)
  end
end
# =============================================================================
# ▼ New Class : Window_ItemUseCommand
# =============================================================================
class Window_ItemUseCommand < Window_Command
  include Theo::LimInv
  
  def initialize
    super(0,0)
    self.openness = 0
  end
  
  def set_item(item)
    @item = item
    refresh
  end
  
  def window_width
    UseCommand_Size
  end
  
  def make_command_list
    add_command(UseVocab, :use, $game_party.usable?(@item))
    add_command(DiscardVocab, :discard, discardable?(@item))
    add_command(CancelVocab, :cancel)
  end
  
  def to_center
    self.x = Graphics.width/2 - width/2
    self.y = Graphics.height/2 - height/2
  end
  
  def discardable?(item)
    return false if item.nil?
    !(item.is_a?(RPG::Item) && item.itype_id == 2)
  end
  
end
# =============================================================================
# ▼ New Class : Window_DiscardAmount
# =============================================================================
class Window_DiscardAmount < Window_Base
  attr_accessor :cmn_window
  attr_accessor :itemlist
  attr_accessor :freeslot
  
  def initialize(x,y,width)
    super(x,y,width,fitting_height(1))
    self.openness = 0
    @amount = 0
  end
  
  def set_item(item)
    @item = item
    @amount = 0
    refresh
  end
  
  def refresh
    contents.clear
    return unless @item
    draw_item_name(@item,0,0,true,contents.width)
    txt = sprintf("%d/%d",@amount, $game_party.item_number(@item))
    draw_text(0,0,contents.width,line_height,txt,2)
  end
  
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, item.name + ":")
  end
  
  def update
    super
    return unless open?
    change_amount(1) if Input.repeat?(:RIGHT)
    change_amount(-1) if Input.repeat?(:LEFT)
    change_amount(10) if Input.repeat?(:UP)
    change_amount(-10) if Input.repeat?(:DOWN)
    lose_item if Input.trigger?(:C)
    close_window if Input.trigger?(:B)
  end
  
  def change_amount(num)
    @amount = [[@amount+num,0].max,$game_party.item_number(@item)].min
    Sound.play_cursor
    refresh
  end
  
  def lose_item
    $game_party.lose_item(@item,@amount)
    @itemlist.redraw_current_item
    @freeslot.refresh
    if $game_party.item_number(@item) == 0
      Sound.play_ok
      @itemlist.activate.refresh
      @cmn_window.close.deactivate
      close
    else
      close_window
    end
  end
  
  def close_window
    close
    @cmn_window.activate
    Sound.play_ok
  end
  
end
# =============================================================================
# ▼ Window_ItemList
# =============================================================================
class Window_ItemList < Window_Selectable
  attr_reader :item_size_window
  
  def item_size_window=(window)
    @item_size_window = window
    update_help
  end
  
  alias theo_liminv_update_help update_help
  def update_help
    theo_liminv_update_help
    @item_size_window.set_item(item) if @item_size_window
  end
  
  alias theo_liminv_height= height=
  def height=(height)
    self.theo_liminv_height = height
    refresh
  end
  
  def enable?(item)
    return !item.nil?
  end
  
end
# =============================================================================
# ▼ Window_ShopNumber
# =============================================================================
class Window_ShopNumber < Window_Selectable
  attr_accessor :mode
  
  alias theo_liminv_init initialize
  def initialize(x, y, height)
    theo_liminv_init(x, y, height)
    @mode = :buy
  end
  
  alias theo_liminv_refresh refresh
  def refresh
    theo_liminv_refresh
    draw_itemsize
  end
  
  def draw_itemsize
    item_size = @number * @item.inv_size
    total_size = $game_party.total_inv_size + 
      (@mode == :buy ? item_size : -item_size)
    txt = sprintf("%d/%d",total_size,$game_party.inv_max)
    ypos = item_y + line_height * ($imported["YEA-ShopOptions"] ? 5 : 4)
    rect = Rect.new(4,ypos,contents.width-8,line_height)
    change_color(system_color)
    draw_text(rect,Theo::LimInv::InvSlotVocab)
    change_color(normal_color)
    draw_text(rect,txt,2)
  end
  
end
# =============================================================================
# ▼ Window_ShopStatus
# =============================================================================
class Window_ShopStatus < Window_Base
  
  if Theo::LimInv::Display_ItemSize
  alias theo_liminv_draw_posses draw_possession
  def draw_possession(x, y)
    theo_liminv_draw_posses(x,y)
    y += line_height
    draw_item_size(@item,x,y,false, contents.width-(x*2))
  end
  
  if $imported["YEA-ShopOptions"]
  def draw_actor_equip_info(dx, dy, actor)
    dy += line_height
    enabled = actor.equippable?(@item)
    change_color(normal_color, enabled)
    draw_text(dx, dy, contents.width, line_height, actor.name)
    item1 = current_equipped_item(actor, @item.etype_id)
    draw_actor_param_change(dx, dy, actor, item1) if enabled
  end
  end # $imported["YEA-ShopOption"]
  end # Display item size

end
# =============================================================================
# Scene classes goes here
# =============================================================================
# =============================================================================
# ▼ Scene_Menu
# =============================================================================
class Scene_Menu < Scene_MenuBase
  
  alias theo_liminv_start start
  def start
    theo_liminv_start
    create_liminv_window
  end
  
  def create_liminv_window
    @lim_inv = Window_MenuLimInv.new(@gold_window.width)
    @lim_inv.x = @command_window.x
    @lim_inv.y = @command_window.height
  end
  
end
# =============================================================================
# ▼ Scene_Item
# =============================================================================
class Scene_Item < Scene_ItemBase
  
  alias theo_liminv_start start
  def start
    theo_liminv_start
    resize_item_window
    create_freeslot_window
    create_itemsize_window
    create_usecommand_window
    create_discard_amount
  end
  
  def resize_item_window
    @item_window.height -= @item_window.line_height * 2
  end
  
  def create_freeslot_window
    wy = @item_window.y + @item_window.height
    wh = Theo::LimInv::Display_ItemSize ? Graphics.width/2 : Graphics.width
    @freeslot = Window_FreeSlot.new(0,wy,wh)
    @freeslot.viewport = @viewport
  end
  
  def create_itemsize_window
    return unless Theo::LimInv::Display_ItemSize
    wx = @freeslot.width
    wy = @freeslot.y
    ww = wx
    @itemsize = Window_ItemSize.new(wx,wy,ww)
    @itemsize.viewport = @viewport
    @item_window.item_size_window = @itemsize
  end
  
  def create_usecommand_window
    @use_command = Window_ItemUseCommand.new
    @use_command.to_center
    @use_command.set_handler(:use, method(:use_command_ok))
    @use_command.set_handler(:discard, method(:on_discard_ok))
    @use_command.set_handler(:cancel, method(:on_usecmd_cancel))
    @use_command.viewport = @viewport
  end
  
  def create_discard_amount
    wx = @use_command.x
    wy = @use_command.y + @use_command.height
    ww = @use_command.width
    @discard_window = Window_DiscardAmount.new(wx,wy,ww)
    @discard_window.cmn_window = @use_command
    @discard_window.itemlist = @item_window
    @discard_window.freeslot = @freeslot
    @discard_window.viewport = @viewport
  end
  
  alias theo_liminv_item_ok on_item_ok
  def on_item_ok
    @use_command.set_item(item)
    @use_command.open
    @use_command.activate
    @use_command.select(0)
  end
  
  alias theo_liminv_use_item use_item
  def use_item
    @use_command.close
    theo_liminv_use_item
    @freeslot.refresh
  end
  
  def use_command_ok
    theo_liminv_item_ok
    @use_command.close
  end
  
  def on_discard_ok
    @discard_window.set_item(item)
    @discard_window.open
  end
  
  def on_usecmd_cancel
    @item_window.activate
    @use_command.close
    @use_command.deactivate
  end
  
end
# =============================================================================
# ▼ Scene_Shop
# =============================================================================
class Scene_Shop < Scene_MenuBase
  alias theo_liminv_buy_ok on_buy_ok
  def on_buy_ok
    @number_window.mode = :buy
    theo_liminv_buy_ok
  end
  
  alias theo_liminv_sell_ok on_sell_ok
  def on_sell_ok
    @number_window.mode = :sell
    theo_liminv_sell_ok
  end
end

# =============================================================================
# ▼ Compatibility patch thingy
# =============================================================================

if $imported["YEA-MenuCursor"]
class Sprite_MenuCursor
  def opacity_rate
    rate = 16
    return -rate if !@window.active || @window.close?
    return rate
  end
end
end

if $imported[:mog_menu_cursor]
module CURSOR_MENU_SPRITE
  def can_update_cursor_position?
    return false if !self.active     
    return false if self.index < 0 
    return false if !self.visible
    return false if self.close?
    return true
  end
end
end
