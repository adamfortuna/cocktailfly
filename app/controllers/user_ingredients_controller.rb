class UserIngredientsController < ApplicationController
  before_action :set_user, only: [:show, :create, :destroy]
  before_action :set_ingredient, only: [:show, :create, :destroy]

  # GET /users/:user_id/ingredients/
  # GET /users/:user_id/ingredients.json
  def index
    @ingredients = @user.owned_ingredients
  end

  # POST /users/:user_id/ingredients
  def create
    @user.owned_ingredients << @ingredient
    redirect_to :back, notice: 'Ingredient Added!'
  end

  # GET /users/:user_id/ingredients/:id
  # GET /users/:user_id/ingredients/:id.json
  def show
    @cocktails = @user.makeable_cocktails_with(@ingredient)
  end

  # DELETE /users/:user_id/ingredients/:id
  def destroy
    @user.remove_ingredient!(@ingredient)
    redirect_to :back, notice: 'Ingredient Removed'
  end

  private
  def set_user
    @user = User.find(params[:user_id])
  end

  def set_ingredient
    @ingredient = Ingredient.find(params[:id])
  end
end
