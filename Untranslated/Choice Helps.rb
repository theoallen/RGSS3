# =============================================================================
# TheoAllen - Choice Helps
# Version : 1.0
# Contact : Discord @ Theo#3034
# =============================================================================
($imported ||= {})[:Theo_ChoiceHelp] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.11.14 - Finished script
# =============================================================================
=begin

  ----------------------------------------------------------------------------
  Perkenalan :
  Script ini membuat kamu bisa menampilkan help pada choice.
  
  ----------------------------------------------------------------------------
  Cara penggunaan :
  Pasang script ini dibawah material namun diatas main
  Gunakan script call seperti berikut untuk menentukan helpnya
  
  choice_helps[0] = "blablabla"
  choice_helps[1] = "dasdasdasd"
  choice_helps[2] = "lorem ipsum"
  choice_helps[3] = "another sample text"
  
  Letakkan script call diatas satu slot tepat diatas show text sebelum command 
  choice. Index choice dimulai dari 0. Jika ada 4 choice, maka masing2 indexnya 
  adalah 0-1-2-3
  
  Jangan lupa untuk membersihkan sisa-sisa help dengan script call seperti
  ini di akhir choice (kecuali kamu set AutoClear ke true)
  
  $game_message.clear_helps
  
  ----------------------------------------------------------------------------
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.

=end
# =============================================================================
# Sedikit Konfigurasi
# =============================================================================
module Theo
  module Choice
    
    AutoClear = true
  # Buat bersihin sisa-sisa help. (rekomendasi : true)
  
    LineNumber = 1
  # Jumlah baris dalam help window
  
  end
end
# =============================================================================
# Akhir dari konfigurasi
# =============================================================================
class Game_Interpreter
  # --------------------------------------------------------------------------
  # Script call
  # --------------------------------------------------------------------------
  def choice_helps
    $game_message.choice_helps
  end
  
end

class Game_Message
  attr_reader :choice_helps
  
  alias theo_choiceh_init initialize
  def initialize
    theo_choiceh_init
    clear_helps
  end
  
  def clear_helps
    @choice_helps = []
  end
end

class Window_ChoiceHelp < Window_Help
  
  def initialize(msg_window, choice_window)
    super(Theo::Choice::LineNumber)
    @msg_window = msg_window
    @choice_window = choice_window
    @choice_window.help_window = self
    self.openness = 0
    update
  end
  
  def update
    super
    update_placement
    update_openness
    update_visible
  end
  
  def update_placement
    self.y = 0 if @msg_window.y > 0
    self.y = Graphics.height - height if @msg_window.y <= 0
  end
  
  def update_openness
    self.openness = @choice_window.openness unless vx_choice?
  end
  
  def update_visible
    self.visible = !$game_message.choice_helps.compact.empty?
  end
  
  def choice_window=(window)
    @choice_window = window
    @choice_window.help_window = self
  end
  
  def vx_choice?
    $imported[:Theo_VXStyleChoices] && $game_message.vx_choice
  end
  
end

class Window_ChoiceList < Window_Command
  
  def update_help
    @help_window.set_text($game_message.choice_helps[index])
  end
  
  alias theo_choiceh_call_ok call_ok_handler
  def call_ok_handler
    theo_choiceh_call_ok
    clear_helps
  end
  
  alias theo_choiceh_call_cancel call_cancel_handler
  def call_cancel_handler
    theo_choiceh_call_cancel
    clear_helps
  end
  
  def clear_helps
    return unless Theo::Choice::AutoClear
    $game_message.clear_helps
  end
  
end

class Window_Message < Window_Base
  
  alias theo_choiceh_init initialize
  def initialize
    theo_choiceh_init
    create_choice_help
  end
  
  def create_choice_help
    @choice_help = Window_ChoiceHelp.new(self, @choice_window)
  end
  
  alias theo_choiceh_update update
  def update
    theo_choiceh_update
    @choice_help.update
  end
  
  alias theo_choiceh_dispose_all dispose_all_windows
  def dispose_all_windows
    theo_choiceh_dispose_all
    @choice_help.dispose
  end
  
  if $imported[:Theo_MessageBallon]
  alias theo_choiceh_recreate_choice recreate_choice
  def recreate_choice
    theo_choiceh_recreate_choice
    @choice_help.choice_window = @choice_window
  end
  end
  
end
