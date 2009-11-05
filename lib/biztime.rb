class Time
  
  def offset_business_days(days)
    time = self.clone
    if days > 0
      days.times do |i|
        time += 1.days
        if time.wday == 0
          time += 1.days
        elsif time.wday == 6
          time += 2.days
        end
      end
    elsif days < 0
      days = days * -1
      days.times do |i|
        time -= 1.days
        if time.wday == 0
          time -= 2.days
        elsif time.wday == 6
          time -= 1.days
        end
      end
    end
    time
  end
  
  def to_batch_code
    day_chars = ['A', 'A', 'B', 'C', 'D', 'E', 'A']
    week = (self.strftime("%U").to_i + 1).to_s
    week = ('0' + week) if week.length == 1 
    self.strftime("%y") + 'R' + week + '-' + day_chars[self.wday]
  end
    
  
end