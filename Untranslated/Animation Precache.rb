#==============================================================================
# ** Theo - Animations Precaching
#------------------------------------------------------------------------------
#  Untuk memproses animasi sebelum masuk game. Seperti loading dalam game.
# Proses precaching dilakukan agar game tidak mengalami banyak lag. Namun
# timpal baliknya adalah game akan memakan memori lebih banyak
#==============================================================================

  AnimID_Start  = 63 # ID animasi start
  AnimID_End    = 230 # ID animasi end

#==============================================================================
# End of Config ~
#==============================================================================
class Sprite_Base < Sprite
  def dispose_animation
#~     if @ani_bitmap1
#~       @@_reference_count[@ani_bitmap1] -= 1
#~       if @@_reference_count[@ani_bitmap1] == 0
#~         @ani_bitmap1.dispose
#~       end
#~     end
#~     if @ani_bitmap2
#~       @@_reference_count[@ani_bitmap2] -= 1
#~       if @@_reference_count[@ani_bitmap2] == 0
#~         @ani_bitmap2.dispose
#~       end
#~     end
    if @ani_sprites
      @ani_sprites.each {|sprite| sprite.dispose }
      @ani_sprites = nil
      @animation = nil
    end
    @ani_bitmap1 = nil
    @ani_bitmap2 = nil
  end
end

class Sprite_Loading < Sprite
  attr_accessor :rate
  
  def initialize
    super
    @rate = 0.0
    self.bitmap = Bitmap.new(400, 10)
    col1 = Color.new(128,128,128)
    col2 = Color.new(255,255,255)
    bitmap.gradient_fill_rect(bitmap.rect, col1, col2)
    self.x = (Graphics.width - width) / 2
    self.y = (Graphics.height - height) / 2
    update_src_rect
  end
  
  def update_src_rect
    src_rect.width = bitmap.width * rate
  end
  
  def update
    super
    update_src_rect
  end
  
  def dispose
    bitmap.dispose
    super
  end
  
end

class SPR_Progress < Sprite
  
  def initialize
    super
    @count = 0
    self.bitmap = Bitmap.new(100,24)
    self.x = (Graphics.width - width) / 2
    self.y = (Graphics.height - height) / 2
    self.y += 30
    draw_progress
  end
  
  def count=(count)
    if @count != count
      @count = count
      draw_progress
    end
  end
  
  def dispose
    bitmap.dispose
    super
  end
  
  def draw_progress
    bitmap.clear
    text = "#{@count}%"
    bitmap.draw_text(bitmap.rect, text, 1)
  end
  
end

rgss_main {
  $data_animations = load_data("Data/Animations.rvdata2")
  @anim_count =  AnimID_End - AnimID_Start
  @loaded = 0
  @loading = Sprite_Loading.new
  @loading.visible = true
  # ----------------------------------
  @text = Sprite.new
  @text.bitmap = Bitmap.new(400, 24)
  @text.x = (Graphics.width - @text.width) / 2
  @text.y = (Graphics.height - @text.height) / 2
  @text.y -= 40
  txt = "Precaching animation. Please wait ..."
  @text.bitmap.draw_text(@text.bitmap.rect, txt, 1)
  @text.visible = true
  # ----------------------------------
  @progress = SPR_Progress.new
  @progress.visible = true

  def loading(anim_id)
    rate = @loaded / @anim_count.to_f
    @loading.rate = rate
    @loading.update
    @progress.count = (rate * 100).to_i
    data = $data_animations[anim_id]
    Cache.animation(data.animation1_name, data.animation1_hue)
    Cache.animation(data.animation2_name, data.animation2_hue)
    @loaded += 1
    update_basics
  end

  def update_basics
    Graphics.update
    Input.update
    Fiber.yield
  end

  @fiber = Fiber.new do 
    Audio.setup_midi
    for id1 in AnimID_Start..AnimID_End
      loading(id1)
    end
    @fiber = nil
  end unless $BTEST #|| $TEST

  while @fiber 
    @fiber.resume 
    break if Input.trigger?(:C) && $TEST
  end


  @loading.dispose
  @text.bitmap.dispose
  @text.dispose
  @progress.dispose
  @loading = nil
  @text = nil
  @progress = nil
  @anim_count = nil
  @loaded = nil
}
