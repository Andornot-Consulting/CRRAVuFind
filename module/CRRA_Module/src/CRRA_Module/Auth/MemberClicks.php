<?php

namespace CRRA_Module\Auth;

use VuFind\Exception\Auth as AuthException;
use VuFindHttp\HttpServiceAwareInterface;
use VuFindHttp\HttpServiceAwareTrait;

class MemberClicks extends \VuFind\Auth\AbstractBase implements HttpServiceAwareInterface
{
    use HttpServiceAwareTrait;

    public function authenticate($request)
    {
        $username = trim($request->getPost()->get('username'));
        $password = trim($request->getPost()->get('password'));

        if ($username == '' || $password == '') {
            throw new AuthException('authentication_error_blank');
        }

        $accessToken = $this->requestAccessToken($username, $password);

        if (empty($accessToken)) {
            throw new AuthException('authentication_error_invalid');
        }

        $details = $this->getDetailsFromAccessToken($accessToken);

        if (!isset($details->{'[Username]'}) || empty($details->{'[Username]'})) {
            throw new AuthException('authentication_error_admin');
        }

        $user = $this->getUserTable()->getByUsername($details->{'[Username]'});

        if (isset($details->{'[Name | First]'}) && !empty($details->{'[Name | First]'})) {
            $user->firstname = $details->{'[Name | First]'};
        }
        if (isset($details->{'[Name | Last]'}) && !empty($details->{'[Name | Last]'})) {
            $user->lastname = $details->{'[Name | Last]'};
        }
        if (isset($details->{'[Email | Primary]'}) && !empty($details->{'[Email | Primary]'})) {
            $user->email = $details->{'[Email | Primary]'};
        }

        $user->save();

        return $user;
    }

    protected function requestAccessToken($username, $password)
    {
        $body = "grant_type=password&scope=read&username={$username}&password={$password}";

        $clientId = $this->getConfig()->MemberClicks->clientId;
        $clientSecret = $this->getConfig()->MemberClicks->clientSecret;
        $orgId = $this->getConfig()->MemberClicks->orgId;

        $encodedCredentials = base64_encode("{$clientId}:{$clientSecret}");

        $endpoint = "https://{$orgId}.memberclicks.net/oauth/v1/token";

        $response = $this->httpService->post($endpoint, $body, 'application/x-www-form-urlencoded', null, [
                'Cache-Control' => 'no-cache',
                'Authorization' => "Basic {$encodedCredentials}",
            ]
        );

        if ($response->getStatusCode() === 200) {
            $json = json_decode($response->getBody());

            return isset($json->access_token) ? $json->access_token : null;
        }
    }

    protected function getDetailsFromAccessToken($accessToken)
    {
        $orgId = $this->getConfig()->MemberClicks->orgId;

        $endPoint = "https://{$orgId}.memberclicks.net/api/v1/profile/me";

        $response = $this->httpService->get($endPoint, [], null, [
            'Cache-Control' => 'no-cache',
            'Accept' => 'application/json',
            'Authorization' => "Bearer {$accessToken}",
        ]);

        if ($response->getStatusCode() === 200) {
            return json_decode($response->getBody());
        }
    }

    protected function validateConfig()
    {
        $memberClicks = $this->config->MemberClicks;

        if (!isset($memberClicks->clientId) || empty($memberClicks->clientId)) {
            throw new AuthException(
                'MemberClicks client ID is missing in your configuration file.'
            );
        }

        if (!isset($memberClicks->clientSecret) || empty($memberClicks->clientSecret)) {
            throw new AuthException(
                'MemberClicks client secret is missing in your configuration file.'
            );
        }

        if (!isset($memberClicks->orgId) || empty($memberClicks->orgId)) {
            throw new AuthException(
                'MemberClicks organization ID is missing in your configuration file.'
            );
        }
    }
}
