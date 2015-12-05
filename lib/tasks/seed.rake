namespace :seed do

  task ingredients: :environment do
    count = ENV['count'] || ENV['COUNT'] || 100
    count = count.to_i


    count.times do 
      word = "#{Faker::Lorem.word.capitalize} #{Faker::Lorem.word.capitalize}"
      Ingredient.create(name: word) if Ingredient.where(name:word).count == 0
    end
  end

  task cocktails: :environment do
    count = ENV['count'] || ENV['COUNT'] || 100
    count = count.to_i


    count.times do 
      word = "#{Faker::Lorem.word.capitalize} #{Faker::Lorem.word.capitalize}"

      ingredients_count = (rand*5).to_i + 1
      cypher = <<-CYPHER
        MATCH (i:Ingredient)
        WITH i, rand() AS number
        ORDER BY rand()
        RETURN i as ingredient
        LIMIT #{ingredients_count}
      CYPHER
      ingredients = Neo4j::Session.query(cypher).collect(&:ingredient)

      Cocktail.create(name: word.capitalize, ingredients: ingredients)
    end
  end
end
