require 'rails_helper'

describe API::V1::UsersController do
  let(:key) { create(:api_key) }
  let(:user) { create(:user) }

  describe 'GET #bans' do
    context 'when unauthenticated' do
      it 'fails with unauthorized error' do
        get :bans, params: { id: user.id }

        expect(response).to have_http_status(:unauthorized)
        expect(json['status']).to eq(401)
        expect(json['message']).to eq('Unauthorized API key')
      end
    end

    context 'when authenticated with invalid key' do
      it 'fails with unauthorized error' do
        request.headers['X-API-Key'] = 'an invalid key'
        get :bans, params: { id: user.id }

        expect(response).to have_http_status(:unauthorized)
        expect(json['status']).to eq(401)
        expect(json['message']).to eq('Unauthorized API key')
      end
    end

    context 'when authenticated' do
      context 'retrieving unbanned player' do
        it 'succeeds with 0 bans' do
          request.headers['X-API-Key'] = key.key
          get :bans, params: { id: user.id }

          expect(response).to have_http_status(:success)
          expect(json['bans'].length).to eq(0)
        end
      end

      context 'retrieving league banned player' do
        it 'succeeds with 1 league ban' do
          user.ban(:use, :leagues)

          request.headers['X-API-Key'] = key.key
          get :bans, params: { id: user.id }

          expect(response).to have_http_status(:success)
          expect(json['bans'].length).to eq(1)
          expect(json['bans'].first['type']).to eq('leagues')
        end
      end

      it 'succeeds with multiple bans' do
        user.ban(:use, :leagues)
        user.ban(:use, :forums)

        request.headers['X-API-Key'] = key.key
        get :bans, params: { id: user.id }

        expect(response).to have_http_status(:success)
        expect(json['bans'].length).to eq(2)
        expect(json['bans'].any? { |hash| hash['type'] == 'leagues' }).to eq(true)
        expect(json['bans'].any? { |hash| hash['type'] == 'forums' }).to eq(true)
      end
    end
  end
end
