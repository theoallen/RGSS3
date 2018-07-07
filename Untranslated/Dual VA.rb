module ED
  module Dual_VA
    
  Stella_Quotes = [
  ["Actor28_ex",3,"Haha... Maaf...","true"],
  ["Actor28_ex",3,"Kalian lihat? Kalian lihat aku menembakkan" +
    "\ntiga peluru sekali tembak?","true"],
  ["Actor28_ex",3,"Ha. Kena kau!","true"],
  ["",4,"Fuuhh.... Tadi itu hampir saja...","hp_rate <= 0.5"],
  ["",7,"Fuh. Merusak rambutku saja...","true"],
  ["",1,"Sudah kubilang kan kalian?, \nmenunduk!","true"],
  ["",7,"Jadi, kalian mau menantang \npenembak jitu sepertiku?", "true"],
  ]
  
  # --------------------------------------------------------------------------
  
  Stella_Level = [
  ["Actor28_ex",3,"Tembakanku semakin keren...","true"],
  ]
  
  # --------------------------------------------------------------------------
  
  Stella_Drops = [
  ["",1,"Ini milikku!!","true"],
  ["Actor28_ex",3,"Hei! lihat, emas!","true"],
  ["Actor28_ex",3,"Wah... Health Potion!",
    "$game_temp.drops.include?($data_items[1])"],
  ["Actor28_ex",2,"Wow! Kita dapat sebanyak ini!",
    "$game_temp.drops.size > 2"],
  ]
  
  # --------------------------------------------------------------------------
  
  Lunar_Quotes = [
  ["",0,"Kau sepuluh tahun lebih cepat untuk \nmenantangku.","hp_rate > 0.5"],
  ["",7,"Sihirku tadi... keren kan?","true"],
  ["",5,"Siapa saja yang membuat tempat ini, dia \npasti orang gila...",
    "hp_rate <= 0.45"],
  ["",3,"Untungnya aku ada disini...","true"],
  ]
  
  Lunar_Level = [
  ["",7,"Pengalaman adalah guru yang terbaik.","true"],
  ]
  
  Lunar_Drops = [
  ["",3,"Lekas ambil barangnya,...","true"],
  ["",7,"Health Potion,\\. boleh juga",
    "$game_temp.drops.include?($data_items[1])"],
  ]
  
  # --------------------------------------------------------------------------
  
  Soleil_Quotes = [
  ["Actor63_ex",0,"Haha. Boleh juga!","true"],
  ["Actor63_ex",4,"Woi, Stella.\. hati-hati dong kalau mau \nmenembak","true"],
  ["Actor63_ex",6,"Hah, cuman seperti itu saja?","$game_troop.turn_count <= 2"],
  ["Actor63_ex",3,"Aku sudah terbiasa dengan dungeon \nseperti ini.",
    "true"],
  ["",1,"Hei, Lunar! Obati aku juga!","hp_rate <= 0.5"],
  ["",1,"Ayo! siapa berikutnya?!","hp_rate > 0.5"],
  ["",0,"Boleh juga....","true"],
  ["",7,"Pertarungan yang bagus....","true"],
  ]
  
  Soleil_Level = [
  ["",7,"Semakin menarik saja tempat \nini.","true"],
  ["",7,"Semakin dalam kita masuk, semakin, \n'greget' rasanya...",
    "$game_switches[11]"]
  ]
  
  Soleil_Drops = [
  ["",3,"Diam! Biar aku saja yang ambil.","true"],
  ["",7,"Yah, boleh juga lah...","true"],
  ["",6,"Yah\\..\\..\\.. tidak dapat apa-apa.",
    "$game_temp.drops.empty?"],
  ["Actor63_ex",2,"Nah, ini namanya barang jarahan!",
    "$game_temp.drops.size >= 2"],
  ]
  
  end
end

class Game_Actor < Game_Battler
  
  def tlz_win_quotes
    if $game_switches[15]
      ary = eval("ED::Dual_VA::#{actor.tlz_win}").select do |quote|
        eval(quote[3]) 
      end
      return ary[rand(ary.size)]
    end
    ary = eval("TLZ::#{actor.tlz_win}").select do |quote|
      eval(quote[3]) 
    end
    return ary[rand(ary.size)]
  end
  
  def tlz_level_quotes
    if $game_switches[15]
      ary = eval("ED::Dual_VA::#{actor.tlz_level}").select do |quote|
        eval(quote[3]) 
      end
      return ary[rand(ary.size)]
    end
    ary = eval("TLZ::#{actor.tlz_level}").select do |quote|
      eval(quote[3]) 
    end
    return ary[rand(ary.size)]
  end
  
  def tlz_drops_quotes
    if $game_switches[15]
      ary = eval("ED::Dual_VA::#{actor.tlz_drops}").select do |quote|
        eval(quote[3]) 
      end
      return ary[rand(ary.size)]
    end
    ary = eval("TLZ::#{actor.tlz_drops}").select do |quote|
      eval(quote[3]) 
    end
    return ary[rand(ary.size)]
  end
  
end
