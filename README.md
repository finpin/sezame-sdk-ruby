Sezame ruby SDK
=======

Passwordless multi-factor authentication. 

Unlike password-based solutions that require you to remember just another PIN or password, sezame is  a secure and simple multi-factor authentication solution. You only need the username and your fingerprint on your smartphone to log into any sezame-enabled site. Magic – Sezame – ENTER SIMPLICITY!.

## Installation



``` bash
```

## Steps

To be able to use Sezame within your application you have to fullfill these steps:

1. download and install the Sezame app from an app store
2. follow the registration process in the app
3. register your application/client
4. obtain a SSL client certificate
5. let your users pair their devices with your application
6. issue authentication requests

If you don not have a supported device with fingerprint reader, you must obtain the ssl certificate by
using the support channels of Sezame.

## Usage

### register

To be able to connect to the Sezame HQ server, you have to register your client/application, this is
done by sending the register call using your recovery e-mail entered during the app installation
process.
You'll get an authentication request on your Sezame app, which must be authorized.

```ruby

client = Sezame::Client.new

response = client.register 'foo@example.com', 'rubysdk test'
if response.is_ok
  p response.get_clientcode
  p response.get_sharedsecret
end

```

### sign

After you have authorized the registration on your mobile device you can request the certificate.

```ruby

client = Sezame::Client.new

request = client.makecsr(clientcode, 'foo@example.com')

p request[:csr]
p request[:key]
# p key.to_pem
# p key.public_key.to_pem

response = client.sign(request[:csr], sharedsecret)
if response.is_ok
  p response.get_cert
else
  p response.get_message
end
```

Store the certificate and the private key within your system, it is recommended to protect your
private key with a secure passphrase.
The certificate and the private key is needed for subsequent calls to the Sezame servers, sign
and register are the only two calls which can be used without the client certificate.

### pair

Once you have successfully obtained the client certificate, let your customers pair their devices
with your application, this is done by displaying a QR code which is read by the Sezame app.

```ruby

client = Sezame::Client.new(cert, privatekey)

unless client.link_status('someusername')
  p 'user is not linked'
end

response = client.link('someusername')

if response.is_duplicate
  p 'user already linked'
  exit
end

unless response.is_ok
  p response.get_message
  exit
end

image = response.qrcode.as_png(
    fill:  'white',
    color: 'black',
    size:  300,
    file:  'qr.png'
)

# prints as html table
p response.qrcode.as_html
```

### auth

To authenticate users with Sezame, use the auth call.

```ruby

timeout = 10 # secs

client = Sezame::Client.new(cert, privatekey)

response = client.authorize('someusername')

if response.is_notfound
  p response.get_message
  exit
end

unless response.is_ok
  p response.get_errors
  p response.get_message
  exit
end

auth_id = response.get_id

timeout.times do |num|
  status = client.status(auth_id)
  if status.is_authorized
    p 'authorized'
    exit
  end

  if status.is_denied
    p 'denied'
    exit
  end

  sleep(1)
end

p 'timeout'
```

### fraud

It is possible to inform users about fraud attempts, this request could be send, if the user logs in
using the password.

```ruby

client = Sezame::Client.new(cert, privatekey)

response = client.fraud('someusername')

if response.is_notfound
  p response.get_message
  exit
end

unless response.is_ok
  p response.get_errors
  p response.get_message
  exit
end

p 'user notified about fraud attempt'


```

### cancel

To disable the service use the cancel call, no further requests will be accepted by the Sezame
servers:

```ruby

client = Sezame::Client.new(cert, privatekey)

response = client.cancel
if response.is_ok
  p 'service cancelled'
end


```

## License

This bundle is under the BSD license. For the full copyright and license
information please view the LICENSE file that was distributed with this source code.
