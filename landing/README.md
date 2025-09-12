
# vytalLink Landing

This is the public landing page for vytalLink.

- Hosted on **Firebase Hosting**
- Public URL: https://vytallink.xmartlabs.com/

## Local development

To preview locally:

```bash
firebase serve --only hosting --port 5000
```

Then open [http://localhost:5000](http://localhost:5000) in your browser.

## Deploy

To deploy to production:

```bash
firebase deploy --only hosting
```

Make sure you are authenticated with Firebase CLI (`firebase login`) and have the correct project selected (`firebase use`).
