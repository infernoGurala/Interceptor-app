**Supabase** is used for authentication (sign up, sign in, sign out), text/markdown content storage, and media metadata storage. No credit card required. Free tier is sufficient for personal and small multi-user scale.

Supabase stores:

- User accounts and auth tokens
- All text and markdown feed items, tied to the user's ID
- Media metadata: Cloudinary URL, content type, upload timestamp, user ID

**Cloudinary** (free tier) handles all image and video file storage. The app never uploads raw files from the device. Instead the Cobalt public API extracts a raw media URL from the pasted link, and Cloudinary fetches and permanently stores that file.

**Cobalt public API** (`cobalt.tools`) converts platform links (Instagram, YouTube, etc.) into raw downloadable media URLs. No self-hosting required.

**Offline behavior:**

- Text and markdown content is cached locally on device using SQLite after first fetch.
- If the user creates or edits content while offline, changes are saved locally and automatically synced to Supabase when connection is restored.
- Images and videos are never cached. They require an active internet connection to display.
- If the user deletes and reinstalls the app, all content is restored from Supabase and Cloudinary on login.

Zero paid services. Zero credit card required.