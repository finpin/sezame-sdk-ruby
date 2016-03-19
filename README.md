Sezame ruby SDK
=======

Passwordless multi-factor authentication. 

Unlike password-based solutions that require you to remember just another PIN or password, sezame is  a secure and simple multi-factor authentication solution. You only need the username and your fingerprint on your smartphone to log into any sezame-enabled site. Magic – Sezame – ENTER SIMPLICITY!.

## Installation

Use [Composer](https://getcomposer.org/) to install the library.

``` bash
$ composer require finpin/sezame-sdk
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

```php

$client = new \SezameLib\Client();

$registerRequest = $client->register()->setEmail('example@example.com')->setName('my new client');

$registerResponse = $registerRequest->send();

$clientcode   = $registerResponse->getClientCode();
$sharedsecret = $registerResponse->getSharedSecret();

```

### sign

After you have authorized the registration on your mobile device you can request the certificate.

```php

$client = new \SezameLib\Client();

$privateKeyPassword = 'somethingsecret';

$csrKey = $client->makeCsr($clientcode, 'example@example.com', $privateKeyPassword,
  Array(
    'countryName'            => 'AT',
    'stateOrProvinceName'    => 'Vienna',
    'localityName'           => 'Vienna',
    'organizationName'       => 'my company name',
    'organizationalUnitName' => 'IT division'
  ));

$signRequest = $client->sign()->setCSR($csrKey->csr)->setSharedSecret($sharedsecret);

$cert = $signResponse->getCertificate();

printf("CSR:\n%s\n\n", $csrKey->csr);
printf("Certificate:\n%s\n\n", $cert);
printf("Private Key:\n%s\n\n", $csrKey->key);

```
Store the certificate and the private key within your system, it is recommended to protect your
private key with a secure passphrase.
The certificate and the private key is needed for subsequent calls to the Sezame servers, sign
and register are the only two calls which can be used without the client certificate.

### pair

Once you have successfully obtained the client certificate, let your customers pair their devices
with your application, this is done by displaying a QR code which is read by the Sezame app.

```php

$client = new \SezameLib\Client($certfile, $keyfile);

$username = 'foo-client-user';

// check pairing status of a certain user
$statusRequest = $client->linkStatus();
$statusResponse = $statusRequest->setUsername($username)->send();

if ($statusResponse->isLinked()) {
  print "user already has been linked\n";
  die;
}

$linkRequest = $client->link();
$linkResponse = $linkRequest->setUsername($username)->send();

if ($linkResponse->isDuplicate()) {
  print "user already has been linked\n";
  die;
}

$qrCode = $linkResponse->getQrCode($username);
$qrCode->setSize(300)->setPadding(10); // optionally adjust qrcode dimensions

printf('<img src="%s"/>', $qrCode->getDataUri());

file_put_contents('qrcode.html', sprintf('<img src="%s"/>', $qrCode->getDataUri()));

```

### auth

To authenticate users with Sezame, use the auth call.

```php

$client = new \SezameLib\Client($certfile, $keyfile, $keyPassword);
$username = 'foo-client-user';

$timeout = 10;
$authRequest = $client->authorize();
$authRequest->setUsername($username);
$authResponse = $authRequest->send();

if ($authResponse->isNotfound()) {
  // user not paired
}

if ($authResponse->isOk())
{
  $statusRequest = $client->status();
  $statusRequest->setAuthId($authResponse->getId());
  for ($i = 0; $i < $timeout; $i++)
  {
    $statusResponse = $statusRequest->send();
    if ($statusResponse->isAuthorized())
    {
      // request has been authorized
    }
    if ($statusResponse->isDenied()) 
    {
      // request has been denied
    }
    
    sleep(1);
  }
  
  printf("user did not respond within %d seconds\n", $timeout);
}

```

### fraud

It is possible to inform users about fraud attempts, this request could be send, if the user logs in
using the password.

```php

$client = new \SezameLib\Client($certfile, $keyfile, $keyPassword);
$username = 'foo-client-user';
$authRequest = $client->authorize();
$authRequest->setType('fraud');
$authRequest->setUsername($username);
$authResponse = $authRequest->send();
if ($authResponse->isNotfound()) {
  // user not paired
}
if ($authResponse->isOk())
{
  printf("user notified about possible fraud attempt\n");
}

```

### cancel

To disable the service use the cancel call, no further requests will be accepted by the Sezame
servers:

```php

$client = new \SezameLib\Client($certfile, $keyfile, $keyPassword);
$client->cancel()->send();

```

### error handling

The Sezame Lib throws exceptions in the case of an error.

```php

$client = new \SezameLib\Client($certfile, $keyfile);
try {
  $client->cancel()->send();
  printf("Client canceled\n");
} catch (\SezameLib\Exception\Connection $e) {
  printf("Connection failure: %s %d\n",
  $e->getMessage(), $e->getCode());
} catch (\SezameLib\Exception\Parameter $e) {
  print_r($e->getErrorInfo());
} catch (\SezameLib\Exception\Response $e) {
  printf("%s %d\n", $e->getMessage(), $e->getCode());
}

```


## License

This bundle is under the BSD license. For the full copyright and license
information please view the LICENSE file that was distributed with this source code.
