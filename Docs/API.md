# API Documentation

## Recovered Business Endpoints

No active Surfie business REST endpoint, MQTT topic, WebSocket URL, TCP host, or UDP host was recovered from the active app pages.

## Generic uniCloud Configuration

The bundle contains generic uniCloud SDK code and config:

```text
provider: aliyun
spaceId: mp-30f0d080-8681-43f6-9e86-e089525baf54
clientSecret: ZUtZ0M1oiqucYjQIAOtrag==
endpoint: https://api.next.bspapp.com
```

The active Surfie pages do not call `request.call` or `request.call2`.

## iOS Networking Layer

The iOS project includes:
- `APIClient`: generic Codable `URLSession` client.
- `AuthenticationService`: Keychain-backed token storage.
- `APIError`: shared error model.

ASSUMPTION: These classes are included to satisfy the requested iOS architecture and to make future recovered endpoints easy to add. They are not wired into the active UI because the APK does not contain active API calls.
