# =============================================================================
# TheoAllen - Story Journal
# Version : 1.1
# Contact : www.rpgmakerid.com (or) http://www.theolized.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||={})[:Theo_StoryJournal] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2014.10.21 - Now supported for encrypted project
#            - Added bitmap cache for faster drawing process
#            - Added journal number to support multi parties journal entry
#            - Added word wrap
# 2013.09.26 - Finished documentation
# 2013.09.25 - Finished script
# =============================================================================
=begin

  Perkenalan : 
  Script ini ngebikin kamu bisa nambahin jurnal sederhana pada game untuk
  keperluan cerita atau yang lain.
  
  ---------------------------------------------------------------------------
  Cara penggunaan :
  Pasang script ini dibawah material namun diatas main
  Buat file dengan nama Journal.txt di dalam folder Data
  Lalu tulis jurnal ceritanya disana. dengan format seperti berikut
  
  ---------------------
  [Title] Judul cerita
  Konten cerita Konten cerita Konten cerita Konten cerita Konten cerita 
  Konten cerita Konten cerita Konten cerita Konten cerita Konten cerita 
  Konten cerita Konten cerita Konten cerita Konten cerita Konten cerita 
  <P>Konten cerita Konten cerita Konten cerita Konten cerita Konten cerita 
  Konten cerita Konten cerita Konten cerita Konten cerita Konten cerita 
  Konten cerita Konten cerita Konten cerita Konten cerita Konten cerita 
  
  Gunakan <P> ato [page] buat misahin konten cerita pada page yg berbeda.
  Kamu juga bisa gunain escape character yang ada dalam message seperti
  \C[1], \N[1], \V[1] dst ...
  
  Contoh :
  ---------------------
  [Title] Lipsum
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean in ultrices 
  nulla, vel pharetra diam. Nunc faucibus pretium leo, a lacinia erat posuere 
  ut. Etiam porttitor enim et bibendum facilisis. Praesent eu elit ut metus 
  tempus aliquet. Cras tempor mauris sapien, ut laoreet quam condimentum ut. 
  <P>Aliquam aliquet ut quam vel sollicitudin. Fusce vestibulum semper sapien 
  nec luctus. Sed rhoncus, neque vitae
  
  ---------------------
  Untuk menambahkan dan mengurangi isi jurnal tinggal panggil script call
  berikut :
  - add_journal("title")
  - remove_journal("title")
  - clear_journal
  
  Jika di game kalian menggunakan multi party kalian bisa menyimpan dan
  mengosongkan isi jurnal dengan menggunakan script call
  
  - journal_number(n)
  
  Dimana n adalah angka. Nilai defaultnya adalah 1. Semisal kamu menggantinya
  dengan 2 di script call, maka jurnal akan kosong. Saat kamu menggantinya lagi
  menjadi 1, maka jurnal sebelumnya akan nongol
  
  Dimana title adalah judul dari konten cerita.
  Untuk masuk ke dalam journal, bisa dengan menggunakan script call
  - SceneManager.call(Story_Journal)
  
  ---------------------------------------------------------------------------
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

  Special Thanks :
  - Tsukihime buat artikel cara baca external file
  
=end
# =============================================================================
# Konfigurasi :
# =============================================================================
module Theo
  module Journal
  # --------------------------------------------------------------------------
  # Setting umum
  # --------------------------------------------------------------------------
    InstantRefresh  = true
  # Jika false, maka untuk mengganti isi konten cerita, player harus nekan
  # action button terlebih dahulu. Jika true, maka setiap ganti judul, konten
  # akan langsung diganti (ga paham? eksperimen aja sendiri)
    
    MainMenu        = true
  # Jika true, maka jurnal dapat dibuka di dalam main menu
  
    DisplayPage     = true
  # Bagi kalian-kalian yang ngga pengen nampilin page dalam journal, kalian
  # bisa ngisi ini dengan false
  
    WordWrap        = true
  # Opsi untuk membuat wrap word. Apa itu wrap word? sebuah opsi untuk membuat
  # teks kalian jika terlalu panjang akan secara otomatis dienter / membuat
  # baris baru
  
    ListWidth       = 200
  # Lebar window untuk list judul
  
  # --------------------------------------------------------------------------
  # Kosakata
  # --------------------------------------------------------------------------
    VocabPage     = "Page :"    # Kosakata untuk halaman
    VocabCommand  = "Journal"   # Kosakata untuk command yang ada di main menu
    
  end
end
# =============================================================================
# Akhir dari konfigurasi ~ !
# =============================================================================
class Game_Interpreter
  
  def add_journal(title)
    return if $game_system.journal_keys.include?(title)
    $game_system.journal_keys.push(title)
  end
  
  def clear_journal
    $game_system.journal_keys.clear
  end
  
  def remove_journal(title)
    $game_system.journal_keys.delete(title)
  end
  
  def journal_number(number)
    $game_system.journal_number = number
  end
  
end

# -----------------------------------------------------------------------------
# Updates version 1.1
# Window content caches
# -----------------------------------------------------------------------------
class << Cache
  
  def journal_cache(key, bmp)
    @journal ||= {}
    @journal[key] = Bitmap.new(bmp.width, bmp.height)
    @journal[key].blt(0,0,bmp,bmp.rect)
  end
  
  def journal_bmp(key)
    @journal ||= {}
    @journal[key]
  end
  
  def journal_clear
    @journal ||= {}
  end
  
end

class << Marshal
  alias theo_storyjournal_load load
  def load(port, proc = nil)
    theo_storyjournal_load(port, proc)  
  rescue TypeError
    if port.kind_of?(File)
      port.rewind 
      port.read
    else
      port
    end
  end
end 

class << DataManager
  
  def open_journal_text
    $journal = {}
    key = ""
    load_data("Data/Journal.txt").split(/[\r\n]+/).each do |txt|
      next if txt =~ /(^\s*(#|\/\/).*|^\s*$)/
      if txt =~ /^\[Title\]\s*(.+)/i
        key = $1.to_s
        $journal[key] = ""
      else
        txt.gsub!(/\[line\]/i) {"\n"}
        txt.gsub!(/\[page\]/i) {"<P>"}
        $journal[key] += txt
      end
    end
  end
  
  alias theo_storyjournal_load_db load_database
  def load_database
    open_journal_text
    theo_storyjournal_load_db
  end
  
end

class Game_System
  attr_accessor :journal_number
  
  alias theo_storyjournal_init initialize
  def initialize
    theo_storyjournal_init
    @journal_number = 0
    @journals = {}
  end
  
  def journal_keys
    @journals[@journal_number] ||= []
  end
  
  def journal_keys=(key)
    @journals[@journal_number] ||= [] 
    @journals[@journal_number] = key
  end
  
end

class Window_JournalList < Window_Selectable
  
  def initialize
    super(0,0,window_width,window_height)
    refresh
    activate
    select(0)
  end
  
  def title_window=(window)
    @title_window = window
    update_help
  end
  
  def window_width
    return Theo::Journal::ListWidth
  end
  
  def window_height
    return Graphics.height
  end
  
  def item_max
    return [$game_system.journal_keys.size,1].max
  end
  
  def draw_item(index)
    rect = item_rect(index)
    rect.x += 4
    draw_text(rect, $game_system.journal_keys[index])
  end
  
  def journal_contents
    $journal[journal_title] || ""
  end
  
  def journal_title
    $game_system.journal_keys[index] || ""
  end
  
  def update_help
    return unless Theo::Journal::InstantRefresh
    if @help_window
      @help_window.set_title(journal_title)
    end
    @title_window.set_title(journal_title) if @title_window
  end
  
end

class Window_JournalTitle < Window_Base
  
  def initialize(x)
    super(x,0,Graphics.width - x,fitting_height(1))
    set_title("")
  end
  
  def set_title(str)
    @title = str
    refresh
  end
  
  def refresh
    contents.clear
    draw_text(contents.rect,@title,1)
  end
  
end

class Window_JournalContents < Window_Base
  
  def initialize(xpos,ypos)
    super(xpos,ypos,Graphics.width - xpos, Graphics.height - ypos)
    @page = 0
    @texts = []
    @title = ""
  end
  
  def set_title(title)
    @title = title
    load_journal_data(journal_contents)
  end
  
  def journal_contents
    $journal[@title] || ""
  end
  
  def load_journal_data(str)
    @page = 0
    @texts = str.split(/<P>/i)
    refresh
  end
  
  def get_cache
    Cache.journal_bmp([@title, @page])
  end
  
  def set_cache
    Cache.journal_cache([@title, @page], contents)
  end
  
  def refresh
    contents.clear
    if get_cache
      draw_cached_bitmap
    else
      draw_contents
      draw_current_page if Theo::Journal::DisplayPage
      set_cache
    end
  end
  
  def draw_cached_bitmap
    begin
      contents.blt(0,0,get_cache, get_cache.rect)
    rescue
      Cache.journal_clear
      draw_contents
      draw_current_page if Theo::Journal::DisplayPage
      set_cache
    end
  end
  
  def draw_contents
    draw_text_ex(4,0,@texts[@page])
  end
  
  def draw_current_page
    reset_font_settings
    ypos = contents.height - line_height
    contents.fill_rect(0,ypos-2,contents.width,2,Color.new(255,255,255,128))
    rect = Rect.new(4,ypos,contents.width-4,line_height)
    pg = sprintf("%d / %d",@page+1,@texts.size)
    draw_text(rect,Theo::Journal::VocabPage)
    draw_text(rect,pg,2)
  end
  
  def update
    super
    next_page if Input.trigger?(:RIGHT)
    prev_page if Input.trigger?(:LEFT)
  end
  
  def next_page
    return if @page + 1 >= @texts.size
    @page += 1
    refresh
  end
  
  def prev_page
    return if @page + 1 <= 1
    @page -= 1
    refresh
  end
  
  def process_character(c, text, pos)
    @text = text
    if Theo::Journal::WordWrap && text[0] != ' '
      w = text_size(get_word(text)).width + 6
      if (pos[:x] + w) >= contents.width
        process_new_line(text, pos)
        return
      end
    end
    super
  end
  
  def get_word(text)
    result = ''
    text.each_char do |c|
      break if c =~ /\s/
      result += c
    end
    result
  end
  
end

class Window_MenuCommand < Window_Command
  
  alias theo_storyjournal_add_ori_cmd add_original_commands
  def add_original_commands
    theo_storyjournal_add_ori_cmd
    return unless Theo::Journal::MainMenu
    add_command(Theo::Journal::VocabCommand, :storyjournal)
  end
  
end

class Scene_Menu < Scene_MenuBase
  
  alias theo_storyjournal_cmnd_window create_command_window
  def create_command_window
    theo_storyjournal_cmnd_window
    @command_window.set_handler(:storyjournal, method(:enter_journal))
  end
  
  def enter_journal
    SceneManager.call(Story_Journal)
  end
  
end

class Story_Journal < Scene_MenuBase
  
  def start
    super
    create_journal_list
    create_journal_title
    create_journal_contents
  end
  
  def create_journal_list
    @list = Window_JournalList.new
    @list.set_handler(:ok, method(:on_journal_ok))
    @list.set_handler(:cancel, method(:return_scene))
  end
  
  def create_journal_title
    @title = Window_JournalTitle.new(@list.width)
    @title.set_title(@list.journal_title)
  end
  
  def create_journal_contents
    @contents = Window_JournalContents.new(@list.width,@title.height)
    @contents.load_journal_data(@list.journal_contents)
    @list.help_window = @contents
    @list.title_window = @title
  end
  
  def on_journal_ok
    @list.activate
    return if Theo::Journal::InstantRefresh
    @title.set_title(@list.journal_title)
    @contents.load_journal_data(@list.journal_contents)
  end
  
end
