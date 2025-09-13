
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

## Styles structure

The landing styles are now modularized:

- Entry point: `public/styles.css` (aggregates partials; keep order)
- Partials live in `public/styles/` and are grouped by section, e.g. `01-nav.css`, `04-hero.css`, `07-demo-integrations.css`, etc.
- Edit the partials, not `public/styles.css`. Keep imports order if adding new files.

### Build a single CSS file (optional, recommended for production)

To concatenate all partials into a single `public/styles.css` (no `@import`s):

```bash
scripts/build-css.sh
```

This overwrites `public/styles.css` with the bundled content while preserving the same path used in HTML.

## Deploy

To deploy to production:

```bash
firebase deploy --only hosting
```

Make sure you are authenticated with Firebase CLI (`firebase login`) and have the correct project selected (`firebase use`).
