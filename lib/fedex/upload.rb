module Fedex
  # Visit {http://www.fedex.com/us/developer/ Fedex Developer Center} for a complete list of values returned from the API
  #
  class Upload
    # Initialize Fedex::Upload Object
    # @param [Hash] options
    #
    #
    # return [Fedex::Upload Object]
    #     @iamge_id #ID of the uploaded image
    attr_accessor :image_id
    def initialize(options = {})
      @image_id = options[:id]
    end
  end
end
