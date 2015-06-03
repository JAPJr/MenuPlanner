class Ingredient_list
  attr_reader :text
  def initialize (text)
    @text = text
  end
  
  def text_to_a
    lines = text.split(/\r?\n|\n/)
    the_array = []
    lines.each do |line|
      the_array << line.split(/\s?;\s?/)
    end
    the_array
  end   

  def clean_array(raw_array)
    new_array = []
    raw_array.each do |line|
      new_line = []
      line.each_with_index do |item, idx|
        new_line << item.gsub(/^\s+|\s+$/,"")	
      end
      if ((new_line.length ==1) and (new_line[0] != "")) or ((new_line.length == 2) and (new_line[1] != "")) then new_array << new_line end
    end
    new_array
  end

  def get_array  
    ingredient_array = text_to_a
    clean_array(ingredient_array)
  end
  
  def no_quantity
    ingredient_array = get_array
   list = ""
   ingredient_array[0..-2].each do |item|
    list << "#{item[1]}; "
  end
  list << "#{ingredient_array[-1][1]}."   
  end
end

  
  
class Ingredient_disp
  attr_reader :ingredient_array
  def initialize(ingredient_array)
    @ingredient_array = ingredient_array
  end
  
  def string_out
    lines = []
    quantity_length = 20
    ingredient_length = 50

    ingredient_array.each_with_index do |row, idx|
      q_length = row[0].length
      q_spaces = quantity_length - q_length
      i_length = row[1].length
      i_spaces = ingredient_length - i_length
    lines << "*  " + row[0] + " " * q_spaces + row[1] + " " * i_spaces
    end
    lines
  end
  
  def html_out
    list = ""
 #   quantity_length = 20
   ingredient_length = 50 
   lengths = []
   ingredient_array.each { |row| lengths << row[0].size }
   quantity_length = lengths.max + 3

    ingredient_array.each_with_index do |row, idx|
      q_length = row[0].length
      q_spaces = quantity_length - q_length
      i_length = row[1].length
      i_spaces = ingredient_length - i_length
    list << "&#8226  " + row[0] + " " * q_spaces + row[1] + " " * i_spaces + "<br>"
    end
    list
  end

end