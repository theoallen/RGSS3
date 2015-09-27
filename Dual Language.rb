#==============================================================================
# TheoAllen - Dual Language
# Version : 1.0b
# Language : Informal Indonesian
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://www.theolized.com
#==============================================================================
($imported ||= {})[:Theo_DualLanguage] = true
#==============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2015.09.27 - Fixed silly bug that couldn't export text
# 2013.10.27 - Finished
#==============================================================================
=begin

  =================
  || Perkenalan ||
  -----------------
  Pernah kepikiran untuk membuat game RM jadi dual language? Namun jika kamu
  make switch, maka itu bakal kebanyakan. Lalu bagaimana solusinya? Script
  ini bisa membantumu
  
  Dianjurkan memakai script ini jika project kalian sudah benar-benar fix dan
  tidak ada perubahan dialog lagi. Karena jika dialog masih berubah terus, 
  bisa jadi kamu akan kesusahan
  
  ======================
  || Cara penggunaan ||
  ----------------------
  Pasang script ini di bawah material namun diatas main.
  
  Langkah-langkah :
  0)  Script ini menggunakan external file berupa file .csv (cek google atau
      yang lainnya kalo ga ngerti). Untuk itu, kamu harus mempersiapkannya 
      terlebih dahulu. Ini penting karena digunakan untuk switching bahasa.
      
  1)  Masuk ke konfigurasi. Set 'ExportText' ke true.
  
  2)  Set sekalian 'ExitOnFinish' ke true.
  
  3)  Set 'ExportedDir' untuk tempat nama folder sebagai text yang akan 
      diekspor. Misalnya kamu set 'ExportedText'.
      
  4)  Jalankan game lewat playtest. Jangan lupa nyalain console di 
      Game > Show Console untuk melihat proses.
      
  5)  Gamemu akan langsung keclose begitu selesai.
  
  6)  Sekarang buka folder 'ExportedText' atau apa nama yang kamu masukkan tadi.
  
  7)  Disana kamu akan menemukan file-file format csv dengan nama seperti 
      1-1-0.csv, 20-3-4.csv dan sebagainya.
      
  8)  Format nama file tersebut adalah berdasarkan format seperti ini.
      #{map_id}-#{event_id}-#{page_index}. Jangan pernah diubah nama file-file
      tersebut.
    
  9)  Buat folder baru untuk menyimpan teks yang nantinya akan di translate di
      folder game kamu. Nama folder harus sama dengan apa yang ada di 'TextDir'
      di konfigurasi bawah
  
  10) Copy paste semua teks hasil export ke folder baru tersebut
  
  11) Buka file-file itu, dianjurkan dengan excel. 
  
  12) Kamu akan melihat isi file dengan format seperti ini
      [nomor | Tulisan teks]
      [1 | Halo tuan, apa kabar?]
      
      Dan sebagainya ....
      Nomor tersebut menunjukkan urutan index teks di barisan event. Dari yang 
      paling atas adalah bernilai 0 dan seterusnya. Simplenya... nomor jangan 
      diubah! Kecuali kalian ngerti konsepnya <(")
  
  13) Yang perlu kalian ubah adalah tulisan teks disana
  
  14) Setelah semua diubah dan di save, set 'ExportText' ke false. Jangan lupa
      tentukan switch yang akan kalian pakai untuk mengubah bahasa (dengan
      asumsi kalian udah ngerti dasar switch)
      
  15) Jalankan game... nyalakan switch, dan lihat hasilnya
  
  ===================
  || Terms of use ||
  -------------------
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.
  

=end
#==============================================================================
# Konfigurasi :
#==============================================================================
module Theo
  module DualLang
    
    ExportText    = false
    ExitOnFinish  = true
    ExportedDir   = 'ExportedText'
    
    TextDir   = 'Texts'
    Switch_ID = 15
    
  end
end

#==============================================================================
# Akhir dari konfigurasi
#==============================================================================
# Compatibility Info :
#   Aliased method
#   - Game_Interpreter ~ setup (added new parameter)
#
#   Overwritten methods
#   - Game_Interpreter ~ marshal_dump
#   - Game_Interpreter ~ marshal_load
#   - Game_Interpreter ~ command_101
#   - Game_Map ~ setup_starting_map_event
#==============================================================================
# Exporting text part
#==============================================================================
if Theo::DualLang::ExportText && !$BTEST
  
unless Dir.exist?(Theo::DualLang::ExportedDir)
  Dir.mkdir(Theo::DualLang::ExportedDir)
end
#------------------------------------------------------------------------------
# load all maps
#------------------------------------------------------------------------------
load_data("Data/MapInfos.rvdata2").each do |map_id, map|
  map = load_data(sprintf("Data/Map%03d.rvdata2", map_id))
  puts "Loading map ID #{map_id}"
  Graphics.update
  
#----------------------------------------------------------------------------
# Load all events
  map.events.each do |evid, event|
  #--------------------------------------------------------------------------
  # Load all pages
    event.pages.each_with_index do |page, page_index|
    #------------------------------------------------------------------------
    # Load all event list
      texts = []
      page.list.each_with_index do |list, index|
        if list.code == 401 # Text data
          texts << "#{index};#{list.parameters[0]}"
        elsif list.code == 102 # Show choice
          texts << "#{index};#{list.parameters}"
        end
      end
      unless texts.empty?
        result = texts.join("\n")
        n = "#{Theo::DualLang::ExportedDir}/#{map_id}-#{evid}-#{page_index}.csv"
        File.open(n, 'w') do |f|
          f.print(result)
        end
        puts "file created : #{n}"
        Graphics.update
      end
    end
  end
  
end 

exit if Theo::DualLang::ExitOnFinish

end # Theo::DualLang::ExportText

unless Dir.exist?(Theo::DualLang::TextDir)
  Dir.mkdir(Theo::DualLang::TextDir)
end

#==============================================================================
# * 
#==============================================================================

module MsgCache
  class << self
    def init
      @caches = {}
    end
    
    def cache(map_id, event_id, page_index)
      key = [map_id, event_id, page_index]
      return @caches[key] if @caches[key]
      cache_val = {}
      n = "#{Theo::DualLang::TextDir}/#{map_id}-#{event_id}-#{page_index}.csv"
      File.open(n).each_line do |line|
        arr = line.split(/[\n;]/)
        cache_val[arr[0].to_i] = arr[1]
      end
      @caches[key] = cache_val
      return @caches[key]
    end
    
  end
end

MsgCache.init

#==============================================================================
# * Game_Interpreter
#==============================================================================

class Game_Interpreter
  
  alias dualang_setup setup
  def setup(map_id, event_id = 0, page_index = -1)
    dualang_setup(map_id, event_id)
    @page_index = page_index
  end
  
  # Overwrite marshal dump
  def marshal_dump
    [@depth, @map_id, @event_id, @list, @index + 1, @branch, @page_index]
  end
  
  # Overwrite marshal load
  def marshal_load(obj)
    @depth, @map_id, @event_id, @list, @index, @branch, @page_index = obj
    create_fiber
  end
  
  # Overwrite command 101
  def command_101
    wait_for_message
    $game_message.face_name = @params[0]
    $game_message.face_index = @params[1]
    $game_message.background = @params[2]
    $game_message.position = @params[3]
    while next_event_code == 401       # Text data
      @index += 1
      if @page_index > -1 && $game_switches[Theo::DualLang::Switch_ID]
        text = MsgCache.cache(@map_id, @event_id, @page_index)[@index]
        text = @list[@index].parameters[0] if text.nil?
      else
        text = @list[@index].parameters[0]
      end
      $game_message.add(text)
    end
    case next_event_code
    when 102  # Show Choices
      @index += 1
      if @page_index > -1 && $game_switches[Theo::DualLang::Switch_ID]
        cache = MsgCache.cache(@map_id, @event_id, @page_index)[@index]
        cache =~ /\[\[(.+)\],\s*(\d+)\]/i
        arr = $1.to_s.gsub(/"/) {""}.split(', ')
        type = $2.to_i
        choice = [arr, type]
      else
        choice = @list[@index].parameters
      end
      setup_choices(choice)
    when 103  # Input Number
      @index += 1
      setup_num_input(@list[@index].parameters)
    when 104  # Select Item
      @index += 1
      setup_item_choice(@list[@index].parameters)
    end
    wait_for_message
  end
  
end

#==============================================================================
# * Game_Map
#==============================================================================

class Game_Map
  
  # Overwrite setup starting map event
  def setup_starting_map_event
    event = @events.values.find {|event| event.starting }
    event.clear_starting_flag if event
    @interpreter.setup(event.list, event.id, event.page_index) if event
    event
  end
  
end

#==============================================================================
# * Game_Event
#==============================================================================

class Game_Event
  
  def page_index
    @event.pages.index(@page)
  end
  
end
