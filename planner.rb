require 'sinatra'
require 'data_mapper'
require 'dm-noisy-failures'
require './functions'
require 'redcloth'
require 'dm-postgres-adapter'

#DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/menu.db")
DataMapper::Logger.new($stdout, :debug)
DataMapper::setup(:default, "postgres://john:mangia@localhost/menu.db")
	
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

        home_form = <<HERE
	<form method="link" action="/">
               <input type="submit" value="Home" style="display:inline; float:left; width:80px; height:25px; font-size:12px; margin:0px 20px">
	</form>
HERE

search_form  = <<HERE
          <form method="link" action="/search">
               <input type="submit" value="Search" style="display:inline; float:left; width:80px; height:25px; font-size:12px; margin:0px 20px">
	</form>
HERE

add_form = <<HERE
          <form method="link" action="/add">
               <input type="submit" value="Add" style="display:inline; float:left; width:80px; height:25px; font-size:12px; margin:0px 20px">
	</form>
HERE

get '/' do
  @nav_forms = []
  @nav_forms << search_form << add_form
  erb :home
end

get '/search' do
  @nav_forms = []
  @nav_forms << home_form << add_form
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

  @nav_forms = []
  @nav_forms << home_form << search_form << add_form

   @recipes = Recipe.all
   @ids = []
   @recipes.each do |recipe|
   	@ids << recipe.id
   end
   
   eliminate_ids = []

 
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
		if meals then
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
			rid = true
		end
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
  end

   
  if params[:veg] == "yes" then
        @ids.each do |idx|
	    if !@recipes.get(idx).veg | !(@recipes.get(idx).veg=="yes") then eliminate_ids << idx end
        end
           @ids -= eliminate_ids
  end
	
  erb :list

end


get '/add' do
  @nav_forms = []
  @nav_forms << home_form << search_form
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
  @nav_forms = []
  @nav_forms << home_form << search_form << add_form
   @id = params[:id]
   text = Recipe.get(@id).ingredients
   i_list = Ingredient_list.new(text).get_array 
   @ingredient_block= Ingredient_disp.new(i_list).html_out
   erb :view
end   

get '/auth_del/:id' do
  @nav_forms = []
  @nav_forms << home_form << search_form << add_form
  @recipe_to_delete = params[:id]
  @auth_msg = ""
  erb :auth_del
end

get '/view_all' do
      @recipes = Recipe.all
      erb :view_all
end
 
delete '/:id' do
  @nav_forms = []
  @nav_forms << home_form << search_form << add_form
  if  params[:pword] == "chiral" then
    Recipe.get(params[:id]).destroy
    @auth_msg = ""
    redirect '/'
  else
    @auth_msg = "Password incorrect.  Re-enter or return to recipe using button below."
    @recipe_to_delete = params[:id]
    erb :auth_del
  end
end	

get '/fail' do
  erb :fail_msg
end

get '/redcloth' do
	erb :RedCloth
end

get '/:id' do
	"Edit has  been requested"
  @nav_forms = []
  @nav_forms << home_form << search_form << add_form
  @recipe_to_edit = params[:id]
  
  erb :edit
end


put '/:id' do

=begin
  @nav_forms = []
  @nav_forms  << home_form << search_form << add_form
  erb  "<div style='height:50px'></div>About to save edited recipe.  The new instructions are: <%=params[:instructions]%>."
=end
  r = Recipe.get params[:id]
  r.contributor = params[:contributor]
  r.name = params[:name]
  r.meal = params[:meal]
  r.dish = params[:dish]
  r.veg = params[:veg]
  r.ingredients = params[:ingredients]
  r.instructions = params[:instructions]
  r.save
  redirect '/'

end



