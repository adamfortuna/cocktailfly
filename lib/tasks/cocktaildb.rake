require 'open-uri'


namespace :cocktaildb do
  namespace :load do

    task glasses: :environment do
      url = 'http://www.thecocktaildb.com/api/json/v1/1/list.php?g=list'
      content = URI(url).read
      glasses = JSON.parse(content)['drinks'].collect { |d| d['strGlass'] }
      puts glasses.length

      i = 0
      create_glasses = glasses.collect do |glass|
        unless glass.empty?
          i = i + 1
          <<-CYPHER.strip_heredoc
          (glass#{i}:Glass {uuid: '#{glass.parameterize}', name: "#{glass.gsub('"',  '\"')}" })
          CYPHER
        end
      end.compact

      cypher = <<-SQL
        CREATE #{create_glasses.join(',')}
      SQL

      puts cypher
      Neo4j::Session.query(cypher)
    end

    task ingredients: :environment do
      url = 'http://www.thecocktaildb.com/api/json/v1/1/list.php?i=list'
      content = URI(url).read
      ingredients = JSON.parse(content)['drinks'].collect { |d| d['strIngredient1'] }
      puts ingredients.length

      i = 0
      create_ingredients = ingredients.collect do |ingredient|
        unless ingredient.empty?
          i = i + 1
          <<-CYPHER.strip_heredoc
          (ingredient#{i}:Ingredient {uuid: '#{ingredient.parameterize}', name: "#{ingredient.gsub('"',  '\"')}" })
          CYPHER
        end
      end.compact

      cypher = <<-SQL
        CREATE #{create_ingredients.join(',')}
      SQL

      puts cypher
      Neo4j::Session.query(cypher)
    end

    task cocktails: :environment do
      cocktails = []

      glass_urls = Glass.all.collect do |glass|
        "http://www.thecocktaildb.com/api/json/v1/1/filter.php?g=#{CGI.escape(glass.name)}"
      end

      ingredient_urls = Ingredient.all.collect do |ingredient|
        "http://www.thecocktaildb.com/api/json/v1/1/filter.php?i=#{CGI.escape(ingredient.name)}"
      end

      urls = [
        'http://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Alcoholic',
        'http://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Non_Alcoholic',
        'http://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Optional_alcohol',
        'http://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Ordinary_Drink',
        'http://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Cocktail',
        'http://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Shot',
        'http://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Beer',
        'http://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Punch_/_Party_Drink',
        'http://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Homemade_Liqueur',
        'http://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Other/Unknown'
      ] + ingredient_urls + glass_urls

      urls.compact!

      puts "Checking #{urls.length} urls"
      urls[21..100].each do |url|
        puts "Loading #{url}..."
        content = URI(url).read
        drinks = JSON.parse(content)['drinks']
        drinks.collect do |drink|
          drink_name = drink['strDrink']
          if drink_name
            cypher = <<-CYPHER.strip_heredoc
              MATCH (Cocktail { uuid: '#{drink_name.parameterize}' })
              CREATE UNIQUE (cocktail:Cocktail {name: "#{drink_name.gsub('"','\"')}", thecocktaildb_id: #{drink['idDrink']} })
            CYPHER
            puts cypher
            Neo4j::Session.query(cypher)
          end
        end
      end
    end
  end
end
