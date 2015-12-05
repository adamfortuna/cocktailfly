class Ingredient 
  include Neo4j::ActiveNode
  property :name, type: String

  scope :by_name, -> { order(:name) }

  has_many :in, :cocktails, rel_class: CocktailIngredient, dependent: :delete
  has_many :in, :owned_by, type: 'OWNED', model_class: 'User'
  has_many :in, :favorited_by, type: 'FAVORITED', model_class: 'User'

  validates_presence_of :name
end
