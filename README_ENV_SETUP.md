# Environment Setup Instructions

## ⚠️ IMPORTANT: API Keys Configuration

This project requires API keys to function properly. Follow these steps before running the app:

### 1. Create `.env` file
Create a `.env` file in the root directory of the project with the following content:

```env
# API Keys - DO NOT COMMIT TO VERSION CONTROL
GEMINI_API_KEY=your_actual_gemini_api_key_here
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 2. Get your API keys

#### Gemini API Key (Required)
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Get API Key"
4. Copy the key and replace `your_actual_gemini_api_key_here` in the `.env` file

#### Supabase Configuration (Optional - for chat history)
1. Create a free account at [Supabase](https://supabase.com)
2. Create a new project
3. Go to Settings > API
4. Copy the "Project URL" and "anon public" key
5. Replace the placeholder values in the `.env` file

### 3. Verify `.gitignore`
Make sure your `.gitignore` file includes:
- `.env`
- `.env.*`
- `*.env`

This ensures your API keys are never committed to version control.

### 4. Install dependencies
```bash
flutter pub get
```

### 5. Run the app
```bash
flutter run
```

## 🔐 Security Notes

- **NEVER** commit the `.env` file to version control
- **NEVER** share your API keys publicly
- Consider using different API keys for development and production
- Rotate your API keys periodically for better security

## 📝 Firebase Configuration

The Firebase configuration in `firebase_options.dart` contains public-facing API keys that are safe to commit. These are restricted by domain/app bundle ID and Firebase security rules.

## 🚨 Troubleshooting

If you see errors about missing API keys:
1. Make sure the `.env` file exists in the root directory
2. Verify all required keys are present
3. Restart the app after adding the `.env` file

If Supabase is not configured, the app will still work but chat history won't be saved.
