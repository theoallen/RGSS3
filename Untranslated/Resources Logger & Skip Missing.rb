#==============================================================================
# TheoAllen - Resources Logger + Skip Missing Resource
# Version : 2.0
# Language : Informal Indonesian
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://theolized.blogspot.com
#==============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.10.06 - Finished
#==============================================================================
%Q{

  =================
  || Perkenalan ||
  -----------------
  Pernah kesusahan buat milah-milah resource apa aja yang kepake di game kamu?
  Pernah kesusahan buat ngecek resors mana sih yang ilang di game kamu?
  
  Sekarang kalian tidak perlu kesusahan. Script ini akan membantu kamu mencatat
  semua resource yang digunakan di game kalian. Dan jika kalian mau, script
  ini juga membantu mencatat grafis / audio mana aja yang ilang di dalam game 
  kamu. Yang kamu lakukan adalah tinggal melihat log yang dihasilkan oleh script
  ini di folder game kamu
  
  ======================
  || Cara penggunaan ||
  ----------------------
  Pasang script ini di bawah material namun di atas main
  Gunakan test play. Karena script ini hanya akan berjalan dengan test play
  
  Jika kalian ingin mematikan fungsi script ini, kalian bisa mengeset 
  Activate dengan false. Atau menaruh script ini di bawah main.
  
  ===================
  || Terms of use ||
  -------------------
  Jika kalian merasa terbantu dengan script ini, masukin ke special thanks.
  Script ini bebas dimodifikasi atau disebar luaskan. Dengan catatan, credit
  tetap buat gw, TheoAllen / Theolized RGSS3
  
}
#==============================================================================
# Konfigurasi
#==============================================================================
module Theo
  module ResLog
    
    Activate  = true  # Jalanin check menyeluruh? (true/false)
    Check     = true  # Mau sekalian tes apakah resors lagi ilang?(true/false)
    EndWait   = 120   # Berhenti sejenak sesudah ngecek dalam frame
    
    LogName   = "ResourceLog"
  # Nama file untuk mencatat resource log
    MissName  = "MissingResources"
  # Nama file untuk mencatat resource yang hilang
    
    MissingSkip = true 
  # Skip resors ilang waktu jalanin game? (true/false)
    
  end
end

#==============================================================================
# Di bawah garis ini jangan disentuh :v
#==============================================================================

class RPG::BGM
  def get_name
    return "Audio/BGM/" + name
  end
end

class RPG::BGS
  def get_name
    return "Audio/BGS/" + name
  end
end

class RPG::ME
  def get_name
    return "Audio/ME/" + name
  end
end

class RPG::SE
  def get_name
    return "Audio/SE/" + name
  end
end

class << Theo::ResLog
  
  def write_missing(path)
    @cache ||= []
    @cache << path
    @cache.uniq!
  end
  
end

class Theo_Window_ResLog < Window_Base
  
  def initialize(y)
    super(0, y, Graphics.width, fitting_height(1))
    self.opacity = 0
  end
  
  def set_text(text)
    contents.clear
    draw_text(contents.rect, text, 1)
  end
  
end

class ResLog_Loadingset
  attr_reader :current
  def initialize(max = 1)
    @max = [max, 1].max
    @current = 0
    create_all_instances
  end
  
  def create_all_instances
    # CREATE SPRITE
    @sprite_bar = Sprite.new
    @sprite_bar.bitmap = Bitmap.new(Graphics.width - 75 ,24)
    @sprite_bar.x = (Graphics.width - @sprite_bar.bitmap.width)/2
    @sprite_bar.y = (Graphics.height - @sprite_bar.bitmap.height)/2
    
    @window1 = Theo_Window_ResLog.new(Graphics.height/2 - 64)
    @window2 = Theo_Window_ResLog.new(@sprite_bar.y + @sprite_bar.height)
    @window3 = Theo_Window_ResLog.new(Graphics.height/2 - 24)
    
    rect = @sprite_bar.bitmap.rect
    col1 = @window1.hp_gauge_color1
    col2 = @window1.hp_gauge_color2
    @sprite_bar.bitmap.gradient_fill_rect(rect, col1, col2)
    refresh_rate
  end
  
  def max=(max)
    @max = max
    refresh_rate
  end
  
  def current=(current)
    @current = current
    refresh_rate
  end
  
  def refresh_rate
    rate = @current / @max.to_f
    @sprite_bar.src_rect.width = @sprite_bar.bitmap.width * rate
    @window3.set_text("#{(rate * 100).to_i}%")
  end
  
  def text1=(text)
    @window1.set_text(text)
  end
  
  def text2=(text)
    @window2.set_text(text)
  end
  
  def dispose
    @sprite_bar.dispose
    @window1.dispose
    @window2.dispose
    @window3.dispose
  end
  
end

#==============================================================================
# RESOURCES CHECKING TEST
#==============================================================================

if Theo::ResLog::Activate && $TEST

DataManager.init
loading_bar = ResLog_Loadingset.new

graphics_res = []  # Record graphics resources
audio_res = []     # Record audio resources

#==============================================================================
# Record all used graphics from database
#==============================================================================

# Mandatory graphics resources ~
graphics_res += ["Graphics/System/Iconset", "Graphics/System/Shadow", 
  "Graphics/System/Balloon", "Graphics/System/GameOver", 
  "Graphics/System/Window"]
  
# Database resources
graphics_res += $data_animations.compact.collect {|a| "Graphics/Animations/" + 
  a.animation1_name}
graphics_res += $data_animations.compact.collect {|a| "Graphics/Animations/" + 
  a.animation2_name}
graphics_res += $data_actors.compact.collect {|a| "Graphics/Characters/" + 
  a.character_name}
graphics_res += $data_actors.compact.collect {|a| "Graphics/Faces/" + 
  a.face_name}
graphics_res += $data_enemies.compact.collect {|e| "Graphics/Battlers/" + 
  e.battler_name}
graphics_res << "Graphics/Titles1/" + $data_system.title1_name
graphics_res << "Graphics/Titles2/" + $data_system.title2_name
$data_tilesets.compact.each do |tiles|
  8.times do |index|
    graphics_res << "Graphics/Tilesets/" + tiles.tileset_names[index]
  end
end

# Vehicle graphics
graphics_res << "Graphics/Characters/" + $data_system.boat.character_name
graphics_res << "Graphics/Characters/" + $data_system.ship.character_name
graphics_res << "Graphics/Characters/" + $data_system.airship.character_name

#==============================================================================
# Record all used audio from database
#==============================================================================

$data_animations.compact.each do |anim|
  anim.timings.each do |tim|
    audio_res << tim.se.get_name
  end
end

audio_res << $data_system.title_bgm.get_name
audio_res << $data_system.battle_bgm.get_name
audio_res << $data_system.battle_end_me.get_name
audio_res << $data_system.gameover_me.get_name
audio_res += $data_system.sounds.compact.collect {|s| s.get_name }

#==============================================================================
# Record all used graphics & audio from common events
#==============================================================================

$data_common_events.compact.each do |comev|
  comev.list.each do |list|
    case list.code
    when 101 # Show Text
      graphics_res << "Graphics/Faces/" + list.parameters[0]
    when 231 # Show Pic
      graphics_res << "Graphics/Pictures/" + list.parameters[1]
    when 132, 133, 241, 245, 249, 250 # Audio Related event
      audio_res << list.parameters[0].get_name
    when 205 # Set Move route
      list.parameters[1].list.each do |li|
        if li.code == 41 # Change character graphic
          graphics_res << "Graphics/Characters/" + li.parameters[0]
        elsif li.code == 44 # Play SE
          audio_res << li.parameters[0].get_name
        end
      end
    end
  end
end

#==============================================================================
# Record all used graphics & audio from maps
#==============================================================================
unless $BTEST

loading_bar.max = $data_mapinfos.size
loading_bar.text1 = "Retriving data from maps ...."

$data_mapinfos.each do |map_id, map|
  name = sprintf("Data/Map%03d.rvdata2", map_id)
  map = load_data(name)
  log = "Loading map ID : #{sprintf("Data/Map%03d.rvdata2", map_id)}" 
  puts log
  loading_bar.text2 = log
  loading_bar.current += 1
  Graphics.update
  
  # Record used graphics in map
  graphics_res << "Graphics/Battlebacks1/" + map.battleback1_name
  graphics_res << "Graphics/Battlebacks2/" + map.battleback2_name
  graphics_res << "Graphics/Parallaxes/" + map.parallax_name
  
  # Record used sound in map
  audio_res << map.bgm.get_name
  audio_res << map.bgs.get_name
  
  # Load all events
  map.events.each_value do |event|
    
    # Load all pages
    event.pages.each do |page|
      graphics_res << "Graphics/Characters/" + page.graphic.character_name
      
      # Load all event list
      page.list.each do |list|
        case list.code
        when 101 # Show Text
          graphics_res << "Graphics/Faces/" + list.parameters[0]
        when 231 # Show Pic
          graphics_res << "Graphics/Pictures/" + list.parameters[1]
        when 132, 133, 241, 245, 249, 250 # Audio Related event
          audio_res << list.parameters[0].get_name
        when 205 # Set Move route
          list.parameters[1].list.each do |li|
            if li.code == 41 # Change character graphic
              graphics_res << "Graphics/Characters/" + li.parameters[0]
            elsif li.code == 44 # Play SE
              audio_res << li.parameters[0].get_name
            end
          end
        end
      end
      
    end
  end
  
end 

end
#==============================================================================
# Data cleaning process
#==============================================================================

graphics_res.uniq! # Delete duplicated data
graphics_res.sort! # Sort data
graphics_res.delete_if {|g| !(g =~ /Graphics\/.+\/.+/i) } # Delete empty name

audio_res.uniq! # Delete duplicated data
audio_res.sort! # Sort data
audio_res.delete_if  {|a| !(a =~ /Audio\/.+\/.+/i) } # Delete empty name

#==============================================================================
# Create resource log file
#==============================================================================

File.open("#{Theo::ResLog::LogName}.txt", 'w') do |file|
  file.print "-----------------------------------------------\n"
  file.print "Last checked at : #{Time.now}\n\n"
  
  file.print "-----------------------------------------------\n"
  file.print " *) USED GRAPHIC RESOURCES : \n"
  file.print "-----------------------------------------------\n"
  graphics_res.each do |g|
    file.print("~> " + g + "\n")
  end
  
  file.print "\n"
  file.print "-----------------------------------------------\n"
  file.print " *) USED AUDIO RESOURCES : \n"
  file.print "-----------------------------------------------\n"
  audio_res.each do |a|
    file.print("~> " + a + "\n")
  end
end

puts "\nLog created in \"#{Theo::ResLog::LogName}.txt\""
loading_bar.text1 = "Log created in #{Theo::ResLog::LogName}.txt"
loading_bar.text2 = "Resource listing completed!"

Theo::ResLog::EndWait.times do
  Graphics.update
  Input.update
  break if Input.trigger?(:C) || Input.trigger?(:B)
end

#==============================================================================
# Perform checking each resource
#==============================================================================

if Theo::ResLog::Check

loading_bar.max = (graphics_res + audio_res).size
loading_bar.current = 0
loading_bar.text1 = "Performing check each resource ...."
missing = []
  
#------------------------------------------------------------------------------
# Graphic resources check
#------------------------------------------------------------------------------
graphics_res.each do |g|
  log = "Checking : #{g}"
  puts log
  loading_bar.current += 1
  loading_bar.text2 = log
  Graphics.update
  begin
    b = Bitmap.new(g)
    b.dispose
  rescue
    puts "Missing!"
    missing << g
    Theo::Reslog.write_missing(g)
    loading_bar.text1 = "Total Missing Resources : #{missing.size}"
  end
end

#------------------------------------------------------------------------------
# Audio resources check
#------------------------------------------------------------------------------
audio_res.each do |a|
  log = "Checking : #{a}"
  puts log
  loading_bar.current += 1
  loading_bar.text2 = log
  Graphics.update
  begin
    case a
    when /Audio\/BGM\/(.+)/i
      RPG::BGM.new($1.to_s, 0, 100).play
    when /Audio\/BGS\/(.+)/i
      RPG::BGS.new($1.to_s, 0, 100).play
    when /Audio\/ME\/(.+)/i
      RPG::ME.new($1.to_s, 0, 100).play
    when /Audio\/SE\/(.+)/i
      RPG::SE.new($1.to_s, 0, 100).play
    end
  rescue
    puts "Missing!"
    missing << a
    Theo::Reslog.write_missing(a)
    loading_bar.text1 = "Total Missing Resources : #{missing.size}"
  end
end

#==============================================================================
# Final Check!
#==============================================================================

if missing.empty?
  log = "\n\nResources check complete. You don't have any missing resources!"
  puts log
  loading_bar.text2 = log.gsub(/\n+/) {""}
else
  File.open("#{Theo::ResLog::MissName}.txt", 'w') do |file|
    file.print "----------------------------------------------------\n"
    file.print "Last checked at : #{Time.now}\n\n"
    file.print "----------------------------------------------------\n"
    file.print " *) MISSING RESOURCES : "
    file.print "----------------------------------------------------\n"
    missing.each do |miss|
      file.print(miss + "\n")
    end
    file.print "\n\n---------------------------------------------------\n"
  end
  log="\n\nResources check complete. Please check #{Theo::ResLog::MissName}.txt"
  puts log
  loading_bar.text2 = log.gsub(/\n+/) {""}
end

Theo::ResLog::EndWait.times do
  Graphics.update
  Input.update
  break if Input.trigger?(:C) || Input.trigger?(:B)
end

loading_bar.dispose

end # Theo::ResLog::Check

end # Theo::ResLog::Activate

#==============================================================================
# SKIP MISSING RESOURCES PART
#==============================================================================

if Theo::ResLog::MissingSkip

class << Theo::ResLog
  
  alias theo_reslog_missing write_missing
  def write_missing(path)
    @cache ||= []
    return if @cache.include?(path)
    theo_reslog_missing(path)
    File.open("#{Theo::ResLog::MissName}.txt", 'a') do |file|
      text = "Missing at Runtime. Checked at - #{Time.now} : " + path + "\n"
      file.print text
      msgbox "Missing at Runtime : " + path
    end
  end
  
end

class << Bitmap
  
  alias :theo_reslog_new :new
  def new(*args)
    begin
      return theo_reslog_new(*args)
    rescue
      if args[0].is_a?(String)
        Theo::ResLog.write_missing(args[0])
      end
      return theo_reslog_new(32,32)
    end
  end
  
end

class << Audio
  
  [:bgm, :bgs, :me, :se].each do |method_name|
    alias_method "theo_reslog_#{method_name}_play", "#{method_name}_play"
    eval "
    def #{method_name}_play(*args)
      begin
        theo_reslog_#{method_name}_play(*args)
      rescue
        Theo::ResLog.write_missing(args[0])
        return
      end
    end
    "
  end
  
end
  
end # Missing Skip
