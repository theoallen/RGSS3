#===============================================================================
# All Category Sell Window
#-------------------------------------------------------------------------------
# > Remove the category window from scene shop
#
# Terms of Service:
# > Free for commercial
# > Credit isn't necessary (if you totally want to, put TheoAllen anywhere on
#   your credit list)
#===============================================================================

class Scene_Shop
  
  # Overwrite
  def command_sell
    @dummy_window.hide
    activate_sell_window
    @sell_window.select(0)
  end
  
  # Overwrite
   def activate_sell_window
    @sell_window.refresh
    @sell_window.show.activate
    @status_window.hide
  end
  
  # Overwrite
  def on_sell_cancel
    @sell_window.unselect
    @status_window.item = nil
    @help_window.clear
    on_category_cancel
  end
  
  # Overwrite
  def create_sell_window
    wy = @category_window.y
    wh = Graphics.height - wy
    @sell_window = Window_ShopSell.new(0, wy, Graphics.width, wh)
    @sell_window.viewport = @viewport
    @sell_window.help_window = @help_window
    @sell_window.hide
    @sell_window.set_handler(:ok,     method(:on_sell_ok))
    @sell_window.set_handler(:cancel, method(:on_sell_cancel))
  end
  
end

class Window_ShopSell
  # Overwrite
  def make_item_list
    @data = $game_party.all_items
    @data.push(nil) if include?(nil)
  end
end
