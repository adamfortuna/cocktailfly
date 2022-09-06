class Glass
  include Neo4j::ActiveNode
  property :name, type: String

  scope :by_name, -> { order(:name) }

  validates_presence_of :name
end
