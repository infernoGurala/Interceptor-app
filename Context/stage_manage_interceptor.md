Stage 1 — Project shell
Bottom nav bar, three empty screens, splash screen, theme system with one preset theme applied globally. No functionality yet. Just the skeleton and the premium visual foundation.
Stage 2 — Auth
Supabase sign up and sign in screens. Session persistence so the user stays logged in after closing the app. Route guard — signed out users cannot reach the feed.
Stage 3 — Jet screen (upload)
Text/markdown upload working and saving to Supabase. No media yet. Just text posts tied to the user's account.
Stage 4 — Intercept screen (text feed)
Fetch text posts from Supabase and display them as full screen cards with markdown rendering. Randomization logic. Offline SQLite cache. Offline/online sync.
Stage 5 — Media upload
Cobalt API integration in Jet screen. Cloudinary upload flow. Media metadata saved to Supabase.
Stage 6 — Media feed cards
Image and video cards in the feed. Offline hiding of media cards. Full screen card behavior.
Stage 7 — Profile screen
Theme picker with previews. Content management. Account settings.
Stage 8 — Polish
Private notes on cards. Feed card animations. Nav bar hide/show on scroll. Final theme variants.