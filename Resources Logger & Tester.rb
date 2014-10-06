#==============================================================================
# TheoAllen - Resources Logger & Tester
# Version : 1.0
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
  ini juga membantu mencatat grafis mana aja yang ilang di dalam game kamu.
  Yang kamu lakukan adalah tinggal melihat log yang dihasilkan oleh script
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
    
    Activate  = true  # Aktivasi script ini? (true/false)
    Check     = true  # Mau sekalian tes apakah resors lagi ilang? (true/false)
    
  end
end

#==============================================================================
# Dibawah garis ini jangan disentuh :v
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

if Theo::ResLog::Activate && $TEST

DataManager.init
graphics_res = []  # Record graphics resources
audio_res = []     # Record audio resources

#==============================================================================
# Record all used graphics from database
#==============================================================================

# Mandatory graphics resources ~
graphics_res += ["Graphics/System/Iconset", "Graphics/System/Shadow", 
  "Graphics/System/Balloon", "Graphics/System/GameOver", 
  "Graphics/System/Window"]
  
# Used defined resources
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

# Vechile graphics
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
# Record all used graphics & audio from maps
#==============================================================================

$data_mapinfos.each do |map_id, map|
  map = load_data(sprintf("Data/Map%03d.rvdata2", map_id))
  puts "Loading map ID #{map_id}"
  Graphics.update
  
  # Record used graphics in map
  graphics_res << "Graphics/Battlebacks1/" + map.battleback1_name
  graphics_res << "Graphics/Battlebacks2/" + map.battleback2_name
  graphics_res << "Graphics/Parallaxes/" + map.parallax_name
  
  # Record used sound in map
  audio_res << map.bgm.get_name
  audio_res << map.bgs.get_name
  
  # Load all events
  map.events.each do |evid, event|
    
    # Load all pages
    event.pages.each_with_index do |page, page_index|
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

File.open('ResourceLog.txt', 'w') do |file|
  file.print "-----------------------------------------------\n"
  file.print "Last checked in : #{Time.now}\n\n"
  
  file.print "-----------------------------------------------\n"
  file.print " *) USED GRAPHIC RESOURCES : \n"
  file.print "-----------------------------------------------\n"
  graphics_res.each do |g|
    file.print(g + "\n")
  end
  
  file.print "\n"
  file.print "-----------------------------------------------\n"
  file.print " *) USED AUDIO RESOURCES : \n"
  file.print "-----------------------------------------------\n"
  audio_res.each do |a|
    file.print(a + "\n")
  end
end

puts "\nLog created in \"ResourceLog.txt\""

#==============================================================================
# Perform checking each resource
#==============================================================================

if Theo::ResLog::Check
missing = []
  
#------------------------------------------------------------------------------
# Graphic resources check
#------------------------------------------------------------------------------
graphics_res.each do |g|
  puts "Checking : #{g}"
  Graphics.update
  begin
    b = Bitmap.new(g)
    b.dispose
  rescue
    puts "Missing!"
    missing << g
  end
end

#------------------------------------------------------------------------------
# Audio resources check
#------------------------------------------------------------------------------
audio_res.each do |a|
  puts "Checking : #{a}"
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
  end
end

if missing.empty?
  puts "\n\nResource check complete. You don't have any missing resources!"
else
  File.open('MissingResources.txt', 'w') do |file|
    file.print "----------------------------------------------------\n"
    file.print "Last checked in : #{Time.now}\n\n"
    file.print "----------------------------------------------------\n"
    file.print " *) MISSING RESOURCES : "
    file.print "----------------------------------------------------\n"
    missing.each do |miss|
      file.print(miss + "\n")
    end
  end
  puts "\n\nResource check complete. Please check MissingResources.txt"
end

end # Theo::ResLog::Check

end # Theo::ResLog::Activate
