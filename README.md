1. Create bin/credentials.dart

```dart
class Credentials {
  static const applicationPublicKey = '*****';
}
```

2. Run the following command

`gcloud beta run deploy discord-interactions-test --allow-unauthenticated --source=.`

3. Add `[Google Cloud Run URL]/rest` as the `INTERACTIONS ENDPOINT URL` on your test bot's configuration page on the Discord Developer Portal

Make sure to set the max instances on the Cloud Run Service to 1 or you might run into issues