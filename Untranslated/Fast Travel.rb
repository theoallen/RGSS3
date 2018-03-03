# ============================================================================
# TheoAllen - Fast Travel
# Version : 1.2
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# =-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Requested by : Rusty
# Requires : Theo - Basic Modules
# > Core Movement
# > Core Fade
# ============================================================================
$imported = {} if $imported.nil?
if $imported[:Theo_Movement] && $imported[:Theo_CoreFade]
$imported[:Theo_Travel] = true
# ============================================================================
# Change Logs:
# ----------------------------------------------------------------------------
# 2014.09.22 - Optimize code. Properly dispose sprite and windows.
#            - Added custom background for each travel list
# 2013.05.07 - Add custom picture in maplists
# 2013.05.01 - Started and finished script
# ============================================================================
=begin

  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  PENGENALAN:
  Script ini ngebikin kamu bisa bikin fast travel sendiri. Map-map yg bisa
  dipake buat transfer dicatet dalam konfigurasi
  
  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  CARA PEMAKAIAN:
  Pasang script ini dibawah Theo - Core Movement.
  Panggil dalam script call seperti ini:
  -------------------------------------
  map = [1,2,3]
  travel(map) (atau-->) travel([1,2,3])
  -------------------------------------
  
  Angka2 itu adalah id map yg bisa ditransfer yg u database sendiri di
  kofigurasi ntar. Kalo semisal u pengen kasi gambar background, u bisa bikin
  kek gini:

  -------------------------------------
  travel([1,2,3],"peta")
  -------------------------------------
  "peta" adalah nama file gambar yg harus ada di folder Graphics/system

  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  TERMS OF USE :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.
  
=end
# ============================================================================
# KONFIGURASI ~
# ============================================================================
module Theo
  module Travel
  # =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  # MAP DATABASE :
  # -----------------------------------------------------------------------
  # id => ["nama", map_id, x, y, (gambar)],
  # id ntar buat dipanggil di script call
  # =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    MapList = {
       1 => ["Alumnea",      1, 1, 1, "Book"], 
       2 => ["Eremidia",     2, 1, 1, "Castle"],
       3 => ["Westerland",   3, 1, 1],
       4 => ["Aldonia",      1, 1, 1],
       5 => ["Vandaria",     2, 1, 1],
       6 => ["Nirbhumi",     3, 1, 1],
       
       # Tambahin sendiri disini
       # Perhatikan KOMA!
       
    } # <-- jangan diilangin!
    
  # =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  # Settingan Window (kalo dirasa g perlu g usah diedit)
  # =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    Window_Image    = "test2"
  # picture pengganti window. tulis "nil" (tanpa petik) kalo g perlu
  # ---------------------------------------------------------
    Text_Xpos = 0       # pergeseran text ke kanan (kalo pake pic)
    Text_Ypos = 0       # pergeseran text ke bawah (kalo pake pic)
  # ---------------------------------------------------------
    Window_Width  = 200
  # ---------------------------------------------------------
  # Lebar window untuk nampilin nama petanya (kalo g pake pic)
  # ---------------------------------------------------------
    Window_Offset = 4       
  # ---------------------------------------------------------
  # Jarak antar window
  # ---------------------------------------------------------
    Move_Duration = 5 
  # ---------------------------------------------------------
  # Kecepatan window ngegeser dalam satuan frame
  # Misalnya kalo u nulis 60 maka window butuh waktu 1 detik
  # buat sampe tujuan
  # default : 5
  # ---------------------------------------------------------
    Position_X = 4
    Position_Y = 4
  # ---------------------------------------------------------
  # Untuk ngatur posisi x ama y window
  # ---------------------------------------------------------
    FontSize = 24
  # ---------------------------------------------------------
  # Untuk ukuran font yg ditampilin di maplist ntar
  # Default : 24
  # ---------------------------------------------------------
    Text_Align = 1
  # ---------------------------------------------------------
  # Untuk ngatur letak text
  # 0 = ditulis dari kiri
  # 1 = ditulis di tengah
  # 2 = ditulis dari kanan
  # ---------------------------------------------------------
  end
end
# ============================================================================
# Do not edit pass this line ~
# ============================================================================
class Window_TravelList < Window_Base
  attr_accessor :id
  
  def initialize(x,y,text)
    super(x,y,window_width,window_height)
    contents.font.size = Theo::Travel::FontSize
    @text = text
    refresh
  end
  
  def refresh
    contents.clear
    rect = Rect.new(0,0,contents.width,Theo::Travel::FontSize)
    draw_text(rect,@text,Theo::Travel::Text_Align)
  end
  
  def window_width
    Theo::Travel::Window_Width
  end
  
  def window_height
    24 + Theo::Travel::FontSize
  end
  
end

class Sprite_Maplist < Sprite
  attr_accessor :id
end

class Scene_Traveling < Scene_MenuBase
  
  def initialize(maplists_id, snapshot = nil)
    @maps = []
    maplists_id.each do |key|
      @maps.push(Theo::Travel::MapList[key])
    end
    @snapshot = snapshot
    @index = 0
  end
  
  def start
    super
    create_maplist_window
    update_windows
  end
  
  def create_background
    if @snapshot
      @background_sprite = Sprite.new
      @background_sprite.bitmap = Cache.system(@snapshot)
    else
      super
    end
  end
  
  def create_maplist_window
    y_pos = Theo::Travel::Position_Y
    x_pos = Theo::Travel::Position_X
    @window_maplists = []
    @sprite_backdrops = []
    @maps.each_with_index do |map, i|
      unless Theo::Travel::Window_Image.is_a?(String)
        make_window_maplists(x_pos,y_pos,i)
        y_pos += Theo::Travel::FontSize + 24 + Theo::Travel::Window_Offset
      else
        window_sprite = Sprite_Maplist.new(@viewport)
        window_sprite.y = y_pos
        window_sprite.x = x_pos
        window_sprite.bitmap = create_window_sprite_bitmap(i)
        y_pos += window_sprite.bitmap.height + Theo::Travel::Window_Offset
        make_sprite_maplist(window_sprite,i)
      end
      spr = Sprite.new
      spr.bitmap = Cache.system(map[4]) if map[4]
      @sprite_backdrops[i] = spr
    end
    @sprite_backdrops.each_with_index do |spr, i|
      if i == @index
        spr.opacity = 255
      else
        spr.opacity = 0
      end
    end
  end
  
  def make_window_maplists(x,y,i)
    @window_maplists.push(Window_TravelList.new(x,y,@maps[i][0]))
    @window_maplists[i].id = i
  end
  
  def create_window_sprite_bitmap(i)
    bitmap = Cache.system(Theo::Travel::Window_Image).clone
    x = Theo::Travel::Text_Xpos
    y = Theo::Travel::Text_Ypos
    width = bitmap.width - x
    bitmap.draw_text(x, y, width, Theo::Travel::FontSize, @maps[i][0],
      Theo::Travel::Text_Align)
    return bitmap
  end
  
  def make_sprite_maplist(window_sprite,i)
    @window_maplists.push(window_sprite)
    @window_maplists[i].id = i
  end
  
  def update
    super
    update_cursor
    @window_maplists.each {|window| window.update}
    @sprite_backdrops.each {|spr| spr.update}
    transfer_player if confirm?
    return_scene if return?
  end
  
  def update_cursor
    if Input.repeat?(:DOWN)
      @index += 1
      correct_index
      update_windows
    elsif Input.repeat?(:UP)
      @index -= 1
      correct_index
      update_windows
    end
  end
  
  def correct_index
    @index = max_index if @index < 0
    @index = 0 if @index > max_index
  end
  
  def max_index
    @maps.size - 1
  end
  
  def update_windows
    @window_maplists.each do |window|
      if window.id == @index
        window.goto(Theo::Travel::Position_X+20, window.y,
          Theo::Travel::Move_Duration)
      else
        window.goto(Theo::Travel::Position_X, window.y,
          Theo::Travel::Move_Duration)
      end
    end
    @sprite_backdrops.each_with_index do |spr, i|
      if i == @index
        spr.fadein(Theo::Travel::Move_Duration)
      else
        spr.fadeout(Theo::Travel::Move_Duration)
      end
    end
  end
  
  def transfer_player
    map = @maps[@index]
    id = map[1]
    x = map[2]
    y = map[3]
    $game_player.reserve_transfer(id,x,y)
    return_scene
  end
  
  def confirm?
    Input.trigger?(:C)
  end
  
  def return_scene
    SceneManager.return
  end
  
  def return?
    Input.trigger?(:B)
  end
  
  def terminate
    super
    (@window_maplists + @sprite_backdrops).each do |grap_obj|
      grap_obj.dispose
    end
  end
  
end

class Game_Interpreter
  
  def travel(maplist,snapshot = nil)
    SceneManager.call_travel(maplist,snapshot)
  end
  
end

module SceneManager
  
  def self.call_travel(maplist,snapshot = nil)
    @stack.push(@scene)
    @scene = Scene_Traveling.new(maplist,snapshot)
  end
  
end

end
