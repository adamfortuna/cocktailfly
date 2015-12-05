class CocktailIngredient
  include Neo4j::ActiveRel

  from_class Cocktail
  to_class Ingredient
  type 'MADE_WITH'

  # Amount of this ingredient
  property :amount, type: Integer

  validates_presence_of :amount
  attr_accessor :_destroy

  def from_node_uuid
    from_node.try :neo_id
  end

  def to_node_uuid
    to_node.try :neo_id
  end

  def to_node_uuid=(uuid)
    @to_node = Ingredient.find(uuid)
  end

  def from_node_uuid=(uuid)
    @from_node = Cocktail.find(uuid)
  end

  def marked_for_destruction?
    false
  end

end
