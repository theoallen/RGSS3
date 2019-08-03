#===============================================================================
# TheoAllen - Extra Event Code Plus Plus
#===============================================================================
# <init>
# ...Script...
# </init>
# Script that will be executed once per event page switch
#
# <parallel: method_name>
# Script that will be execute parallel, using the method name
#===============================================================================
# ** Game_Event
#===============================================================================
class Game_Event
  ParallelEXE_Start = /<init>/i
  ParallelEXE_End = /<\/init>/i
  InitMethod  = /<init\s*:\s*(.+)>/i
  CreateREGEX = /<create\s*:\s*(.+)>/i
  ParallelProc = /<parallel\s*:\s*(.+)>/i
  
  alias theo_parallel_exe_setup_page_settings setup_page_settings
  def setup_page_settings
    theo_parallel_exe_setup_page_settings
    load = false
    code = ""
    @parallel_method = nil
    @list.each do |cmd|
      next unless [108, 408].include?(cmd.code)
      case cmd.parameters[0]
      when InitMethod
        method($1.to_s).call
      when ParallelProc
        @parallel_method = $1.to_s
      when ParallelEXE_Start
        load = true
        code = ""
      when ParallelEXE_End
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
    method(@parallel_method).call if @parallel_method && !@interpreter
  end
  
end
