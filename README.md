#Menu Planner#

*Menu Planner* is a web app, created using Sinatra, which stores cooking recipes and attributes in a database, which is maintained using *DataMapper*. 
Required gems are *sinatra*, *data_mapper*, and *redcloth*.
  
Using the web app, the data base can be searched by: recipe name keywords, ingredients, meal type, or any combination of the preceding items. A list of 
recipe names, and required ingredients for each, which satisfy the search criteria, is then displayed.   A recipe in the generated list can then be selected for 
view or editing.  Recipes are easily added by filling out and submitting a form.