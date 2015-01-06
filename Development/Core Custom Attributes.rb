#==============================================================================
# TheoAllen - Core Custom Attributes
# Version : 0.1
# Language : English
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://www.theolized.com
#==============================================================================
($imported ||= {})[:Theo_CustomAttr] = true
#==============================================================================
=begin

  These core custom attributes aimed to have dynamic custom stats. Every stat
  could affect built-in stat like if you increase the STR, then the attack and
  MHP could increase. And many other things. Also your own custom parameters
  could be used in damage formula as well since I added new method in 
  Game_Battler.
  
  Due to lack of understanding of people need, I temporarily abandoned this 
  script project. Any derivated works from this script are welcomed. However
  please put my name in credit list, TheoAllen.

=end
#==============================================================================
module Theo
  module Attr
  #============================================================================
  # The script config for this script is a bit unique and need a little more
  # understanding. Here you could define your own attributes. The following
  # format should be used when setting the script
  #
  # List[:symbol] = {
  #   :init => initial value, 
  #   :name => "Parameter name",
  #   :desc => "Parameter description",
  #   :param => {parameter change},
  #   :max => parameter maximum,
  # }
  #
  # :init
  # For initial value of the parameter at the beginning by default
  #
  # :name
  # Parameter name. It just trivia, and not used at the moment. Just in case if
  # there will be a UI script that show parameter name
  #
  # :desc
  # Parameter description. Just like :name, it just trivia
  #
  # :param
  # The affection of the parameter to default parameters like MHP, MMP, etc.
  # It should be written in this format {:atk => 1, :mhp => 10}. It means that
  # every one value of the custom parameter will add 1 attack and 10 MHP.
  #
  # :max
  # Maximum value of param. Not yet implemented.
  #
  # These custom parameter could be used in damage formula as well. If you set
  # List[:str] = { :init => 10 }, then you write damage formula like this
  # "a.str", it will deal 10 damage.
  #
  #----------------------------------------------------------------------------
  # Reserved symbol! Avoid use these symbol
  #----------------------------------------------------------------------------
  # Basic Params    --> :mhp, :mmp, :atk, :def, :mat, :mdf, :agi, :luk 
  # Extra Params    --> :eva, :cri, :cev, :mev, :mrf, :cnt, :hrg, :mrg, :trg
  # Special Params  --> :trg, :grd, :rec, :pha, :mcr, :tcr, :pdr, :mdr, :fdr
  #                     :exr
  #============================================================================
  List = {} # <-- Do not touch this
  #============================================================================
  # Config part
  #============================================================================
  List[:str] = {
    :name   => 'Strength',
    :desc   => 'Increase Max HP (+3/point) and Attack (+1/point)',
    :param  => {:mhp => 3, :atk => 1},
  }
    
  List[:int] = {
    :name   => 'Intelligence',
    :desc   => 'Increase magic attack and magic defend one per point',
    :param  => {:mat => 1, :mdf => 1},
  }
  
  List[:fin] = {
    :name   => 'Finesse',
    :desc   => 'Increase Agility and Luck by one per point',
    :param  => {:agi => 1, :luk => 1},
  }
  
  List[:endr] = {
    :name   => 'Endurance',
    :desc   => 'Increase defense point by one per point',
    :param  => {:def => 1},
  }
  
  List[:ref] = {
    :name   => 'Reflex',
    :desc   => 'Increase evasion rate by 5% per point',
    :param  => {:eva => 0.05},
  }
  
  List[:res] = {
    :name   => 'Resistance',
    :desc   => 'Increase magic evasion and magic reflect by 5% per point',
    :param  => {:mev => 0.05, :mrf => 0.05},
  }
  
  List[:mana] = {
    :name   => 'Mana Poll',
    :desc   => 'Increase Maximum MP by 25 per point',
    :param  => {:mmp => 25},
  }
  
  end
end

class RPG::Class
  CustomStat_REGX = /<init[\s_]+(.+)\s*:\s*(\d+)>/i
  
  def custom_stats
    return @custom_stats if @custom_stats
    @custom_stats = {}
    note.split(/[\r\n]+/).each do |line|
      if line =~ CustomStat_REGX
        @custom_stats[$1.to_sym] = $2.to_i
      end
    end
    return @custom_stats
  end
  
end

class Game_Battler
  ParamSymbols = {
  
  # Basic Parameters
    :mhp => [:param_base,0],
    :mmp => [:param_base,1],
    :atk => [:param_base,2],
    :def => [:param_base,3],
    :mat => [:param_base,4],
    :mdf => [:param_base,5],
    :agi => [:param_base,6],
    :luk => [:param_base,7],
    
  # Extra Parameters  
    :eva => [:xparam,1],
    :cri => [:xparam,2],
    :cev => [:xparam,3],
    :mev => [:xparam,4],
    :mrf => [:xparam,5],
    :cnt => [:xparam,6],
    :hrg => [:xparam,7],
    :mrg => [:xparam,8],
    :trg => [:xparam,9],
    
  # Special Parameters
    :tgr => [:sparam,0],
    :grd => [:sparam,1],
    :rec => [:sparam,2],
    :pha => [:sparam,3],
    :mcr => [:sparam,4],
    :tcr => [:sparam,5],
    :pdr => [:sparam,6],
    :mdr => [:sparam,7],
    :fdr => [:sparam,8],
    :exr => [:sparam,9],
  }
  
  Param_Indexes = {
    0 => [:mhp, :tgr],
    1 => [:mmp, :grd, :eva],
    2 => [:atk, :rec, :cri],
    3 => [:def, :pha, :cev],
    4 => [:mat, :mcr, :mev],
    5 => [:mdf, :tcr, :mrf],
    6 => [:agi, :pdr, :cnt],
    7 => [:luk, :mdr, :hrg],
    8 => [:mhp, :fdr, :mrg],
    9 => [:mhp, :exr, :trg],
  }
  
  alias theo_custom_attr_init initialize
  def initialize
    @param_attr = {}
    theo_custom_attr_init
  end
  
  #-----------------------------------------------------------------------------
  # Dynamically add new attributes
  #-----------------------------------------------------------------------------
  Theo::Attr::List.each do |param_symbol, values|
    
  define_method(param_symbol) { 
    @param_attr[param_symbol] ||= (values[:init] || 0)
  }
  
  writer = (param_symbol.to_s + "=")
  define_method(writer) { |val| 
    stat_val = [val, (values[:max] || Theo::Attr::DefaultMax)].min
    @param_attr[param_symbol] = stat_val
  }
  
  values[:param].each do |psym2, val_inc|
    old_method = ParamSymbols[psym2][0]
    new_method = "theo_statdist_#{param_symbol}_#{psym2}_#{old_method}"
    alias_method(new_method, old_method)
    
    define_method(old_method) do |param_id|
      send(new_method, param_id) + (Param_Indexes[param_id].include?(psym2) ?
        send(param_symbol) * val_inc : 0)
    end
  end if values[:param]
  
  end # Theo::Attr::List.each
  #-----------------------------------------------------------------------------
  # End of dynamic new attributes
  #-----------------------------------------------------------------------------
  
  def gain_attr(symbol, value)
    @param_attr[symbol] ||= 0
    @param_attr[symbol] += value
  end
  
end

class Game_Actor
  
  alias theo_custom_attr_setup setup
  def setup(actor_id)
    theo_custom_attr_setup(actor_id)
    self.class.custom_stats.each do |sym, val|
      send(sym.to_s + "=", val)
    end
  end
  
end
