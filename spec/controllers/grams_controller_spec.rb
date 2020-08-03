require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#destroy action" do 
    it "shouldn't allow for a user to delete a gram if they didn't create to" do 
      gram = FactoryBot.create(:gram)
      user = FactoryBot.create(:user)
      sign_in user 
      delete :destroy, params: { id: gram.id, gram: { message: 'I can only be deleted by my creator' } }
      expect(response).to have_http_status(:forbidden)
    end
    it "should require for a user to be logged in order to delete a gram" do 
      gram = FactoryBot.create(:gram)
      delete :destroy, params: { id: gram.id }
      expect(response).to redirect_to new_user_session_path
    end
    it "should allow a user to destroy a gram that is in our database" do 
      gram = FactoryBot.create(:gram, message: 'Here for now')
      sign_in gram.user 
      delete :destroy, params: { id: gram.id }
      expect(response).to redirect_to root_path
      gram = Gram.find_by_id(gram.id)
      expect(gram).to eq nil
    end
    it "should return a 404 for a gram that is attempted to be deleted but doesn't exist" do 
      user = FactoryBot.create(:user)
      sign_in user 
      delete :destroy, params: { id: 'SPACE DUCK' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#update action" do 
      it "should allow for a user who did not create the gram to update it" do 
        gram = FactoryBot.create(:gram)
        user = FactoryBot.create(:user)
        sign_in user 
        patch :update, params: { id: gram.id, gram: { message: "Not going to update" } }
        expect(response).to have_http_status(:forbidden)
      end 
      it "should require for a user to be logged in order to update a gram" do 
      gram = FactoryBot.create(:gram)
      patch :update, params: { id: gram.id }
      expect(response).to redirect_to new_user_session_path
    end
    it "should allow for a gram to be updated successfully" do 
      gram = FactoryBot.create(:gram, message: "Initial Value")
      sign_in gram.user
      patch :update, params: { id: gram.id, gram: { message: 'New Value' } }
      expect(response).to redirect_to root_path
      gram.reload
      expect(gram.message).to eq "New Value"
    end
    it "should return 404 for an update attempt for a gram that doesn't exist" do 
      user = FactoryBot.create(:user)
      sign_in user
      patch :update, params: { id: 'Nobody here!', gram: { message: "Nobody here either" } }
      expect(response).to have_http_status(:not_found)
    end
    it "should handle validations for updates that are blank" do 
      gram = FactoryBot.create(:gram, message: "Message that isn't blank")
      sign_in gram.user
      patch :update, params: { id: gram.id, gram: { message: '' } }
      expect(response).to have_http_status(:unprocessable_entity) 
      gram.reload
      expect(gram.message).to eq "Message that isn't blank"     
    end
  end 

  describe "grams#edit action" do 
    it "shouldn't let a user who did not create the gram to edit it" do 
      gram = FactoryBot.create(:gram)
      user = FactoryBot.create(:user)
      sign_in user 
      get :edit, params: { id: gram.id }
      expect(response).to have_http_status(:forbidden)
    end
    it "should require for a user to be logged in in order to delete a gram" do 
      gram = FactoryBot.create(:gram)
      get :edit, params: { id: gram.id }
      expect(response).to redirect_to new_user_session_path
    end
    it "should show the edit form for a gram that is in our database" do 
      gram = FactoryBot.create(:gram)
      sign_in gram.user
      get :edit, params: { id: gram.id }  
      expect(response).to have_http_status(:success)
    end
    it "should return a 404 error for a gram that not in the database" do 
      user = FactoryBot.create(:user)
      sign_in user
      get :edit, params: { id: "This is not in the database" }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#show action" do 
    it "should successfully show the gram that is in our database" do 
      gram = FactoryBot.create(:gram)
      get :show, params: { id: gram.id }
      expect(response).to have_http_status(:success)
    end
    it "should return a 404 error for a gram that does not exist in the database" do 
      get :show, params: { id: "TACOCAT" }
      expect(response).to have_http_status(:not_found)
    end
  end 

  describe "grams#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end


  describe "grams#new action" do
    it "should require users to be logged in" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the new form" do
      user = FactoryBot.create(:user)
      sign_in user

      get :new
      expect(response).to have_http_status(:success)
    end
  end


  describe "grams#create action" do

    it "should require users to be logged in" do
      post :create, params: { gram: { message: "Hello" } }
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully create a new gram in our database" do
      user = FactoryBot.create(:user)
      sign_in user

      post :create, params: 
        { gram: { 
          message: 'Hello!',
          picture: fixture_file_upload("/picture.png", 'image/png') 
        } 
      }
      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq("Hello!")
      expect(gram.user).to eq(user)
    end

    it "should properly deal with validation errors" do
      user = FactoryBot.create(:user)
      sign_in user

      gram_count = Gram.count
      post :create, params: { gram: { message: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(gram_count).to eq Gram.count
    end

  end
end