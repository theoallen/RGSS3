#===============================================================================
# TheoAllen - Temporary Text Bubble
#-------------------------------------------------------------------------------
# 2018.08.13 - Finished
#===============================================================================
# > Introduction
#-------------------------------------------------------------------------------
# This script pops up a text bubble above a character and goes away after 
# certain time has passed. It should not be used for an actual text dialogue
# as it has no wait time. Best to be used as random NPC/Character commentary
#
#===============================================================================
# > How to use
#-------------------------------------------------------------------------------
# Use it in move route script call
# > bubble(text)
# > bubble(text, timeout)
#
# Text is an actual text using ""
# Timeout is frame before it starts fading. Default value is 90 frames
#
# Example :
# > bubble("What was that?")
# > bubble("What was that?", 120)
#
# For splitting into two line, use \n
# Example :
# > bubble("What was that? Sure\n I saw something")
# > bubble("What was that? Sure\n I saw something", 120)
#
#===============================================================================
# > Terms of Use
#-------------------------------------------------------------------------------
# Credit me, TheoAllen. You are free to edit this script by your own. As long 
# as you don't claim it's yours. For commercial purpose, don't forget to give me
# a free copy of the game.
#===============================================================================
class Sprite_Bubble < Sprite
  Height = 16
  Col = Color.new(0,0,0,180)
  
  def initialize(vport, char, text, timeout = 60)
    super(vport)
    @char = char
    self.bitmap = Bitmap.new(23,23)
    bitmap.font.size = Height
    show_text(text)
    @timeout = timeout
    update
  end
  
  def show_text(text)
    @text = text.split(/\n/)
    s = @text.collect {|t| self.bitmap.text_size(t).width}.max
    bmp = Bitmap.new(s+10,Height*@text.size + 5)
    self.bitmap = bmp
    bitmap.font.size = Height
    draw_background
    draw_message
    self.ox = width/2
    self.oy = height
  end
  
  def draw_background
    # main body
    h = Height*@text.size + 1
    bitmap.fill_rect(2,0,width-4,h,Col)
    
    # border left
    bitmap.fill_rect(1,1,1,h-2,Col)
    bitmap.fill_rect(0,2,1,h-4,Col)
    
    # border right
    bitmap.fill_rect(width-1 ,2 ,1 ,h-4,Col)
    bitmap.fill_rect(width-2 ,1 ,1 ,h-2,Col)
    
    # pointer
    bitmap.fill_rect(width/2-3, h    ,7,1,Col)
    bitmap.fill_rect(width/2-2, h+1  ,5,1,Col)
    bitmap.fill_rect(width/2-1, h+2  ,3,1,Col)
    bitmap.fill_rect(width/2,   h+3  ,1,1,Col)
  end
  
  def draw_message
    @text.each_with_index do |t,i|
      bitmap.draw_text(5,Height*i,width,20,t)
    end
  end
  
  def update
    super
    update_position
    @timeout -= 1
    if @timeout == 0
      if $imported[:Theo_CoreFade] && !fade?
        fadeout(30)
      else
        dispose
      end
    elsif opacity == 0
      dispose
    end
  end
  
  def update_position
    self.x = @char.x
    self.y = @char.y - @char.height
  end
  
end

class Game_Character
  attr_reader :bubble_text
  attr_reader :bubble_timeout
  
  def bubble(text, timeout = 100)
    @bubble_text = text
    @bubble_timeout = timeout
  end
  
  def clear_bubbles
    @bubble_text = @bubble_timeout = nil
  end
end

class Sprite_Character
  
  alias aed2_text_bubble_update update
  def update
    aed2_text_bubble_update
    if !character.bubble_text.nil? && (!@bubble || @bubble.disposed?)
      text = character.bubble_text
      time = character.bubble_timeout
      character.clear_bubbles
      @bubble = Sprite_Bubble.new(viewport,self,text,time)
    end
    @bubble.update if @bubble && !@bubble.disposed?
  end
  
  alias aed2_text_bubble_dispose dispose
  def dispose
    aed2_text_bubble_dispose
    @bubble.dispose if @bubble && !@bubble.disposed?
  end
  
end
