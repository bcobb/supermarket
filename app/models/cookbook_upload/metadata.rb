require 'virtus'

class CookbookUpload
  class Metadata
    include Virtus.value_object

    values do
      attribute :name, String
      attribute :version, String
      attribute :description, String
      attribute :maintainer, String
      attribute :license, String
    end
  end
end
