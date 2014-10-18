module Theo
  module Attr
    
  DefaultMax    = 10
  DefaultCost   = 'param_level + 1'
  
  PointInit     = 10
  LevelUpPoint  = 2
  
  #============================================================================
  # Reserved symbol! Please do not use these symbol as a new attributes
  #----------------------------------------------------------------------------
  # Basic Params    --> :mhp, :mmp, :atk, :def, :mat, :mdf, :agi, :luk 
  # Extra Params    --> :eva, :cri, :cev, :mev, :mrf, :cnt, :hrg, :mrg, :trg
  # Special Params  --> :trg, :grd, :rec, :pha, :mcr, :tcr, :pdr, :mdr, :fdr
  #                     :exr
  #============================================================================
  List = {}
  List[:str] = {
    :name   => 'Strength',
    :max    => 10,
    :desc   => 'Increase Max HP (+3/point) and Attack (+100/point)',
    :param  => {:mhp => 3, :atk => 100},
  }
    
  List[:int] = {
    :name   => 'Intelligence',
    :max    => 10,
    :desc   => 'Increase magic attack and magic defend one per point',
    :param  => {:mat => 1, :mdf => 1},
  }
  
  List[:fin] = {
    :name   => 'Finesse',
    :max    => 10,
    :desc   => 'Increase Agility and Luck by one per point',
    :param  => {:agi => 1, :luk => 1},
  }
  
  List[:endr] = {
    :name   => 'Endurance',
    :max    => 10,
    :desc   => 'Increase defense point by one per point',
    :param  => {:def => 1},
  }
  
  List[:ref] = {
    :name   => 'Reflex',
    :max    => 5,
    :desc   => 'Increase evasion rate by 5% per point',
    :param  => {:eva => 0.05},
  }
  
  List[:res] = {
    :name   => 'Resistance',
    :max    => 5,
    :desc   => 'Increase magic evasion and magic reflect by 5% per point',
    :param  => {:mev => 0.05, :mrf => 0.05},
  }
  
  List[:mana] = {
    :name   => 'Mana Poll',
    :max    => 10,
    :desc   => 'Increase Maximum MP by 25 per point',
    :param  => {:mmp => 25},
  }
  
  end
end

class Game_Actor
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
  
  attr_accessor :attr_points
  
  alias theo_stat_dist_init initialize
  def initialize(actor_id)
    @param_stats = {}
    @attr_points = 0
    theo_stat_dist_init(actor_id)
  end
  
  alias theo_stat_dist_setup setup
  def setup(actor_id)
    theo_stat_dist_setup(actor_id)
    @attr_points = Theo::Attr::PointInit
  end
  
  #-----------------------------------------------------------------------------
  Theo::Attr::List.each do |param_symbol, values|
    
  define_method(param_symbol) { @param_stats[param_symbol] ||= 0 }
  writer = (param_symbol.to_s + "=").to_sym
  define_method(writer) { |val| 
    stat_val = [val, (values[:max] || Theo::Attr::DefaultMax)].min
    @param_stats[param_symbol] = stat_val
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
  alias theo_stat_dist_level_up level_up
  def level_up
    theo_stat_dist_level_up
    @attr_point += Theo::Attr::LevelUpPoint
  end
  
  def param_cost(symbol)
    param_level = send(symbol)
    formula = Theo::Attr::List[symbol][:cost] || Theo::Attr::DefaultCost
    return eval(formula)
  end
  
  def assign_value(symbol)
    symbol = (symbol.to_s + "=")
    send(symbol, 1)
    @attr_points -= 1
  end
  
  def can_upgrade_param?(symbol)
    return @attr_points >= param_cost(symbol)
  end
  
end
