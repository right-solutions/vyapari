require 'rails_helper'

describe Vyapari::Admin::BrandsController, :type => :controller do

  let(:published_brand) {FactoryGirl.create(:published_brand, name: "Published Brand")}
  let(:unpublished_brand) {FactoryGirl.create(:unpublished_brand, name: "Un Published Brand")}
  let(:removed_brand) {FactoryGirl.create(:removed_brand, name: "Removed Brand")}

  let(:approved_user) {FactoryGirl.create(:approved_user)}
  
  describe "index" do
    describe "Positive Case" do
      it "should list the brands for site admin" do
        site_admin_role = FactoryGirl.create(:role, name: "Site Admin")
        site_admin_user = FactoryGirl.create(:site_admin_user)
        session[:id] = site_admin_user.id
        get :index, params: { use_route: 'vyapari' }, cookies: {id: site_admin_user.id}
        expect(response.status).to eq(200)
      end

      it "should list the brands for super admin user" do
        site_admin_role = FactoryGirl.create(:role, name: "Site Admin")
        site_admin_user = FactoryGirl.create(:site_admin_user)
        session[:id] = site_admin_user.id
        get :index, params: { use_route: 'vyapari' }, cookies: {id: site_admin_user.id}
        expect(response.status).to eq(200)
      end
    end

    describe "Negative Case" do
      it "should redirect to dash page for all other users" do
        site_admin_role = FactoryGirl.create(:role, name: "Site Admin")
        site_admin_user = FactoryGirl.create(:site_admin_user)
        session[:id] = site_admin_user.id
        get :index, params: { use_route: 'vyapari' }, cookies: {id: site_admin_user.id}
        expect(response.status).to eq(200)
      end
    end
  end

  describe "create_session" do

    context "Positive Case" do
      it "should create session with email" do
        sign_in_params = { login_handle: approved_user.email, password: approved_user.password, use_route: 'usman' }
        post :create_session, params: sign_in_params
        expect(session[:id].to_s).to  eq(approved_user.id.to_s)
      end

      it "should create session with username" do
        sign_in_params = { login_handle: approved_user.username, password: approved_user.password, use_route: 'usman' }
        post :create_session, params: sign_in_params
        expect(session[:id].to_s).to  eq(approved_user.id.to_s)
      end
    end

    context "Negative Case" do
      it "invalid email" do
        sign_in_params = { login_handle: "invalid@email.com", use_route: 'usman' }
        session[:id] = nil
        post :create_session, params: sign_in_params
        expect(session[:id]).to be_nil
      end

      it "invalid password" do
        sign_in_params = { login_handle: approved_user.email, password: "Invalid", use_route: 'usman' }
        session[:id] = nil
        post :create_session, params: sign_in_params
        expect(session[:id]).to be_nil
      end

      it "inactive user" do
        sign_in_params = { login_handle: pending_user.email, password: pending_user.password, use_route: 'usman' }
        session[:id] = nil
        post :create_session, params: sign_in_params
        expect(session[:id]).to be_nil
      end

      it "suspended user" do
        sign_in_params = { login_handle: suspended_user.email, password: suspended_user.password, use_route: 'usman' }
        session[:id] = nil
        post :create_session, params: sign_in_params
        expect(session[:id]).to be_nil
      end
    end
  end

  describe "destroy a session" do
    it "should delete session of user" do
      delete :sign_out, params: {:id => approved_user.id, use_route: 'usman'}, cookies: {id: approved_user.id}
      expect(response).to redirect_to("/sign_in?locale=en")
    end
  end
end
