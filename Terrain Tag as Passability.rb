# =============================================================================
# TheoAllen - Terrain Tag as Passability
# Version : 1.1
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (English Documentation)
# =============================================================================
($imported ||= {})[:Theo_TagPassability] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.11.23 - Rebuild the structure
#            - Fixed crash when checking an empty event
# 2013.06.21 - Finished script
# =============================================================================
=begin

  Perkenalan : 
  This script can make terrain tag as passability instead of use X or O
  
  Cara penggunaan :
  Put this script below material but above main
  Setting terrain tag in database, use this comment in event  
  
  <terrain tag: n>
  <terrain tag: m,n>
  <terrain tag: m,n, ...>
  
  Which n and m is a terrain tag number. You can also add multiple terrain tag
  such as <terrain tag: 1,2,3,4,5,6>
  
  Remember, if the event's terrain tag is determined, the event won't able to
  move to other tile with different terrain tag even if the tile passability
  is O
  
  Terms of use :
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.


=end
# =============================================================================
# No configuration. Better don't touch anything unless you know what to do
# =============================================================================
class Game_Event < Game_Character
  PASSTAG = /<terrain[\s_]+tag\s*:\s+(\d+(?:\s*,\s*\d+)*)>/i
  
  alias ori_passable? map_passable?
  def map_passable?(x,y,d)
    return ori_passable?(x,y,d) if @tag_passable.empty?
    return tag_passable?(x,y,d)
  end  
  
  alias theo_passtag_setup_page_settings setup_page_settings
  def setup_page_settings
    theo_passtag_setup_page_settings
    read_tag_passability
  end
  
  def read_tag_passability
    @tag_passable = []
    return unless @list
    @list.each do |command|
      next unless command.code == 108 || command.code == 408
      case command.parameters[0]
      when PASSTAG
        $1.scan(/\d+/).each do |num|
          puts num.to_i
          @tag_passable.push(num.to_i)
        end
      end
    end
  end
  
  def tag_passable?(x,y,d)
    x2 = $game_map.round_x_with_direction(x, d)
    y2 = $game_map.round_y_with_direction(y, d)
    @tag_passable.include?($game_map.terrain_tag(x2,y2))
  end
  
end
