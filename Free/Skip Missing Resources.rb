# ===========================================================================
=begin

  Theo - Skip Missing Resources
  Version : 1.1

  _(:3JZ)_
  This script allow you to continue to play the game even though the 
  resources are missing

=end
# ===========================================================================
($imported ||= {})[:Theo_SkipResource] = true

module THEO
  
  MissingList_FileName = "List"
  # A filename to record what was missing
  
  ShowMessageBox = true
  # You want to show a dialogue box where it shows u what is missing?
  
  MissingSound = "Missing sound!"
  # A text to show when a sound is missing  
  
  MissingBitmap = "Missing bitmap!"
  # A text to show when a graphic is missing
  
end

# ===========================================================================
class << Audio
  
  [:bgm, :bgs, :me, :se].each do |method|
    eval "
    alias pre_skip_#{method}_play #{method}_play
    def #{method}_play(filename, *args)
      begin
        pre_skip_#{method}_play(filename, *args) 
      rescue 
        msgbox THEO::MissingSound + \"\n\" + filename unless 
          Cache.missing_included?(filename) && THEO::ShowMessageBox
        Cache.missing_resource_add(filename)
        Cache.write_missing_list
        return
      end
    end
    "
  end
  
end

class << Cache
  
  def missing_resource_add(path)
    missing_list
    @missing.push(path) unless missing_included?(path)
  end
  
  def missing_included?(path)
    missing_list
    @missing.include?(path)
  end
  
  def missing_list
    return @missing ||= []
  end
  
  def write_missing_list
    File.open(THEO::MissingList_FileName + ".txt", "w+") do |file|
      Marshal.dump(make_missing_list, file)
    end
  end
  
  def make_missing_list
    Cache.missing_list.inject("\r\n"*2) do |text, list|
      text + list + "\r\n"
    end + "\r\n"
  end
  
end

class Bitmap
  
  alias pre_skip_init initialize
  def initialize(*args)
    begin 
      pre_skip_init(*args)
    rescue
      msgbox sprintf(THEO::MissingBitmap + "\n%s",args[0]) unless 
        Cache.missing_included?(args[0])
      Cache.missing_resource_add(args[0])
      Cache.write_missing_list
      pre_skip_init(32,32)
    end
  end
  
end
