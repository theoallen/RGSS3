#==============================================================================
# YEA + Theolized ~ Global System Option
# Version : 1.0
# Language : Informal Indonesian
# Requires : YEA System Option
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://www.theolized.com
#==============================================================================
($imported ||= {})[:Theo_GlobalOption] = true
#==============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.10.27 - Finished
#==============================================================================
%Q{

  =================
  || Perkenalan ||
  -----------------
  Script ini adalah addon untuk YEA System Option dimana opsi yang kamu atur
  nantinya akan disimpan secara global dan akan dipakai di setiap save file
  
  ======================
  || Cara penggunaan ||
  ----------------------
  Pasang script ini di bawah YEA system option
  
  Script ini akan membuat file yang bernama 'OptionData.rvdata2' di folder
  game kamu. Jika kamu ingin mereset system option, tinggal delete saja file
  tersebut dan saat kamu jalankan kembali, maka semuanya akan direset dan file
  akan dibuat kembali.
  
  ===================
  || Terms of use ||
  -------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

}
#==============================================================================
# Tidak ada konfigurasi
#==============================================================================
if $imported["YEA-SystemOptions"]  
#==============================================================================
# * DataManager
#==============================================================================

class << DataManager
  
  alias theo_globoption_load_db load_database
  def load_database
    theo_globoption_load_db
    OptionData.init
  end
  
end

#==============================================================================
# * SceneManager
#==============================================================================

class << SceneManager
  
  def from_title?
    @stack[-1].is_a?(Scene_Title)
  end
  
end

#==============================================================================
# * OptionData
#==============================================================================

class OptionData
  attr_accessor :volume_bgm
  attr_accessor :volume_bgs
  attr_accessor :volume_sfx
  attr_accessor :autodash
  attr_accessor :instant_msg
  attr_accessor :animations
  attr_accessor :window_tone
  attr_reader :switch_ids
  attr_reader :var_ids
  attr_reader :switches
  attr_reader :variables
  
  FileName = 'OptionData.rvdata2'
  
  def self.init
    if FileTest.exist?(FileName)
      $option_data = load_data(FileName)
      $option_data.refresh_switch_var
    else
      $option_data = OptionData.new
      OptionData.save
    end
  end
  
  def self.save
    File.open(FileName, 'w') do |file|
      Marshal.dump($option_data, file)
    end
  end
  
  def initialize
    @volume_bgm = 100
    @volume_bgs = 100
    @volume_sfx = 100
    @autodash = YEA::SYSTEM::DEFAULT_AUTODASH
    @instant_msg = YEA::SYSTEM::DEFAULT_INSTANTMSG
    @animations = YEA::SYSTEM::DEFAULT_ANIMATIONS
    @window_tone = $data_system.window_tone.clone
    @switches = {}
    @variables = {}
    refresh_switch_var
  end
  
  def refresh_switch_var
    switch_keys = YEA::SYSTEM::COMMANDS & YEA::SYSTEM::CUSTOM_SWITCHES.keys
    used_switches = switch_keys.collect {|k| YEA::SYSTEM::CUSTOM_SWITCHES[k]}
    @switch_ids = used_switches.collect {|val| val[0]}
    
    var_keys = YEA::SYSTEM::COMMANDS & YEA::SYSTEM::CUSTOM_VARIABLES.keys
    used_var = var_keys.collect {|k| YEA::SYSTEM::CUSTOM_VARIABLES[k]}
    @var_ids = used_var.collect {|val| val[0]}
    
    used_var.each do |vari|
      orival = (@variables[vari[0]] ||= 0)
      min = vari[4]
      max = vari[5]
      @variables[vari[0]] = [[orival, min].max, max].min
    end
    
  end
  
end

#==============================================================================
# * Game_System
#==============================================================================

class Game_System
  
  def window_tone
    $option_data.window_tone
  end
  
  def window_tone=(tone)
    $option_data.window_tone = tone
  end
  
  def volume(type)
    case type
    when :bgm
      result = $option_data.volume_bgm
    when :bgs
      result = $option_data.volume_bgs
    when :sfx
      result = $option_data.volume_sfx
    else
      return 100
    end
    return [[result, 0].max, 100].min
  end
  
  def volume_change(type, inc)
    case type
    when :bgm
      $option_data.volume_bgm = [[$option_data.volume_bgm + inc, 0].max,100].min
    when :bgs
      $option_data.volume_bgs = [[$option_data.volume_bgs + inc, 0].max,100].min
    when :sfx
      $option_data.volume_sfx = [[$option_data.volume_sfx + inc, 0].max,100].min
    end
    OptionData.save
  end
  
  def set_autodash(value)
    $option_data.autodash = value
    OptionData.save
  end
  
  def autodash?
    $option_data.autodash
  end
  
  def set_instantmsg(value)
    $option_data.instant_msg = value
    OptionData.save
  end
  
  def instantmsg?
    $option_data.instant_msg
  end
  
  def set_animations(value)
    $option_data.animations = value
    OptionData.save
  end
  
  def animations?
    $option_data.animations
  end
  
end

#==============================================================================
# * Game_Switches
#==============================================================================

class Game_Switches
  
  alias :glob_switch :[]
  alias :glob_switch_set :[]=
  
  def [](id)
    if $option_data.switch_ids.include?(id)
      return $option_data.switches[id] || false
    end
    return glob_switch(id)
  end
  
  def []=(id, val)
    if $option_data.switch_ids.include?(id)
      $option_data.switches[id] = val
      OptionData.save
      on_change
      return
    end
    return glob_switch_set(id, val)
  end
  
end

#==============================================================================
# * Game_Variables
#==============================================================================

class Game_Variables
  
  alias :glob_var :[]
  alias :glob_var_set :[]=
  
  def [](id)
    if $option_data.var_ids.include?(id)
      return $option_data.variables[id] ||= 0
    end
    return glob_var(id)
  end
  
  def []=(id, val)
    if $option_data.var_ids.include?(id)
      $option_data.variables[id] = val
      OptionData.save
      on_change
      return
    end
    return glob_var_set(id, val)
  end
  
end

#==============================================================================
# * Window_TitleCommand
#==============================================================================

class Window_TitleCommand
  
  alias theo_globoption_init initialize
  def initialize
    theo_globoption_init
    set_handler(:option, method(:goto_option))
  end
  
  alias theo_globoption_make_command make_command_list
  def make_command_list
    theo_globoption_make_command
    hash = { 
      :name => YEA::SYSTEM::COMMAND_NAME, 
      :symbol => :option, 
      :enabled=> true, 
      :ext=> nil
    }
    @list.insert(2, hash)
  end
  
  def goto_option
    SceneManager.call(Scene_System)
  end
  
end

#==============================================================================
# * Scene_System
#==============================================================================

class Scene_System
  
  alias theo_globoption_terminate terminate
  def terminate
    theo_globoption_terminate
    OptionData.save
  end
  
  def command_to_title
    fadeout_all unless SceneManager.from_title?
    SceneManager.goto(Scene_Title)
  end
  
end

end # $imported
