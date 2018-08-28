# =============================================================================
# TheoAllen - Database Manager
# Version : 1.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_DBManager] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.11.11 - Finished Script
# =============================================================================
=begin
  ----------------------------------------------------------------------------
  Perkenalan :
  Merasa kurang bebas ngedit database dari editor yang hanya disedian copy,
  paste, clear, dan multicopy?
  
  Sekarang, dengan script ini, kamu bisa menukar ID dari sebuah database,
  atau bahkan menyisipkan database kosong dan menghapus database untuk alasan 
  kerapian. Coba aja
  
  ----------------------------------------------------------------------------
  Cara penggunaan :
  Pasang script ini dibawah material namun diatas main
  Set Activate ke true jika kamu ingin mengaktifasi script ini. Lalu playtest.
  
  Setelah kamu selesai mengedit database dari game, tutup gamenya beserta
  editornya. Lalu buka kembali editor RMVXA kamu. Dan lihat database yang
  barusan kamu ubah
  
  ----------------------------------------------------------------------------
  Terms of use :
  Script ini diperuntukkan cuman buat alat bantu ngedit database. Kalo kamu
  bisa dan berani mengedit script ini, wa bolehin. Kalo kamu share script
  versi editan dari ini, jangan lupa, tetep kredit gw, TheoAllen

=end
# =============================================================================
Font.default_name = ["Calibri"]       # <-- Default font
class Window_DB < Window_Selectable   # <-- Yang ini jangan diubah-ubah
# =============================================================================
  # --------------------------------------------------------------------------
  # Activation flag. Set ke true jika kamu mau gunain script ini
  # --------------------------------------------------------------------------
    Activate = true
  # --------------------------------------------------------------------------
  # Database Object. Tulis antara pilihan berikut :
  # --------------------------------------------------------------------------
  # $data_actors          >> Untuk database Actor  
  # $data_classes         >> Untuk database Class
  # $data_skills          >> Untuk database Skill
  # $data_items           >> Untuk database Item
  # $data_weapons         >> Untuk database Weapon
  # $data_armors          >> Untuk database Armor
  # $data_enemies         >> Untuk database Enemy
  # $data_troops          >> Untuk database Troop
  # $data_states          >> Untuk database State
  # $data_animations      >> Untuk database Animasi
  # $data_tilesets        >> Untuk database Tileset
  # $data_common_events   >> Untuk database common event
  # 
  # Letakkan antara "def" dan "end"
  # --------------------------------------------------------------------------
  def database
    $data_skills  # <-- disini
  end
# =============================================================================
# Akhir dari konfigurasi. Setelah ini jangan sentuh apapun, atawa database
# game lu bakal rusak :v
# =============================================================================
  attr_reader :pending_index
  def initialize(*args)
    super(*args)
    @load_index = 0
    reset_pending_index
    init_handlers
    refresh
    activate
    select(0)
  end
  
  def window_progress=(window)
    @progress = window
  end
  
  def reset_pending_index
    @pending_index = -1
  end
  
  def init_handlers
    set_handler(:ok, method(:on_okay))
    set_handler(:cancel, method(:on_cancel))
  end
  
  def on_okay
    if pending?
      change_id
      clear_pending
    elsif index == pending_index
      clear_pending
    else
      @pending_index = index
      draw_pending(@pending_index)
    end
    activate
  end
  
  def on_cancel
    if pending?
      clear_pending
    else
      SceneManager.exit
    end
    activate
  end
  
  def pending?
    @pending_index > -1
  end
  
  def item
    @data[index]
  end
  
  def pending_item
    @data[@pending_index]
  end
  
  def change_id
    id1 = item.id
    id2 = pending_item.id
    temp_item = item
    database[id1] = pending_item 
    database[id2] = temp_item
    database[id1].id = id1
    database[id2].id = id2
    make_item_list
    redraw_item(id1)
    redraw_item(index)
  end
  
  def draw_pending(index)
    clear_item(index) if index >= 0
    contents.fill_rect(item_rect(index), Color.new(255,255,255,128))
    draw_item(index)  if index >= 0
  end
  
  def clear_pending
    index = @pending_index
    redraw_item(index)
    reset_pending_index
  end
  
  def item_max
    unless @data
      make_item_list
    end
    @data.size
  end
  
  def make_item_list
    @data = database.compact
  end
  
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, true)
    end
  end
  
  def draw_item_name(item, x, y, enabled = true, width = contents.width)
    return unless item
    if item.respond_to?("icon_index") && !item.icon_index.nil?
      draw_icon(item.icon_index, x, y, enabled)
    else
      draw_icon(0, x, y, enabled)
    end
    change_color(normal_color, enabled)
    contents.font.size = line_height
    draw_text(x+24, y, width, line_height, sprintf("%03d:%s",item.id,item.name))
  end
  
  def update_help
    @help_window.set_item(item)
  end
  
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  
  def draw_all_items
    @load_index = 0
    @fiber = Fiber.new { fiber_load }
  end
  
  def insert_new_db(index)
    Sound.play_ok
    index += 1
    database.insert(index, db_class.new)
    database[index].id = database.index(database[index])
    refresh_id(index+1)
    refresh_at(index-1)
  end
  
  def delete_db(index)
    Sound.play_cancel
    index += 1
    database.delete_at(index)
    refresh_id(index)
    refresh_at(index-1)
  end
  
  def refresh_at(index)
    make_item_list
    @load_index = index
    @fiber = Fiber.new { fiber_load }
  end
  
  def refresh_id(start_id)
    for id in (start_id)..database.size-1
      database[id].id = id
    end
  end
  
  def save_database
    save_data(database, db_name[db_class])
  end
  
  def db_name
    hash = {
      RPG::Actor => "Data/Actors.rvdata2",
      RPG::Class => "Data/Classes.rvdata2",
      RPG::Skill => "Data/Skills.rvdata2",
      RPG::Item => "Data/Items.rvdata2",
      RPG::Weapon => "Data/Weapons.rvdata2",
      RPG::Armor => "Data/Armors.rvdata2",
      RPG::Enemy => "Data/Enemies.rvdata2",
      RPG::Troop => "Data/Troops.rvdata2",
      RPG::State => "Data/States.rvdata2",
      RPG::Animation => "Data/Animations.rvdata2",
      RPG::Tileset => "Data/Tilesets.rvdata2",
      RPG::CommonEvent => "Data/CommonEvents.rvdata2",
    }
    return hash
  end
  
  def db_class
    database[1].class
  end
  
  def process_handling
    super
    return unless open? && active
    return insert_new_db(index) if Input.trigger?(:SHIFT)
    return delete_db(index) if Input.trigger?(:CTRL)
    if Input.trigger?(:ALT)
      Sound.play_load
      return refresh 
    end
  end
  
  def update
    super
    if @fiber
      @fiber.resume
    end
  end
  
  def fiber_load
    refresh_count = 5
    for index in @load_index..item_max
      redraw_item(index)
      refresh_count -= 1
      # --------------------------------------------
      # To avoid lag
      # --------------------------------------------
      if @progress && refresh_count == 0
        @progress.set(index+1, item_max-1) 
        refresh_count = 5
      end
      Fiber.yield
    end
    @progress.set(1,1) 
    Graphics.frame_reset
    @fiber = nil
  end
  
end

class Manual < Window_Base
  
  def initialize(*args)
    super(*args)
    @line = 0
    refresh
  end
  
  def text(command,text)
    change_color(system_color)
    draw_text(0,@line,contents.width,line_height,command)
    change_color(normal_color)
    xpos = text_size(command).width
    draw_text(xpos,@line,contents.width,line_height,text)
  end
  
  def just_text(text,align = 1)
    draw_text(0,@line,contents.width,line_height,text,align)
  end
  
  def refresh
    @line = 0
    contents.clear
    contents.font.size = line_height
    just_text "------------------------------------------"
    line_plus
    just_text "Movement Controls"
    line_plus
    just_text "------------------------------------------"
    line_plus
    text "Up              :"," Scroll up"
    line_plus
    text "Down         :"," Scroll down"
    line_plus
    text "PageUP      :"," Prev page"
    line_plus
    text "PageDown :"," Next Page"
    line_plus
    just_text "------------------------------------------"
    line_plus
    just_text "Editor Controls"
    line_plus
    just_text "------------------------------------------"
    line_plus
    text "Z       :"," Swap database"
    line_plus
    text "X       :"," Cancel / Exit"
    line_plus
    text "Shift  :"," Insert empty database"
    line_plus
    text "CTRL :"," Delete database"
    line_plus
    text "ALT   :"," Refresh database list"
    line_plus
    text "S      :"," Save Database"
  end
  
  def line_plus
    @line += line_height
  end
  
end

class Window_DBLoading < Window_Base
  
  def initialize(*args)
    super(*args)
  end
  
  def set(current, max)
    contents.clear
    rate = ((current/max.to_f) * 100).to_i
    rect = contents.rect
    txt = sprintf("%d%",rate)
    txt2 = (rate < 100 ? "Loading . . ." : "Done")
    draw_text(rect, txt, 2)
    draw_text(rect, txt2)
  end
  
end

class DBHelp < Window_Help
  
  def set_item(item)
    if item.respond_to?("description")
      super(item)
    end
    contents.font.size = 20
    text = "#{item.class}"
    h = text_size(text).height
    rect = Rect.new(0,contents.height-h,contents.width-6,h)
    draw_text(rect,text,2)
  end
  
end

class DBManager < Scene_Base
  
  def start
    super
    Graphics.resize_screen(680,480)
    create_help
    create_list
    create_manual
    create_loading_progress
    create_popup
  end
  
  def create_help
    @help = DBHelp.new
  end
  
  def create_list
    wy = @help.height
    ww = Graphics.width / 2
    wh = Graphics.height - wy - 48
    @list = Window_DB.new(0,wy,ww,wh)
    @list.help_window = @help
  end
  
  def create_popup
    @popup = Window_Base.new(0,0,200,48)
    @popup.x = (Graphics.width - @popup.width)/2
    @popup.y = (Graphics.height - @popup.height)/2
    @popup.draw_text(@popup.contents.rect, "Database Saved!",1)
    @popup.openness = 0
  end
  
  def create_manual
    wx = @list.width
    wy = @list.y
    ww = @list.width
    wh = @list.height + 48
    @manual = Manual.new(wx,wy,ww,wh)
  end
  
  def create_loading_progress
    wx = 0
    wy = @list.height + @help.height
    ww = @list.width
    wh = 48
    @loading = Window_DBLoading.new(wx,wy,ww,wh)
    @list.window_progress = @loading
  end
  
  def update
    super
    if Input.trigger?(:Y)
      Sound.play_save
      @list.deactivate
      @list.save_database
      @popup.open
      wait(180)
      @popup.close
      @list.activate
    end
  end
  
  def return_scene
    SceneManager.exit
  end
  
  def wait(duration)
    duration.times do
      update_basic
      if Input.trigger?(:C)
        Sound.play_ok
        return
      end
    end
  end
  
end

class << SceneManager
  
  alias theo_dbmanager_first_scene first_scene_class
  def first_scene_class
    Window_DB::Activate ? DBManager : theo_dbmanager_first_scene
  end
  
end
