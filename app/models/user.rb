require 'benchmark'

class User 
  include Neo4j::ActiveNode
  property :name, type: String

  has_many :out, :favorites, type: 'FAVORITED', model_class: false
  has_many :out, :favorite_cocktails, type: 'FAVORITED', model_class: 'Cocktail'
  has_many :out, :favorite_ingredients, type: 'FAVORITED', model_class: 'Ingredient'
  has_many :out, :owned_ingredients, type: 'OWNS', model_class: 'Ingredient'

  def makeable_cocktails(start=0, limit=20)
    cypher = <<-SQL
      MATCH (User { uuid:'#{id}' })-[:OWNS]->(Ingredient)<-[:MADE_WITH]-(cocktail:Cocktail) 
      WITH cocktail, collect(Ingredient) AS availableIngredients
      MATCH (cocktail)-[:MADE_WITH]->(Ingredient) 
      WITH cocktail, availableIngredients, collect(Ingredient) AS ingredients 
      WHERE ALL (x IN ingredients WHERE SINGLE (y IN availableIngredients WHERE x=y)) 
      RETURN cocktail
      SKIP #{start}
      LIMIT #{limit}
    SQL
    puts Benchmark.measure {
      @r = Neo4j::Session.query(cypher).collect(&:cocktail)
    }
    @r
  end

  def makeable_cocktails_count
    cypher = <<-SQL
      MATCH (User { uuid:'#{id}' })-[:OWNS]->(Ingredient)<-[:MADE_WITH]-(cocktail:Cocktail) 
      WITH cocktail, collect(Ingredient) AS availableIngredients
      MATCH (cocktail)-[:MADE_WITH]->(Ingredient) 
      WITH cocktail, availableIngredients, collect(Ingredient) AS ingredients 
      WHERE ALL (x IN ingredients WHERE SINGLE (y IN availableIngredients WHERE x=y)) 
      RETURN count(cocktail) as count
    SQL
    puts 'makeable_cocktails_count'
    puts Benchmark.measure {
      @r = Neo4j::Session.query(cypher).first['count']
    }
    @r
  end


  def cocktails_by_min_ingredients_count(count)
    cypher = <<-SQL
      MATCH (User { uuid:'#{id}' })-[:OWNS]->(Ingredient)<-[:MADE_WITH]-(Cocktail) 
      RETURN count(distinct(Cocktail)) as count
    SQL
    puts 'cocktails_by_min_ingredients_count'
    puts Benchmark.measure {
      @r = Neo4j::Session.query(cypher).first['count']
    }
    @r
  end

  def makeable_cocktails_with(ingredient)
    cypher = <<-SQL
      MATCH (Ingredient { uuid:'#{ingredient.id}'})<-[:MADE_WITH]-(cocktail:Cocktail)
      WITH cocktail
      MATCH (cocktail)-[:MADE_WITH]->(Ingredient) 
      WITH cocktail, collect(Ingredient) as ingredients
      MATCH (User { uuid:'#{id}' })-[:OWNS]->(i:Ingredient)<-[:MADE_WITH]-(cocktail)
      WITH cocktail, ingredients, collect(i) AS availableIngredients
      ORDER BY cocktail.name
      WHERE ALL (x IN ingredients WHERE SINGLE (y IN availableIngredients WHERE x=y)) 
      RETURN cocktail
    SQL
    puts Benchmark.measure {
      @r = Neo4j::Session.query(cypher).collect(&:cocktail) 
    }
    @r
  end
end



