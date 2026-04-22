This is where the user uploads content to their feed.

The user pastes a link (Instagram, YouTube, or any supported platform). The app sends the link to the Cobalt public API, which returns a raw media URL. The app then sends that URL to Cloudinary, which fetches and permanently stores the file. From that point the content is served from Cloudinary.

The user must choose a content type tag when uploading: image, video, or text.

For text/markdown content, the user types or pastes directly. No external link needed.

All uploaded content is tied to the logged-in user's account. Other users cannot see or access it.

Offline mode: only text content is shown when there is no internet. Images and videos require an active connection.

Content randomization: feed order is reshuffled on every app open. The same item is never shown twice within close proximity in a single session.