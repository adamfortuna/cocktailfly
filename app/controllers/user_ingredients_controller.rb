class UserIngredientsController < ApplicationController
  before_action :set_user, only: [:show]
  before_action :set_ingredient, only: [:show]

  # GET /users/:user_id/ingredients/
  # GET /users/:user_id/ingredients.json
  def index
    @ingredients = @user.owned_ingredients
  end

  # GET /users/:user_id/ingredients/:id
  # GET /users/:user_id/ingredients/:id.json
  def show
    @cocktails = @user.makeable_cocktails_with(@ingredient)
  end

  private
  def set_user
    @user = User.find(params[:user_id])
  end

  def set_ingredient
    @ingredient = Ingredient.find(params[:id])
  end
end
