#==============================================================================
# TheoAllen - Sprite Extensions
# Version : 1.0
# Language : Informal Indonesian
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://www.theolized.com
#==============================================================================
($imported ||= {})[:Theo_SpriteEX] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.01.30 - Finished script
# =============================================================================
%Q{

  =================
  || Perkenalan ||
  -----------------
  Pernah ngerasa pengen import fungsi-fungsi di window kek draw_text_ex dan
  draw_gauge ke dalam sprite? Cuman akan terasa merepotkan jika kamu harus
  copy paste satu-satu, kan? 
  
  Dengan script ini, kamu bisa menggunakan semua fungsi Window_Base ke dalam
  Sprite. Seperti draw_text_ex, draw_gauge, atau bahkan draw_actor_simple_status
  
  ======================
  || Cara penggunaan ||
  ----------------------
  Pasang script ini di bawah material namun di atas main
  
  Seperti yang udah gw jelaskan di atas, sekarang kalian sudah bisa gunain
  fungsi-fungsi window di dalam class Sprite dan Plane. Sisanya ada di gimana
  kalian gunainnnya.
  
  ===================
  || Terms of use ||
  -------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

}
# =============================================================================
# Tidak ada konfigurasi
# =============================================================================
module Theo
  class Global_Window < Window_Base
    attr_accessor :sprite_ref
    
    def contents
      if @sprite_ref
        if @sprite_ref.disposed?
          @sprite_ref = nil
          return super
        else
          return sprite_ref.bitmap
        end
      else
        super
      end
    end
    
  end
  
  def self.glob_window
    if @glob_window.nil? || @glob_window.disposed?
      @glob_window = Global_Window.new(0,0,1,1)
      @glob_window.visible = false
      @glob_window.gobj_exempt if @glob_window.respond_to?(:gobj_exempt)
      # Compatibility with mithran's
    end
    return @glob_window
  end
  
end

class Sprite
  
  def method_missing(name, *args, &block)
    window = Theo.glob_window
    if window.respond_to?(name)
      window.sprite_ref = self
      window.send(name, *args, &block)
    else
      super
    end
  end
  
end

class Plane
  
  def method_missing(name, *args, &block)
    window = Theo.glob_window
    if window.respond_to?(name)
      window.sprite_ref = self
      window.send(name, *args, &block)
    else
      super
    end
  end
  
end

#~ DataManager.init
#~ def updates
#~   Graphics.update
#~   Input.update
#~   @sprite.update
#~ end

#~ @sprite = Sprite.new
#~ @sprite.bitmap = Bitmap.new(544, 416)
#~ text = "Testing Icon \\I[34]\nNew line\n\nNew line\n\\C[23]change color?" +
#~ "\n\n\\C[0]Well... you can even call draw actor simple status :3"
#~ @sprite.draw_text_ex(0,0,text)
#~ @sprite.draw_actor_simple_status($game_actors[1], 0, 24 * 8)
#~ updates while true
