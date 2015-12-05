class Cocktail 
  include Neo4j::ActiveNode
  property :name, type: String

  scope :by_name, -> { order(:name) }
  
  has_many :out, :ingredients, rel_class: CocktailIngredient, unique: true
  has_many :in, :favorited_by, type: 'FAVORITED', model_class: 'User'

  validates_presence_of :name

  after_save :create_recipe
  attr_accessor :recipe

  def build_ingredient
    CocktailIngredient.new(from_node: self)
  end

  private

  def create_recipe
    @recipe.each do |cocktail_ingredient|
      CocktailIngredient.create(cocktail_ingredient.merge(from_node: self))
    end
  end
end
