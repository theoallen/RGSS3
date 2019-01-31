#===============================================================================
# TheoAllen - Extra Event Code
#===============================================================================
#===============================================================================
# ** Game_Event
#===============================================================================
class Game_Character
  def creation_method
  end
end

class Game_Event
  Init_Start = /<init>/i
  Init_End = /<\/init>/i
  ParallelProc = /<parallel\s*:\s*(.+)>/i
  
  alias theo_parallel_exe_setup_page_settings setup_page_settings
  def setup_page_settings
    theo_parallel_exe_setup_page_settings
    load = false
    code = ""
    @parallel_method = []
    @list.each do |cmd|
      next unless [108, 408].include?(cmd.code)
      case cmd.parameters[0]
      when ParallelProc
        @parallel_method << $1.to_s
      when Init_Start
        load = true
        code = ""
      when Init_End
        load = false
      else
        next unless load
        code += cmd.parameters[0] + "\n"
      end
    end if @list
    eval(code)
  end
  
  alias theo_parallel_exe_update update
  def update
    theo_parallel_exe_update
    @parallel_method.each do
      method(@parallel_method).call
    end unless @interpreter
  end
  
end
