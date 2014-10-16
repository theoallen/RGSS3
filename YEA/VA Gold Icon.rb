class Window_VictorySpoils
  IconGold = 365
  
  def draw_gold(rect)
    text = Vocab.currency_unit
    draw_icon(IconGold, 4, 0)
    draw_currency_value(@gold, text, rect.x, rect.y, rect.width)
  end
  
end
