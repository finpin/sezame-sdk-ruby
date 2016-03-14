require 'openssl'
require_relative 'sezamejsonclient'
require_relative 'response'


module Sezame

  ##
  # base class for client requests.
  class Client
    attr_reader :http

    # Expects a certificate string in pem format, the
    # corresponding private key and an optional keypassword
    def initialize(cert = nil, key = nil, keypassword = nil)
      @http                 = SezameJSONClient.new
      @http.connect_timeout = 10

      @endpoint = 'https://hqfrontend-finprin.finprin.com/'

      if cert != nil && key != nil
        @http.ssl_config.client_cert = OpenSSL::X509::Certificate.new(cert)
        @http.ssl_config.client_key  = OpenSSL::PKey.read(key, keypassword)
      end
    end

    # start the self-registration process by specifying
    # a recovery e-mail entered during app installation
    # and a name for your application
    def register(email, name)
      endpoint  = @endpoint + 'client/register'
      response = @http.post endpoint, {
          :email => email,
          :name  => name
      }
      Sezame::Response::Register.new(response)
    end

    # helper function for building a csr
    # pass the client code, obtained by the registration call
    # add an e-mail address and additional x509 options
    def makecsr(clientcode, email, x509 = {}, keylen = 2048)
      options = {
          :country      => 'AT',
          :state        => 'Vienna',
          :city         => 'Vienna',
          :organization => '-',
          :department   => '-',
          :common_name  => clientcode,
          :email        => email
      }
      options.merge!(x509)

      key            = OpenSSL::PKey::RSA.new(keylen)
      csr            = OpenSSL::X509::Request.new
      csr.version    = 0
      csr.subject    = OpenSSL::X509::Name.new([
                                                   ['C', options[:country], OpenSSL::ASN1::PRINTABLESTRING],
                                                   ['ST', options[:state], OpenSSL::ASN1::PRINTABLESTRING],
                                                   ['L', options[:city], OpenSSL::ASN1::PRINTABLESTRING],
                                                   ['O', options[:organization], OpenSSL::ASN1::UTF8STRING],
                                                   ['OU', options[:department], OpenSSL::ASN1::UTF8STRING],
                                                   ['CN', options[:common_name], OpenSSL::ASN1::UTF8STRING],
                                                   ['emailAddress', options[:email], OpenSSL::ASN1::UTF8STRING]
                                               ])
      csr.public_key = key.public_key
      csr.sign(key, OpenSSL::Digest::SHA256.new)

      {
          :csr => csr.to_pem,
          :key => key.to_pem
      }
    end

    # let the csr signed by the hq server, pass the
    # shared secret as optained by the register call
    def sign(csr, sharedsecret)
      endpoint  = @endpoint + 'client/sign'
      response = @http.post endpoint, {
          :csr          => csr,
          :sharedsecret => sharedsecret
      }
      Sezame::Response::Sign.new(response)
    end

    # check the pairing status for the given username
    def link_status(username)
      endpoint  = @endpoint + 'client/link/status'
      response = @http.post endpoint, {
          :username => username
      }
      response.content
    end

    # pair the given username with your application
    def link(username)
      endpoint  = @endpoint + 'client/link'
      response = @http.post endpoint, {
          :username => username
      }
      ret = Sezame::Response::Link.new(response)
      ret.username = username
      ret
    end

    # remove the pairing for the given username
    def link_delete(username)
      endpoint  = @endpoint + 'client/link'
      response = @http.delete endpoint, {
          :username => username
      }
      Sezame::Response::LinkDelete.new(response)
    end

    # submit an authentication request for the given username
    # the message is displayed on the mobile app
    # the timeout parameter defined the amount of seconds the requests is valid
    # the type of request (auth or fraud)
    # a callback url, results are posted to this url
    # extra_params to be returned with the callback post
    def authorize(username, message = nil, timeout = nil, type = 'auth', callback = nil, extra_params = nil)
      endpoint          = @endpoint + 'auth/login'
      params            = {
          :username => username
      }

      params[:type]  = type if type
      params[:message]  = message if message
      params[:timeout]  = timeout if timeout
      params[:callback] = callback if callback
      params[:params]   = extra_params if extra_params

      Sezame::Response::Auth.new(@http.post endpoint, params)
    end

    # inform the user about fraud attempts, like plaintext password logins
    def fraud(username, message = nil, timeout = nil, callback = nil, extra_params = nil)
      authorize(username, message, timeout, 'fraud', callback, extra_params)
    end

    # fetch the status of an authentication request
    def status(auth_id)
      endpoint  = @endpoint + 'auth/status/' + auth_id
      Sezame::Response::Status.new(@http.get endpoint)
    end
  end

  # cancel the service
  def cancel
    endpoint  = @endpoint + 'client/cancel'
    Sezame::Response::Cancel.new(@http.get endpoint)
  end
end
