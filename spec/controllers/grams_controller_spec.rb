require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#index action" do
    it "should successfully show the grams page" do  
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#new action" do 
    it "should successfully show the new form" do 
      user = User.create(
        email: 'fakeemail@gmail.com',
        password: 'fakepassword',
        password_confirmation: 'fakepassword'
      )

      sign_in user
      get :new
      expect(response).to have_http_status(:success)
    end
    it "should require users to be logged in" do 
      get :new
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe "grams#create action" do 
    it "should allow for grams to be created" do
      user = User.create(
        email: 'fakeemail@gmail.com',
        password: 'fakepassword',
        password_confirmation: 'fakepassword'
      )

      sign_in user 
      post :create, params: { gram: { message: 'Hello!' } }
      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq('Hello!')
      expect(gram.user).to eq(user)
    end
    it "should deal with validation error properly" do
      user = User.create(
        email: 'fakeemail@gmail.com',
        password: 'fakepassword',
        password_confirmation: 'fakepassword'
      )

      gram_count = Gram.count
      sign_in user 
      post :create, params: { gram: { message: "" } } 
      expect(response).to have_http_status(:unprocessable_entity)
      expect(gram_count).to eq Gram.count
    end
    it "should make a user sign in before accessing page" do
      post :create, params: { gram: { message: "Hello!" } }
      expect(response).to redirect_to new_user_session_path

    end
  end
end