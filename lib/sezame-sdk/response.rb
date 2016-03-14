require 'rqrcode'

module Sezame

  # defines a set of response classes
  # to get easily response values
  module Response

    # generic response, expects the response as returned by the httpclient
    class Generic
      attr_reader :response
      attr_reader :data

      def initialize(response)
        @response = response
        @data     = response.content
      end

      def is_empty
        [201, 204, 304].include? @response.status
      end

      def is_ok
        @response.status == 200
      end

      def is_notfound
        @response.status == 404
      end

      def get_status
        unless @data.has_key?('status')
          return nil
        end

        @data['status']
      end

      # get the error message return by hq if any
      def get_message
        unless @data.has_key?('message')
          return nil
        end

        @data['message']
      end

      # return an array of error messages
      def get_errors
        unless @data.has_key?('errors')
          return []
        end

        @data['errors']
      end
    end

    # represents the registration response
    # returns the clientcode and the shared secret
    class Register < Generic
      def is_ok
        super && @data.has_key?('clientcode')
      end

      def get_clientcode
        @data['clientcode']
      end

      def get_sharedsecret
        @data['sharedsecret']
      end
    end

    # represents the sign response
    # returns the certificate
    class Sign < Generic
      def is_ok
        super && @data.has_key?('cert')
      end

      def get_cert
        @data['cert']
      end
    end

    # represents an authentication response
    # returns the authentication id
    class Auth < Generic
      def is_ok
        get_status == 'initiated'
      end

      def get_id
        @data['id']
      end
    end

    # auth status response
    # returns the status of the authentication request
    class Status < Generic
      def is_authorized
        get_status == 'authorized'
      end

      def is_denied
        get_status == 'denied'
      end

      def is_pending
        get_status == 'initiated'
      end
    end

    # represents the pairing response
    # returns a qrcode
    class Link < Generic
      attr_accessor :username

      def is_ok
        super && @data.has_key?('id')
      end

      def qrcode
        linkdata            = @data
        linkdata[:username] = username
        RQRCode::QRCode.new(linkdata.to_json)
      end

      def is_duplicate
        @response.status == 409
      end
    end

    # remove pairing response
    class LinkDelete < Generic

      def is_ok
        super || @response.status == 204
      end
    end

    # cancel service response
    class Cancel < Generic

      def is_ok
        super || @response.status == 204
      end
    end

  end
end
