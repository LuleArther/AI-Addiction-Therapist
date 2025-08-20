# Google Sign-In Setup Instructions

## Important: Enable Required APIs

To fix the Google Sign-In error, you need to enable the People API in your Google Cloud Console:

### Steps:

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/
   - Select your project (should match your Firebase project)

2. **Enable People API**
   - Go to "APIs & Services" → "Library"
   - Search for "People API"
   - Click on it and press "ENABLE"
   - Direct link: https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=840648616109

3. **Verify OAuth 2.0 Client IDs**
   - Go to "APIs & Services" → "Credentials"
   - You should see OAuth 2.0 Client IDs for:
     - Web application
     - Android (if applicable)
     - iOS (if applicable)

4. **For Web Platform**
   - Make sure your Web Client ID is: `840648616109-80hmdcihg106e66a3272saa4mn63imnf.apps.googleusercontent.com`
   - Add authorized JavaScript origins:
     - http://localhost
     - http://localhost:5000
     - Your production domain

5. **Wait for Propagation**
   - After enabling the API, wait 2-5 minutes for changes to propagate
   - Try signing in again

## Alternative: Use Firebase Auth UI

If the issue persists, consider using Firebase Auth UI which handles Google Sign-In more robustly:

```dart
// In pubspec.yaml
dependencies:
  firebase_ui_auth: ^1.13.0
```

## Troubleshooting

If you still see the error:
1. Clear browser cache and cookies
2. Try in an incognito/private window
3. Ensure you're not blocking third-party cookies
4. Check that popup blockers are disabled for localhost
