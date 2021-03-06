require "rails_helper"
require "goodcity/organisation_populator"

describe Goodcity::OrganisationPopulator do
  let(:organisation_populator) { described_class.new }
  let(:file)                   { File.read("#{Rails.root}/spec/fixtures/organisation.json")}
  let!(:country)               { FactoryGirl.create(:country, name_en: "China - Hong Kong (Special Administrative Region)") }

  before do
    stub_request(:get, /goodcitystorage.blob.core.windows.net/).
      with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: file , headers: {}).response.body
  end

  context "populate organisation" do
    before { organisation_populator.run }
    it ":count created data" do
      expect(Organisation.count).to eq(JSON.parse(file).count)
    end
    it ":created data" do
      JSON.parse(file).each do |data|
        organisation_fields_mapping = described_class::ORGANISATION_MAPPING.keep_if { |k, v| data.key? v }
        organisation = Organisation.find_by_registration(data['org_id'])
        organisation_fields_mapping.each do |organisation_column, data_key|
          expect(organisation[organisation_column.to_sym]).to eq(data[data_key])
        end
      end
    end
  end

  context "update organisation" do
    let(:registration_id_one) { "91/09657"}
    let(:registration_id_two) { "91/15022" }
    before do
      Organisation.create(registration: registration_id_one, website: "")
      Organisation.create(registration: registration_id_two, name_en: "abcd")
    end

    describe ":updated data" do
      it "Create only new records" do
        expect {
         organisation_populator.run
        }.to change(Organisation, :count).by(6)
      end

      it ":update the existing records" do
        organisation_populator.run
        JSON.parse(file).each do |data|
          [registration_id_one, registration_id_two].each do |reg_id|
            if(data['org_id'] == reg_id)
              organisation = Organisation.find_by(registration: data['org_id'])
              expect(organisation.name_en).to eq(data['name_en'])
              expect(organisation.website).to eq(data['url'])
            end
          end
        end
      end
    end

    context "default_country" do
      it do
        expect(organisation_populator.send(:default_country).name_en).to eq(described_class::COUNTRY_NAME_EN)
      end
    end

    context "organisation_type" do
      it do
        expect(organisation_populator.send(:organisation_type).name_en).to eq(described_class::ORGANISATION_TYPE_NAME)
      end
    end

  end

end
