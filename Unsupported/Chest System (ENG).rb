# =============================================================================
# TheoAllen - Chest System
# Version : 1.2
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script is translated by AbsoluteIce)
# =============================================================================
($imported ||= {})[:Theo_ChestSystem] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2013.08.19 - Compatibility Patch with Limited Inventory
# 2013.06.28 - Add custom chest name
# 2013.06.01 - Adjust control and GUI
# 2013.05.24 - Finished script
# 2013.05.23 - Started Script
# =============================================================================
=begin

  Introduction :
  This script lets you open a chest. It lets you take out, or fill in items
  from your inventory. Similar to the western RPG game, Elder Scrolls.
 
  How to use :
  Put this below materials, and above main in the script section.
 
  Use a comment on the event in this format before you do a script call to
  initialize the chest starting items.
  <item: id, amount>
  <weapon: id, amount>
  <armor: id, amount>
 
  Explanation of Id's :
  id >> id of the item
  amount >> number of items
 
  After using the comment, use this script call :
  open_chest
 
  For custom name chest, you can use this script call. For example :
  open_chest("Garbage")
  open_chest("Eric's Chest")
 
  note : every comment in every event is read once. Make sure you put it before
  the script call.
 
  Terms of use :
  Credit me, TheoAllen. You're free to edit by your own as long as you don't
  claim it's yours. If you want to use for a commercial project, share the
  profit with me. And don't forget to give me free copy of the game

=end
# =============================================================================
# Configuration :
# =============================================================================
module THEO
  module CHEST
    # =========================================================================
    # Vocabs
    # -------------------------------------------------------------------------
      AMOUNT_VOCAB  = "Amount :"    # Vocab for said amount.
      ALL_VOCAB     = "All"         # Vocab for all categories.
      INV_VOCAB     = "Inventory"   # Vocab for inventory.
      ST_VOCAB      = "Stash"       # Vocab for stash/storage.
    # =========================================================================
   
    # =========================================================================
      TRIGGER_GAIN_ALL  = :CTRL
    # -------------------------------------------------------------------------
    # Trigger to take all items. If you write :CTRL, thus all items
    # will be taken if you press CTRL + Confirm (z)
    # =========================================================================
   
    # =========================================================================
      SHOW_AMOUNT_MIN   = 10
    # -------------------------------------------------------------------------
    # minimum amount for viewing the window amount.
    # =========================================================================
   
  end
end
# =============================================================================
# End of Configuration (Don't edit if you don't know what you're doing)
# =============================================================================
module THEO
  module CHEST
  module REGEXP
    
    ITEM_REGEX   = /<(?:ITEM|item):[ ]*[ ]*(\d+\s*,\s*\d*)>/i
    WEAPON_REGEX = /<(?:WEAPON|weapon):[ ]*[ ]*(\d+\s*,\s*\d*)>/i
    ARMOR_REGEX  = /<(?:ARMOR|armor):[ ]*[ ]*(\d+\s*,\s*\d*)>/i
    
  end
  end
end

class Scene_Chest < Scene_MenuBase
  
  include THEO::CHEST
  
  def initialize(key,st_vocab)
    $game_party.init_chest_cursors
    @last_active = :stash
    @key = key
    @st_vocab = st_vocab
  end
  
  def start
    super
    create_header_windows
    create_footer_window
    create_main_windows
    create_amount_window
    prepare
  end
  
  def create_header_windows
    create_help_window
    create_category_window
  end
  
  def create_main_windows
    create_inventory_window
    create_stash_window
  end
  
  def create_help_window
    @help = Window_Help.new
    @help.viewport = @viewport
  end
  
  def create_category_window
    @category = Window_ChestCategory.new
    @category.viewport = @viewport
    @category.y = @help.height
    @category.set_handler(:ok, method(:on_category_ok))
    @category.set_handler(:cancel, method(:return_scene))
  end
  
  def create_footer_window
    create_inv_footer
    create_st_footer
  end
  
  def create_inv_footer
    if $imported[:Theo_LimInventory]
      x = 0
      y = Graphics.height - 48
      w = Graphics.width/2
      @inv_footer = Window_ChestFreeSlot.new(x,y,w)
      @inv_footer.viewport = @viewport
    else
      @inv_footer = Window_ChestFooter.new(INV_VOCAB,$game_party,0)
      @inv_footer.viewport = @viewport
    end
  end
  
  def create_st_footer
    @st_footer = Window_ChestFooter.new(@st_vocab,$game_chests[@key],1)
    @st_footer.viewport = @viewport
  end
  
  def create_inventory_window
    x = 0
    y = @help.height + @category.height
    w = Graphics.width/2
    h = Graphics.height - y - @inv_footer.height
    @inventory = Window_Inventory.new(x,y,w,h)
    @inventory.viewport = @viewport
    @inventory.set_handler(:ok, method(:item_inventory_ok))
    @inventory.set_handler(:cancel, method(:on_inventory_cancel))
    @inventory.help_window = @help
    @category.item_window = @inventory
  end
  
  def create_stash_window
    x = Graphics.width / 2
    y = @inventory.y
    w = x
    h = @inventory.height
    @stash = Window_Stash.new(x,y,w,h,@key)
    @stash.viewport = @viewport
    @stash.set_handler(:ok, method(:item_stash_ok))
    @stash.set_handler(:cancel, method(:on_stash_cancel))
    @stash.help_window = @help
    @category.stash_window = @stash
  end
  
  def create_amount_window
    @amount = Window_ChestAmount.new
    @amount.viewport = @viewport
    @amount.inv_window = @inv_footer if $imported[:Theo_LimInventory]
  end
  
  # for future plan ~
  def refresh_all_footers
    @inv_footer.refresh
    @st_footer.refresh
  end
  
  def prepare
    unselect_all
    @category.show
    @category.activate
    @item_phase = false
    deactivate_item_windows
    hide_amount
  end
  
  def deactivate_item_windows
    @inventory.deactivate
    @stash.deactivate
  end
  
  def on_category_ok
    @category.deactivate
    activate_itemlist
    @item_phase = true
  end
  
  def item_inventory_ok
    unless @inventory.item
      @inventory.activate
      return
    end
    if @inventory.item_number < SHOW_AMOUNT_MIN
      store_items(1)
      @inventory.activate
      refresh_itemlist
    else
      @last_active = :inventory
      input_amount(@inventory)
    end
  end
  
  def item_stash_ok
    unless @stash.item
      @stash.activate
      return
    end
    if @stash.item_number < SHOW_AMOUNT_MIN
      gain_items(1)
      @stash.activate
      refresh_itemlist
    else
      @last_active = :stash
      input_amount(@stash)
    end
  end
  
  def on_stash_cancel
    @last_active = :stash
    memorize_st
    prepare
  end
  
  def on_inventory_cancel
    @last_active = :inventory
    memorize_inv
    prepare
  end
  
  def input_amount(window)
    memorize_all
    if window.equal?(@stash)
      @inventory.unselect
    else
      @stash.unselect
    end
    @amount.open
    @amount.item_window = window
    deactivate_item_windows
  end
  
  def hide_amount
    Sound.play_cancel
    @amount.close
    @amount.reset_amount
  end
  
  def update
    super
    @amount.mode = @last_active
    @inv_footer.mode = @last_active if $imported[:Theo_LimInventory]
    select_item_phase if @item_phase
    input_amount_phase if @amount.open?
  end
  
  def select_item_phase
    gain_all_items if trigger_gain_all_item?
    switch_window if Input.repeat?(:RIGHT) || Input.repeat?(:LEFT)
  end
  
  def input_amount_phase
    activate_itemlist if Input.trigger?(:B)
    if @amount.item_window.equal?(@stash) && Input.trigger?(:C)
      gain_items(@amount.amount)
    elsif @amount.item_window.equal?(@inventory) && Input.trigger?(:C)
      store_items(@amount.amount)
    end
  end
  
  def switch_window
    if @inventory.active
      switch_stash
    elsif @stash.active
      switch_inventory
    end
  end
  
  def switch_inventory
    memorize_st
    @stash.deactivate
    @stash.unselect
    @inventory.activate
    inv_select
  end
  
  def switch_stash
    @stash.activate
    st_select
    memorize_inv
    @inventory.deactivate
    @inventory.unselect
  end
  
  def gain_all_items
    if @stash.active
      @stash.data.each do |item|
        gain_items(@stash.item_number(item),item)
      end
      @stash.select(0)
    else
      @inventory.data.each do |item|
        store_items(@inventory.item_number(item),item)
      end
      @inventory.select(0)
    end
    refresh_itemlist
    refresh_all_footers
  end
  
  def trigger_gain_all_item?
    Input.press?(THEO::CHEST::TRIGGER_GAIN_ALL) && Input.trigger?(:C)
  end
  
  def gain_items(amount, item = @stash.item)
    if $imported[:Theo_LimInventory]
      amount = [[amount,0].max,$game_party.inv_max_item(item)].min
    end
    $game_party.gain_item(item,amount)
    $game_chests[@key].lose_item(item,amount)
    on_amount_confirm if @amount.open?
  end
  
  def store_items(amount, item = @inventory.item)
    $game_chests[@key].gain_item(item,amount)
    $game_party.lose_item(item,amount)
    on_amount_confirm if @amount.open?
  end
  
  def refresh_itemlist
    @stash.refresh    
    @inventory.refresh
  end
  
  def on_amount_confirm
    Sound.play_ok
    refresh_itemlist
    unselect_all
    activate_itemlist
  end
  
  def activate_itemlist
    hide_amount
    case @last_active
    when :stash
      activate_stash
    when :inventory
      activate_inventory
    end
    @item_phase = true
  end
  
  def activate_inventory
    @inventory.activate
    @stash.unselect
    inv_select
  end
  
  def activate_stash
    @stash.activate
    @inventory.unselect
    st_select
  end
  
  def memorize_inv
    $game_party.last_inv = @inventory.index
  end
  
  def memorize_st
    $game_party.last_st = @stash.index
  end
  
  def inv_select
    @inventory.index = [[$game_party.last_inv,@inventory.item_max-1].min,0].max
  end
  
  def st_select
    @stash.index = [[$game_party.last_st,@stash.item_max-1].min,0].max
  end
  
  def unselect_all
    @inventory.unselect
    @stash.unselect
  end
  
  def memorize_all
    memorize_inv
    memorize_st
  end
  
end

if $imported[:Theo_LimInventory]
class Window_ChestFreeSlot < Window_FreeSlot
  attr_accessor :item
  attr_accessor :mode
  
  def initialize(x,y,w)
    @add_number = 0
    @mode = :stash
    super(x,y,w)
  end
  
  def add_number=(number)
    temp = @add_number
    @add_number = number
    refresh if temp != number
  end
  
  def draw_inv_slot(x,y,width = contents.width,align = 2)
    item_size = @item.nil? ? 0 : @item.inv_size
    item_size = -item_size if @mode == :inventory
    txt = sprintf("%d/%d",$game_party.total_inv_size + @add_number * 
    item_size, $game_party.inv_max)
    color = Theo::LimInv::NearMaxed_Color
    near_max = ($game_party.total_inv_size + @add_number * item_size).to_f /
      $game_party.inv_max >= (100 - Theo::LimInv::NearMaxed_Percent)/100.0
    if near_max
      change_color(text_color(color))
    else
      change_color(normal_color)
    end
    draw_text(x,y,width,line_height,txt,align)
    change_color(normal_color)
  end
  
end
end

class Window_ChestCategory < Window_ItemCategory
  attr_reader :stash_window
  
  def col_max
    return 4
  end
  
  def update
    super
    @stash_window.category = current_symbol if @stash_window
  end
  
  def make_command_list
    add_command(THEO::CHEST::ALL_VOCAB, :all)
    add_command(Vocab::item,     :item)
    add_command(Vocab::weapon,   :weapon)
    add_command(Vocab::armor,    :armor)
  end
  
  def stash_window=(stash_window)
    @stash_window = stash_window
    update
  end
  
end

class Window_Inventory < Window_ItemList
  attr_reader :data
  
  def col_max
    return 1
  end
  
  def current_item_enabled?
    return true
  end
  
  def include?(item)
    case @category
    when :item
      item.is_a?(RPG::Item) && !item.key_item?
    when :weapon
      item.is_a?(RPG::Weapon)
    when :armor
      item.is_a?(RPG::Armor)
    when :all
      item.is_a?(RPG::Armor) || item.is_a?(RPG::Weapon) || item.is_a?(RPG::Item)
    else
      false
    end
  end
  
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, true,contents.width)
      draw_item_number(rect, item)
    end
  end
  
  def item_number(item = @data[index])
    $game_party.item_number(item)
  end
  
  def process_ok
    return if Input.press?(THEO::CHEST::TRIGGER_GAIN_ALL)
    super
  end
  
end

class Window_Stash < Window_ItemList
  attr_reader :data
  
  def initialize(x, y, width, height, key)
    @key = key
    super(x,y,width,height)
    @category = :none
    @data = []
  end
  
  def col_max
    return 1
  end
  
  def current_item_enabled?
    enable?(item)
  end
  
  def enable?(item)
    return true unless $imported[:Theo_LimInventory]
    return $game_party.inv_max_item(item) > 0
  end
  
  def include?(item)
    case @category
    when :item
      item.is_a?(RPG::Item) && !item.key_item?
    when :weapon
      item.is_a?(RPG::Weapon)
    when :armor
      item.is_a?(RPG::Armor)
    when :all
      item.is_a?(RPG::Armor) || item.is_a?(RPG::Weapon) || item.is_a?(RPG::Item)
    else
      false
    end
  end
  
  def make_item_list
    @data = $game_chests[@key].all_items.select {|item| include?(item) }
    @data.push(nil) if include?(nil)
  end
  
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item),contents.width)
      draw_item_number(rect, item)
    end
  end
  
  def draw_item_number(rect, item)
    draw_text(rect, sprintf(":%2d", $game_chests[@key].item_number(item)), 2)
  end
  
  def item_number(item = @data[index])
    $game_chests[@key].item_number(item)
  end
  
  def process_ok
    return if Input.press?(THEO::CHEST::TRIGGER_GAIN_ALL)
    super
  end
  
end

class Window_ChestAmount < Window_Base  
  attr_accessor :item_window
  attr_accessor :mode
  attr_reader   :amount
  
  def initialize
    super(0,0,window_width,window_height)
    self.openness = 0
    @mode = :stash
    reset_amount
    update_position
    refresh
  end
  
  def inv_window=(window)
    @inv_window = window
  end
  
  def reset_amount
    @amount = 0
    refresh
  end
  
  def open
    super
    reset_amount
  end
  
  def update_position
    self.x = (Graphics.width / 2) - (self.width / 2)
    self.y = (Graphics.height / 2) - (self.height / 2)
  end
  
  def refresh
    contents.clear
    draw_text(0,0,contents.width,24,THEO::CHEST::AMOUNT_VOCAB,)
    draw_text(0,0,contents.width,24,@amount,2)
  end
  
  def window_width
    return 200
  end
  
  def window_height
    return 24+24
  end
  
  def update
    super
    if @inv_window
      @inv_window.add_number = @amount
      @inv_window.item = @item_window.item if @item_window
    end
    if open?
      increment if Input.repeat?(:RIGHT)
      decrement if Input.repeat?(:LEFT)
      ten_increment if Input.repeat?(:UP)
      ten_decrement if Input.repeat?(:DOWN)
    end
  end
  
  def increment
    change_amount(1)
  end
  
  def decrement
    change_amount(-1)
  end
  
  def ten_increment
    change_amount(10)
  end
  
  def ten_decrement
    change_amount(-10)
  end
  
  def change_amount(modifier)
    @amount = [[@amount+modifier,0].max,max_amount].min
    refresh
  end
  
  def show
    super
    reset_amount
  end
  
  def max_amount
    if $imported[:Theo_LimInventory]
      if @mode == :inventory
        @item_window.item_number rescue 0
      elsif @mode == :stash
        [@item_window.item_number,$game_party.inv_max_item(@item_window.item)].min
      end
    else
      @item_window.item_number rescue 0
    end
  end
  
end

class Window_ChestFooter < Window_Base
  
  include THEO::CHEST
  
  def initialize(vocab,object,x)
    w = Graphics.width/2
    h = fitting_height(1)
    y = Graphics.height - h
    x = (Graphics.width/2) * x
    @vocab = vocab
    super(x,y,w,h)
    @object = object
    refresh
  end
  
  def refresh
    contents.clear
    cx = text_size(@vocab).width
    draw_text(0,0,contents.width,line_height,@vocab,1)
  end
  
end

module DataManager
  
  class << self
    alias pre_create_chest create_game_objects
    alias pre_chest_save_contents make_save_contents
    alias pre_extract_chests extract_save_contents
  end
  
  def self.create_game_objects
    pre_create_chest
    create_chest_object
  end
  
  def self.create_chest_object
    $game_chests = Game_Chest.new
  end
  
  def self.make_save_contents
    contents = pre_chest_save_contents
    contents[:chest] = $game_chests
    contents
  end
  
  def extract_save_contents(contents)
    pre_extract_chests(contents)
    $game_chests = contents[:chest]
  end
  
end

class Game_Chest
  
  def initialize
    @data = {}
    @explored = {}
  end
  
  def[](key)
    (@data[key] ||= Game_Stash.new)
  end
  
  def explored
    @explored
  end
  
end

class Game_Stash
  attr_accessor :items_stash
  attr_accessor :weapons_stash
  attr_accessor :armors_stash
  
  def initialize
    @items_stash = {}
    @weapons_stash = {}
    @armors_stash = {}
  end
  
  def refresh
    evaluate(@items_stash)
    evaluate(@weapons_stash)
    evaluate(@armors_stash)
  end
  
  def evaluate(stash)
    stash.keys.each do |key|
      stash.delete(key) if stash[key] <= 0
    end
  end
  
  def items
    @items_stash.keys.collect {|id| $data_items[id] }
  end
  
  def weapons
    @weapons_stash.keys.collect {|id| $data_weapons[id] }
  end
  
  def armors
    @armors_stash.keys.collect {|id| $data_armors[id] }
  end
  
  def all_items
    items + weapons + armors
  end
  
  def item_number(item)
    if item.is_a?(RPG::Item)
      return @items_stash[item.id] ||= 0
    elsif item.is_a?(RPG::Weapon)
      return @weapons_stash[item.id] ||= 0
    elsif item.is_a?(RPG::Armor)
      return @armors_stash[item.id] ||= 0
    end
    refresh
  end
  
  def gain_item(item, amount)
    return unless item
    stash = pick_stash(item)
    stash[item.id] = 0 if stash[item.id].nil?
    stash[item.id] += amount
    refresh
  end
  
  def lose_item(item,amount)
    gain_item(item,-amount)
  end
  
  def pick_stash(item)
    if item.is_a?(RPG::Item)
      return @items_stash
    elsif item.is_a?(RPG::Weapon)
      return @weapons_stash
    elsif item.is_a?(RPG::Armor)
      return @armors_stash
    end
  end
  
end

class Game_Party
  attr_accessor :last_inv
  attr_accessor :last_st
  
  alias pre_chest_init initialize
  def initialize
    pre_chest_init
    init_chest_cursors
  end
  
  def init_chest_cursors
    @last_inv   = 0
    @last_st = 0
  end
  
end

class Game_Interpreter
  
  def open_chest(st_vocab = THEO::CHEST::ST_VOCAB,key = [@map_id,@event_id])
    if st_vocab.is_a?(Numeric)
      key = st_vocab 
      st_vocab = THEO::CHEST::ST_VOCAB
    end
    SceneManager.call_chest(key,st_vocab)
  end
  
  alias pre_chest_command_108 command_108
  def command_108
    pre_chest_command_108
    read_chest_comments
  end
  
  def read_chest_comments
    map = @map_id
    event = @event_id
    key = [map,event]
    return if $game_chests.explored[key]
    @comments.each do |comment|
      case comment
      when THEO::CHEST::REGEXP::ITEM_REGEX
        x = $1.scan(/\d+/)
        $game_chests[key].items_stash[x[0].to_i] = x[1].to_i
      when THEO::CHEST::REGEXP::WEAPON_REGEX
        x = $1.scan(/\d+/)
        $game_chests[key].weapons_stash[x[0].to_i] = x[1].to_i
      when THEO::CHEST::REGEXP::ARMOR_REGEX
        x = $1.scan(/\d+/)
        $game_chests[key].armors_stash[x[0].to_i] = x[1].to_i
      end
    end
    $game_chests.explored[key] = next_event_code != 108
  end
  
end

module SceneManager
  
  def self.call_chest(key,st_vocab = THEO::CHEST::ST_VOCAB)
    @stack.push(@scene)
    @scene = Scene_Chest.new(key,st_vocab)
  end
  
end
