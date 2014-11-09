#===============================================================================
# TheoAllen - Script Backtracer
# Version : 1.0
# Contact : www.theolized.com
#===============================================================================
# Change log :
# 2014.11.09 - Finished
#===============================================================================
# Perkenalan: 
#-------------------------------------------------------------------------------
# Script ini adalah untuk developer tool para scripter. Dimana kamu bisa 
# melakukan backtrace dari suatu method
#
#===============================================================================
# Cara penggunaan :
#-------------------------------------------------------------------------------
# Pasang script ini di atas main
# Untuk menggunakan backtracer, cukup kamu tuliskan 'backtrace' pada method
# yang ingin kamu inspect / periksa
#
# Script ini bukan untuk mereka yang bukan scripter
#===============================================================================

  OutputFile = 'Backtrace'
# File yang akan jadi backtrace log

  OpenFile = true
# Buka file setelah membuat log?

#===============================================================================
# End config
#===============================================================================
def backtrace
  regex = /\{(\d+)\}\:\d+\:in\s\S+/i
  array = caller.collect do |line|
    if line =~ regex
      name = $RGSS_SCRIPTS[$1.to_i][1]
      line.gsub(/\{\d+\}/) {"#{name} --- "}
    else
      line
    end
  end
  unless OutputFile.empty?
    filename = OutputFile + '.txt'
    File.open(filename, 'w') do |file|
      file.print "Created on : "
      file.print Time.now
      file.print "\n=================================================\n"
      array.each do |line|
        file.print line + "\n"
      end
    end
    if OpenFile
      system %{cmd /c "start #{filename}"}
    else
      puts "Script Backtrace log created in #{filename}"
    end
    return []
  end
  return array
end
