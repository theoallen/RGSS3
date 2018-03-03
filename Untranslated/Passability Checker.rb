# =============================================================================
# TheoAllen - Passability Checker
# Version : 1.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# -----------------------------------------------------------------------------
# Require : Theo - Basic Modules v1.5
# > Basic Functions
# > Bitmap Extra Addons
# =============================================================================
($imported ||= {})[:Theo_PassDebug] = true
# =============================================================================
# Change Logs :
# -----------------------------------------------------------------------------
# 2014.09.22 - Finished Script
# =============================================================================
=begin

  Perkenalan :
  Punya masalah dengan pengecekan passability? Ngga punya waktu buat ngecekin
  tiap sudut peta? Script ini ngebantu kamu buat ngecekin seluruh isi peta dan
  ditampilkan dalam bentuk garis. Sehingga kamu tahu mana yang punya
  passability salah
  
  Cara penggunaan :
  Pasang script ini di bawah material namun diatas main
  Tekan tombol trigger buat mulai ngetes passability
  
  Terms of Use :
  Script ini dibuat cuman untuk keperluan debugging. Jika kamu bisa ngedit
  script ini jadi lebih baik, silahkan saja. Jika kamu mau nge-share versi
  editan kamu sendiri, jangan lupa tetep credit gw, TheoAllen.

=end
# =============================================================================
# Config
# =============================================================================
module Theo
  module PassDebug
    
    Activate = true
    # Aktivasi script?
    
    BelowCharacter = false
    # Taruh dibawah karakter?
    
    Trigger   = :F7  # Trigger buat ngedraw garis
    Erase     = :F8  # Trigger buat ngehapus semua garis
    
    Multitask = true 
    # Jika multitask dinyalain, kamu masi bisa jalan-jalan selagi script
    # nggambar garis. Jika ngga, screen RM kamu akan mengalami frameskip / hang
    # sebentar untuk ngegambar garis-garis di setiap sudut map
    
    LineColor = Color.new(255,255,255,255)
    # Warna garis yang akan digambar. Dalam format :
    # (red, green, blue, transparansi)
    
  end
end
# =============================================================================
# End config. Ngedit dibawah ini adalah resiko lu ndiri.
# =============================================================================

# =============================================================================
# ** DebugNodes
# -----------------------------------------------------------------------------
#   Imported from basic modules, Coordinate class. It contains x,y coordinate
# and can be linked to neightbour nodes in direction (2,4,6,8)
# =============================================================================
class DebugNodes < Coordinate
  attr_reader :nodes  # Neightbour nodes in direction
  # ---------------------------------------------------------------------------
  # *) Initialize
  # ---------------------------------------------------------------------------
  def initialize(x,y)
    super(x,y)
    @nodes = {}
  end
  # ---------------------------------------------------------------------------
  # *) Connect to neightbour nodes
  # ---------------------------------------------------------------------------
  def make_nodes(mapnodes, char)
    dir = [2,4,6,8]
    dir.each do |d|
      next unless char.passable?(x,y,d)
      xpos = x
      ypos = y
      case d
      when 2 # DOWN
        ypos += 1
      when 4 # LEFT
        xpos -= 1
      when 6 # RIGHT
        xpos += 1
      when 8 # UP
        ypos -= 1
      end
      key = [xpos,ypos]
      next_node = mapnodes[key]
      if next_node.nil?
        next_node = DebugNodes.new(xpos,ypos)
        mapnodes[key] = next_node
      end
      self.nodes[d] = next_node
      draw_vector(next_node)
    end
  end
  # ---------------------------------------------------------------------------
  # *) Draw vector arrow from Bitmap Extra Addons (Basic Module)
  # ---------------------------------------------------------------------------
  def draw_vector(n2)
    # Clone nodes
    n1 = self.clone
    n2 = n2.clone
    
    # Adjust (x,y) values
    n1.x = n1.x * 32 + 16
    n1.y = n1.y * 32 + 16
    n2.x = n2.x * 32 + 16
    n2.y = n2.y * 32 + 16
    
    # Get arrow color
    color = Theo::PassDebug::LineColor
    # Draw arrow
    SceneManager.scene.screen_mask.bitmap.draw_arrow(n1,n2,color)
    # Yield fiber if fiber is not nil.
    Fiber.yield if SceneManager.scene.screen_mask.fiber
  end
  
end

# =============================================================================
# ** Vport_Mask
# -----------------------------------------------------------------------------
#   Exclusive viewport for Screen_Mask. Just to make sure mine is always on
# top. Deal with it
# =============================================================================

class Vport_Mask < Viewport
  # ---------------------------------------------------------------------------
  # *) Initialize
  # ---------------------------------------------------------------------------
  def initialize(*args)
    super(*args)
    self.z = 999 # Always on top
  end
  
end

# =============================================================================
# ** Screen_Mask
# -----------------------------------------------------------------------------
#   Imported from basic modules, Plane_Mask class. It's simply invisible
# parallax sprite used to draw arrows on map
# =============================================================================

class Screen_Mask < Plane_Mask
  attr_accessor :fiber  # Fiber thread to allow multithreading
  # ---------------------------------------------------------------------------
  # *) Initialize
  # ---------------------------------------------------------------------------
  def initialize(vport)
    super(vport)
    @width = 1
    @height = 1
  end
  # ---------------------------------------------------------------------------
  # *) Update method
  # ---------------------------------------------------------------------------
  def update
    super
    if bitmap && Input.trigger?(Theo::PassDebug::Trigger)
      if Theo::PassDebug::Multitask
        @fiber = Fiber.new { draw_passability }
      else
        draw_passability
      end
    end
    if bitmap && Input.trigger?(Theo::PassDebug::Erase)
      @fiber = nil
      bitmap.clear
    end
    @fiber.resume if @fiber
  end
  # ---------------------------------------------------------------------------
  # *) Draw passability arrow
  # ---------------------------------------------------------------------------
  def draw_passability
    $game_player.create_passdebug
  end
  
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#   This class handles the player. It includes event starting determinants and
# map scrolling functions. The instance of this class is referenced by
# $game_player.
#==============================================================================

class Game_Player
  # ---------------------------------------------------------------------------
  # *) Create passability debug
  # ---------------------------------------------------------------------------
  def create_passdebug
    @passdebug = {}
    player = Marshal.load(Marshal.dump(self))
    for i in 0..$game_map.width
      for j in 0..$game_map.height
        key = [i,j]
        node = @passdebug[key]
        if node
          node.make_nodes(@passdebug, player)
        else
          new_node = DebugNodes.new(i,j)
          new_node.make_nodes(@passdebug, player)
          @passdebug[key] = new_node
        end
      end
    end
    SceneManager.scene.screen_mask.fiber = nil
    @passdebug.clear
  end
  
end

class Spriteset_Map
  attr_reader :viewport1
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#   This class performs the map screen processing.
#==============================================================================

class Scene_Map
  attr_reader :screen_mask
  # ---------------------------------------------------------------------------
  # *) Update
  # ---------------------------------------------------------------------------
  alias theo_passdebug_start start
  def start
    theo_passdebug_start
    @vport_mask = Vport_Mask.new
    vport = (Theo::PassDebug::BelowCharacter ? @spriteset.viewport1 : 
      @vport_mask)
    @screen_mask = Screen_Mask.new(vport)
    @screen_mask.z = 25
  end
  # ---------------------------------------------------------------------------
  # *) Update
  # ---------------------------------------------------------------------------
  alias theo_passdebug_update update
  def update
    theo_passdebug_update
    return unless Theo::PassDebug::Activate && !scene_changing?
    @screen_mask.update 
  end
  # ---------------------------------------------------------------------------
  # *) Terminate
  # ---------------------------------------------------------------------------
  alias theo_passdebug_terminate terminate
  def terminate
    theo_passdebug_terminate
    @screen_mask.dispose
    @vport_mask.dispose
  end
  # ---------------------------------------------------------------------------
  # *) Pre Transfer
  # ---------------------------------------------------------------------------
  alias theo_passdebug_pre_transfer pre_transfer
  def pre_transfer
    @screen_mask.bitmap.clear
    theo_passdebug_pre_transfer
  end
  
end
