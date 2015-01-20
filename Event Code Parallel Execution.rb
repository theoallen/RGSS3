#===============================================================================
# TheoAllen - Event Code Parallel Execution
# Version : 1.0
# Language : English
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This script a merely made just for fun. Feel free to use if you found this 
# script. However, this script is provided as is. And I will likely not to
# provide much support
#
#===============================================================================
# *) Introduction :
#-------------------------------------------------------------------------------
# This script add function to execute a piece of code in parallel in character
# events. However, you need to know how to code properly in Ruby to use this
# script.
# 
#===============================================================================
# *) How to use :
#-------------------------------------------------------------------------------
# Installation : 
# Put the script below material but above main
#
# Usage :
# Put comments in event
#
# <parallel>
# script to execute
# </parallel>
#
# Replace the 'script to execute' with any valid ruby code. For example. This
# will make the RGSS Console prints Hello World!
#
# <parallel>
# puts "Hello World!"
# </parallel>
#
# The code will continue to execute. And you still allowed to trigger the event
# using action button or any trigger type.
# 
#-------------------------------------------------------------------------------
# Special thanks :
# - FenixFyreX for serialized proc
# - Enelvon for suggestion of using proc / lambda instead of eval
#===============================================================================

#===============================================================================
# ** Serializable_Lambda
#===============================================================================
class Serializable_Lambda
  attr_reader :code
  def initialize(str_code)
    @str_code = str_code
    @code = eval("lambda { #{str_code} }")
  end
  
  def marshal_dump
    [@str_code]
  end
  
  def marshal_load(obj)
    @str_code = obj[0]
    @code = eval("lambda { #{@str_code} }")
  end
  
end

#===============================================================================
# ** Game_Event
#===============================================================================
class Game_Event
  ParallelEXE_Start = /<parallel>/i
  ParallelEXE_End = /<\/parallel>/i
  
  alias theo_parallel_exe_setup_page_settings setup_page_settings
  def setup_page_settings
    theo_parallel_exe_setup_page_settings
    @parallel_exe = nil
    load = false
    code = ""
    @list.each do |cmd|
      next unless [108, 408].include?(cmd.code)
      case cmd.parameters[0]
      when ParallelEXE_Start
        load = true
        code = ""
      when ParallelEXE_End
        load = false
        @parallel_exe = Serializable_Lambda.new(code)
      else
        next unless load
        code += cmd.parameters[0] + "\n"
      end
    end if @list
  end
  
  alias theo_parallel_exe_update update
  def update
    theo_parallel_exe_update
    instance_exec(&@parallel_exe.code) if @parallel_exe
  end
  
end
