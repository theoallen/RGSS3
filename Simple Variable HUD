# =============================================================================
# TheoAllen - Simple Variable HUD
# Version : 1.2b
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_VariableHUD] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2014.03.13 - Fixed hidden glitch when access menu then back to map
# 2014.02.07 - Make sure that variable HUD is always visible
# 2013.08.09 - Add mutiple variable HUD support
# 2013.07.23 - Finished script
# =============================================================================
=begin

  Perkenalan :
  Script ini berguna untuk menampilkan nilai dari sebuah variable
  
  Cara penggunaan :
  Pasang dibawah material namun diatas main
  
  Gunakan script call
  show_variable(id) >> nampilin nilai variable
  show_variable(id,icon_id) >> variable + gambar icon
  show_variable(id,icon_id,pos) >> variable + icon + posisi
  
  Untuk mutiple HUD, gunakan script call
  show_variable([id,id,id],[icon,icon,icon],pos)
  
  hide_variable >> untuk sembunyiin variable HUD
  
  Terms of Use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.
  
  Note :
  Karena ini simple, jadi jangan harap ada banyak kustomisasi bebas

=end
# =============================================================================
# Sedikit Konfigurasi
# =============================================================================
  VarHUD_DefaultPos = 1 # Posisi default HUD
# -----------------------------------------------------------------------------
# 1 >> Kiri Atas
# 2 >> Kanan Atas
# 3 >> Kiri Bawah
# 4 >> Kanan Bawah
# -----------------------------------------------------------------------------
  VarHUD_FontSize = 24 # Ukuran Font
# -----------------------------------------------------------------------------
  VarHUD_MaxVar = 3 # Maksimal variable yg dapat ditampilin
# =============================================================================
# Akhir dari konfig
# =============================================================================
class Game_Temp
  attr_accessor :refresh_hud
  
  alias theo_varhud_init initialize
  def initialize
    theo_varhud_init
    @refresh_hud = false
  end
  
end

class Game_Variables
  alias theo_varhud_on_change on_change
  def on_change
    theo_varhud_on_change
    $game_temp.refresh_hud = true
  end
end

class Game_System
  class VarHUD
    attr_accessor :position
    attr_accessor :icon
    attr_accessor :id
    
    def initialize
      @position = 0
      @icon = 0
      @id = 0
    end
  end
  attr_accessor :varhud_visible
  attr_accessor :varhud_position
  attr_reader :varhud
  
  alias theo_varhud_init initialize
  def initialize
    theo_varhud_init
    @varhud = Array.new(VarHUD_MaxVar) { VarHUD.new }
  end
  
  def clear_varhud
    @varhud.each do |hud|
      hud.id = 0
    end
  end
  
end

class Game_Interpreter
  
  def show_variable(id = nil,icon = 0,position = VarHUD_DefaultPos)
    $game_system.clear_varhud
    if id.is_a?(Array)
      icon = [icon] unless icon.is_a?(Array)
      id.each_with_index do |i,index|
        return if index-1 > VarHUD_MaxVar
        hud = $game_system.varhud[index]
        hud.id = i
        hud.icon = icon[index]
      end
    elsif id.is_a?(Numeric)
      hud = $game_system.varhud[0]
      hud.icon = icon
      hud.id = id
    end
    $game_system.varhud_position = position
    $game_system.varhud_visible = true
    $game_temp.refresh_hud = true
  end
  
  def hide_variable
    $game_system.varhud_visible = false
  end
  
end

class Window_VarHUD < Window_Base
  
  def initialize
    super(0,0,window_width,window_height)
    contents.font.size = VarHUD_FontSize
    update_hud_position
    update_visibility
    self.opacity = 0
    refresh
  end
  
  def window_width;Graphics.width;end;
  def window_height;fitting_height(VarHUD_MaxVar);end;
  def line_height;VarHUD_FontSize;end;
    
  def update
    super
    update_visibility
    refresh if $game_temp.refresh_hud
  end
  
  def update_visibility
    self.visible = $game_system.varhud_visible
  end
  
  def refresh
    contents.clear
    active_hud.each_with_index do |hud,i|
      update_hud_contents(hud,i)
    end
    update_hud_position
    $game_temp.refresh_hud = false
  end
  
  def update_hud_position
    pos = $game_system.varhud_position
    if pos == 1 || pos == 2
      self.y = 0
    elsif
      self.y = Graphics.height - self.height
      size = active_hud.size - 1
      return if size < 0
      self.y += size * line_height
    end
  end
  
  def update_hud_contents(hud,i)
    var_id = hud.id
    icon = hud.icon.nil? ? 0 : hud.icon
    return if var_id == 0
    rect = Rect.new(0,0,contents.width,line_height)
    rect.y = i * line_height
    case $game_system.varhud_position
    when 1,3
      if icon != 0
        rect.x += 27
        draw_icon(icon,0,icon_y_pos + (i * line_height))
      end
      draw_text(rect,$game_variables[var_id])
    else
      if icon != 0
        rect.x -= 27 
        draw_icon(icon,contents.width-24,icon_y_pos + (i * line_height))
      end
      draw_text(rect,$game_variables[var_id],2)
    end
  end
  
  def icon_y_pos
    return 0 if line_height <= 24
    return line_height/2 - 12
  end
  
  def active_hud
    $game_system.varhud.select {|hud| hud.id > 0}
  end
  
end

class Scene_Map < Scene_Base
  
  alias theo_varhud_start start
  def start
    theo_varhud_start
    create_var_hud
  end
  
  def create_var_hud
    @varhud_viewport = Viewport.new
    @varhud_viewport.z = 9999
    @var_hud = Window_VarHUD.new
#~     @var_hud.z -= 100
    @var_hud.viewport = @vahud_viewport
  end
  
  alias theo_varhud_terminate terminate
  def terminate
    theo_varhud_terminate
    @varhud_viewport.dispose
  end
  
end
