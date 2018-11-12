def attach_console
  # Get game window text
  console_w = Win32API.new('user32','GetForegroundWindow', 'V', 'L').call
  buf_len = Win32API.new('user32','GetWindowTextLength', 'L', 'I').call(console_w)
  str = ' ' * (buf_len + 1)
  Win32API.new('user32', 'GetWindowText', 'LPI', 'I').call(console_w , str, str.length)
  
  # Initiate console
  Win32API.new('kernel32.dll', 'AllocConsole', '', '').call
  Win32API.new('kernel32.dll', 'SetConsoleTitle', 'P', '').call('RGSS Console')
  $stdout.reopen('CONOUT$')
  
  # Sometimes pressing F12 will put the editor in focus first,
  # so we have to remove the program's name
  game_title = str.strip
  game_title.sub! ' - RPG Maker VX Ace', ''
  
  # Set game window to be foreground. This is purely for user convenience
  hwnd = Win32API.new('user32.dll', 'FindWindow', 'PP','N').call(0, game_title)
  Win32API.new('user32.dll', 'SetForegroundWindow', 'P', '').call(hwnd)
end

# Call this at the beginning
attach_console
