module Api::V1
  class OrganisationSerializer < ApplicationSerializer
    embed :ids, include: true

    attributes :id, :name_en, :name_zh_tw, :description_en, :description_zh_tw, :registration,
      :website, :organisation_type_id, :district_id, :country_id

  end
end
