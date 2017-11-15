require 'fedex/request/base'

module Fedex
  module Request
    class Upload < Base
      def initialize(credentials, options={})
        requires!(options, :image, :id)

        @id = options[:id]
        @image = options[:image]
        @credentials = credentials
      end

      def process_request
        puts build_xml if @debug == true
        api_response = self.class.post api_url, body: build_xml
        puts api_response if @debug == true
        response = parse_response(api_response)
        if success?(response)
          Fedex::Upload.new(response[:upload_images_reply][:image_statuses])
        else
          error_message = if response[:upload_images_reply]
            [response[:upload_images_reply][:notifications]].flatten.first[:message]
          else
            "#{api_response["Fault"]["detail"]["fault"]["reason"]}\n
            --#{api_response["Fault"]["detail"]["fault"]["details"]["ValidationFailureDetail"]["message"].join("\n--")}"
          end rescue $1
          raise UploadError, error_message
        end
      end

      private

      # Build xml Fedex Web Service request
      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.UploadImagesRequest(xmlns: "http://fedex.com/ws/uploaddocument/v#{Fedex::UPLOAD_IMAGES_API_VERSION}"){
            add_web_authentication_detail(xml)
            add_client_detail(xml)
            add_version(xml)
            add_images(xml)
          }
        end
        builder.doc.root.to_xml
      end

      def add_images(xml)
        xml.Images {
          xml.Id @id
          xml.Image @image
        }
      end

      def service
        { id: 'cdus', version: Fedex::UPLOAD_IMAGES_API_VERSION }
      end

      # Successful request
      def success?(response)
        response[:upload_images_reply] &&
          %w{SUCCESS WARNING NOTE}.include?(response[:upload_images_reply][:highest_severity])
      end
    end
  end
end
