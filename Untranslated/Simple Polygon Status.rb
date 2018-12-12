# =============================================================================
# TheoAllen - Simple Polgygon Status
# Version : 1.0
# Contact : -
# (This script documentation is written in informal indonesian language)
# -----------------------------------------------------------------------------
# Requires :
# >> Theo - Bitmap Extra addons v2.0 or later
# =============================================================================
($imported ||= {})[:Theo_PolygonStatus] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2013.06.06 - Finised script
# =============================================================================
=begin

  Perkenalan :
  Script ini ngebikin kamu nampilin parameter bentuknya poligon di status menu
  
  Cara penggunaan :
  Pasang dibawah material namun diatas main
  edit konfigurasinya kalo perlu
  
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

  Note :
  Script ini cuman ngubah tampilan di RTP saja.
  
=end
# =============================================================================
# Konfigurasi
# =============================================================================
module THEO
  module STATUS
    # =========================================================================
      Outline_Polygon_color   = Color.new(255,255,255)
      Outline_Polygon_radius  = 70
    # -------------------------------------------------------------------------
    # Opsi untuk poligon luar.
    # Color  >> untuk warna garis poligonnya (red,green,blue)
    # Radius >> untuk jarak dari titik pusatnya
    # =========================================================================
    
    # =========================================================================
      Params_Polygon_color    = Color.new(0,255,0)
      Params_Polygon_radius   = 60
    # -------------------------------------------------------------------------
    # Opsi untuk poligon dalem
    # Color  >> untuk warna garis poligonnya (red,green,blue)
    # Radius >> untuk jarak maksimum dari titik pusatnya
    # =========================================================================
    
  end
end
# =============================================================================
# Akhir dari konfigurasi
# =============================================================================
class Game_Battler < Game_BattlerBase
  
  def params_array
    return [self.atk,self.def,self.mat,self.mdf,self.agi,self.luk]
  end
  
end

class Window_Status < Window_Selectable
  if $imported[:Theo_BitmapAddons]
  include THEO::STATUS
  
  def draw_parameters(x, y)
    contents.draw_shape_params(x+50,y+70,@actor.params_array,Params_Polygon_radius,
      Params_Polygon_color)
    contents.draw_polygon(x+50,y+70,@actor.params_array.size,Outline_Polygon_radius,
      Outline_Polygon_color)
    6.times {|i| draw_actor_param(@actor, x+120, y + line_height * i, i + 2) }
  end
  
  def draw_actor_param(actor, x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 120, line_height, Vocab::param(param_id))
    change_color(normal_color)
    draw_text(x + 60, y, 36, line_height, actor.param(param_id), 2)
  end
  end
end
