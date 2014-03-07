require 'spec_helper'

describe Api::V1::CookbookUploadsController do
  describe '#create' do
    context 'when the upload is valid' do
      before do
        allow_any_instance_of(CookbookUpload).to receive(:valid?) { true }
        allow_any_instance_of(CookbookUpload).
          to receive(:finish!).
          and_yield(double('Cookbook'))
      end

      it 'sends the cookbook to the view' do
        post :create, cookbook: 'cookbook', tarball: 'tarball', format: :json

        expect(assigns[:cookbook]).to_not be_nil
      end

      it 'returns a 200' do
        post :create, cookbook: 'cookbook', tarball: 'tarball', format: :json

        expect(response.status.to_i).to eql(200)
      end
    end
  end
end
