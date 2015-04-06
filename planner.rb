require 'sinatra'
require 'data_mapper'
require 'dm-noisy-failures'
require './functions'
require 'redcloth'

DataMapper.setup :default, "sqlite://#{Dir.pwd}/menu.db"
	
class Recipe
  include DataMapper::Resource

  property :id			, Serial
  property :contributor	, String
  property :name		, String
  property :meal		, String
  property :dish			, String
  property :veg			, String
  property :ingredients	, Text
  property :instructions	, Text
end

DataMapper.finalize.auto_upgrade!


get '/' do
  erb :home
end

get '/search' do
  erb:search
end


get '/list' do
   class List
     attr_reader :list, :items
     def initialize (list)
       @list = list
     end
     
     def to_a
       list_array = list.split(/,|;/)    
     end
     
     def items
       items = to_a.map {|item| item.gsub(/(^ +)|( +$)/,"")}
     end
     
     def text
       if items.length == 1 then
         from_list = items[0]
       else
         form_list = items[0..-2].join(", ") << ", and " << items[-1]	    
       end     
     end
   end


   @recipes = Recipe.all
   @ids = []
   @recipes.each do |recipe|
   	@ids << recipe.id
   end
   
   eliminate_ids = []
 puts "All parameters are:"
 puts params
 
   if  !(params[:keywords].empty?) then 
       @key_array = List.new(params[:keywords]).to_a
       @ids.each do |idx|
            rid = true
            @key_array.each do |word|
                  if @recipes.get(idx).name =~/#{word}/i then rid = false end
             end
	     if rid then eliminate_ids << idx  end
       end
       @ids -= eliminate_ids
  end
  puts "Raw ingredient list is: #{params[:ingredients]}."

   if  !(params[:ingredients].empty?) then 
       @ingredient_array = List.new(params[:ingredients]).to_a
       @ids.each do |idx|
            rid = true
            @ingredient_array.each do |item|
                  if @recipes.get(idx).ingredients =~/#{item}/i then rid = false end
             end
	     if rid then eliminate_ids << idx  end
       end
       @ids -= eliminate_ids
  end

   if params[:meal].length > 1 then
        @ids.each do |idx|
		meals = @recipes.get(idx).meal
		puts "For index #{idx} meal is: #{meals}."
		if meals then
			puts "There are meals specified."
			if params[:meal][0] == "any" then
			     rid = true
			     params[:meal][1..-1].each do |type|
				     if meals.include?(type) then rid = false end
			     end
			else
				rid = false
				params[:meal][1..-1].each do |type|
				     if !(meals.include?(type)) then rid = true end
				end
			end
		else     
			puts "There are no meals specified."
			rid = true
		end
	       puts "Rid is #{rid}."
	       if rid then eliminate_ids << idx end
       end
       @ids -= eliminate_ids
  end



   if params[:dish].length > 1 then
       @ids.each do |idx|
	     dishes = @recipes.get(idx).dish
	     if dishes then
	          if params[:dish][0] =="any" then
	              rid =true
	              params[:dish][1..-1].each do |type|
	                   if dishes.include?(type) then rid = false end
	              end
	          else
	              rid = false
	              params[:dish][1..-1].each do |type|
	                  if !(dishes.include?(type)) then rid = true end
	              end
	          end
	     else
		     rid = true
	     end
	     if rid then eliminate_ids << idx end
       end
       @ids -= eliminate_ids
	puts
        puts "Remaining ids after checking dish type are: #{@ids}" 
  end


  puts "Vegetarian is #{params[:veg]}"    
  if params[:veg] == "yes" then
        @ids.each do |idx|
	    puts "For index = #{idx} veg is #{@recipes.get(idx).veg}"
	    if !@recipes.get(idx).veg | !(@recipes.get(idx).veg=="yes") then eliminate_ids << idx end
        end
           @ids -= eliminate_ids
	    puts
            puts "Remaining ids after checking for vegetarian are: #{@ids}"
  end


	



   erb :list

end


get '/add' do
	erb :add
end

post '/add' do
  r= Recipe.new
  r.name = params[:name]
  r.contributor = params[:contributor]
  r.meal= params[:meal]
  r.dish = params[:dish]
  r.veg = params[:vegetarian]
  r.ingredients = params[:ingredients]
  r.instructions = params[:instructions]
  r.save
  redirect '/'
end

get '/view/:id' do
#   @id = 7 
   @id = params[:id]
   text = Recipe.get(@id).ingredients
   i_list = Ingredient_list.new(text).get_array 
   @ingredient_block= Ingredient_disp.new(i_list).html_out
   puts
   puts "***************************************"
   puts Recipe.get(@id).instructions
   puts"***************************************"
   erb :view
end   

get '/auth_del/:id' do
  @recipe_to_delete = params[:id]
  @auth_msg = ""
  erb :auth_del
end

get '/view_all' do
      @recipes = Recipe.all
      erb :view_all
end
 
delete '/:id' do
  if  params[:pword] == "chiral" then
    Recipe.get(params[:id]).destroy
    @auth_msg = ""
    redirect '/'
  else
    @auth_msg = "Password incorrect.  Re-enter or return to recipe using button below."
    @recipe_to_delete = params[:id]
    erb :auth_del
 #   redirect '/fail'
  end
end	

get '/fail' do
  erb :fail_msg
end

get '/redcloth' do
	erb :RedCloth
end

get '/:id' do
  @recipe_to_edit = params[:id]
#  puts "Recipe to edit is #{@recipe_to_edit} in get id"
#  "<h1>The id is #{@recipe_to_edit}</h1> and the name of the recipe is #{Recipe.get(@recipe_to_edit).name}."
  
  erb :edit
end




