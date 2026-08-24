# static-template

GitHub template for static client sites: **Astro 7 + Tailwind 4**, built to `dist/` and
served by Vercel. No backend, no database, no serverless.

It is deliberately empty. What it carries is the skeleton — folder layout, tooling, CI and
the conventions in `CLAUDE.md` — so a new site starts from a known-good setup instead of
`npm create astro` plus an afternoon of wiring.

## Requirements

Node 22.12+ (Astro 7 refuses to start below it). `.nvmrc` pins the version CI uses.

## Getting started

```bash
npm ci
npm run dev          # http://localhost:4321
```

## Scripts

```bash
npm run dev          # dev server
npm run sync         # regenerate .astro/types.d.ts after adding content collections
npm run typecheck    # astro check (types inside .astro included)
npm run lint         # eslint + prettier --check
npm run format       # prettier --write
npm run build        # astro check && astro build  <- what Vercel runs
npm run build:fast   # astro build only
npm run preview      # serve dist/ locally
```

## Structure

```
public/            static assets served as-is (favicon, robots, images)
src/
├─ assets/         images processed by <Image>, local fonts
├─ components/
│  ├─ ui/          reusable, knows nothing about the site
│  ├─ layout/      header, footer, site chrome
│  └─ sections/    page blocks
├─ content/        markdown collections (add src/content.config.ts to define them)
├─ layouts/        page shells
├─ lib/            site config, helpers
├─ pages/          routes
└─ styles/         global.css with the @theme tokens
scripts/           setup-github.sh · ruleset-main.json
```

The empty folders carry a `.gitkeep` so the layout survives the first push. Delete it as
soon as the folder has a real file.

## New site checklist

1. Set `site` in `astro.config.ts` to the client's domain.
2. Rename `mysite` in `package.json`.
3. Replace the tokens in `src/styles/global.css` and check contrast (AA, 4.5:1) in **both**
   themes.
4. Replace `public/favicon.svg` and `public/apple-touch-icon.png`.
5. Fill in `.env.example` and set the same variables in Vercel.
6. Create the Vercel project (framework: Astro, build command `npm run build`) and point DNS.
7. Run `scripts/setup-github.sh` to apply the branch ruleset and squash-only merges.

## Deployment

Vercel builds on merge to `main` and creates a preview per PR. `vercel.json` carries the
security headers and the `cleanUrls` / `trailingSlash` settings that must stay coherent with
`astro.config.ts`.
