# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Communicating with Claude Code

Always respond to the developer in **Spanish**, regardless of the language of his message.
This is about chat responses only — it does not change the "Conventions" section below
(code, branch names and commit messages stay in English; **code comments are in Spanish**,
unlike `template-app`).

## Project

**This repository is a GitHub template, and it is deliberately empty.** It is not a website
and must not become one. What it carries is the skeleton a static client site starts from:
folder layout, tooling, CI, security headers and the conventions below.

Static site, no backend: Astro 7 + Tailwind 4, built to `dist/` and served by Vercel from a
CDN. There is no server, no database and no serverless function.

The sibling repository `template-app` is the equivalent for projects that _do_ have a
backend. Where a decision here differs from the one there, the difference is deliberate and
documented below.

The placeholder name is `mysite` (`https://mysite.example.com`). It is deliberately not
`site` or `web`, which appear inside identifiers all over the codebase and would be
destructive to search-and-replace.

**Do not add pages, components, sections, collections or demo content to this repository.**
Someone cloning it wants an empty starting point, not a landing page to delete. If asked to
build something concrete, build it in the repo made _from_ this template.

## Commands you must NOT run

The developer runs these himself. Write the code and the files, then stop and tell him what
to run — never execute them yourself:

- `git add`, `git commit`, `git push`, `git merge`, `git rebase`, `git reset`
- `vercel`, `vercel deploy`, or any command that publishes the site
- `gh repo create`, `gh repo edit`, `scripts/setup-github.sh` — these change repository
  settings on GitHub

You may read git state (`git status`, `git diff`, `git log`) and run the local commands
below.

## Commands

Node 22.12+ is required (Astro 7 refuses to start below it). `.nvmrc` pins the version CI
uses; keep them aligned.

```bash
npm ci                  # install exactly what package-lock.json says
npm run dev             # dev server at http://localhost:4321
npm run sync            # regenerate .astro/types.d.ts after touching content.config.ts
npm run typecheck       # astro check (types inside .astro included)
npm run lint            # eslint + prettier --check
npm run format          # prettier --write
npm run build           # astro check && astro build  <- what Vercel runs
npm run build:fast      # astro build only
npm run preview         # serve dist/ locally
```

npm 11 prints an `allow-scripts` warning for `esbuild` and `fsevents` on install. It is
noise here: esbuild's binary arrives through a platform-specific optional dependency, not
through the postinstall, and the build works without approving either.

## Structure

The empty folders exist to fix the layout before the first file lands in them. Each carries
a `.gitkeep`, which is deleted as soon as the folder has real content.

- **`src/components/`** — three folders with different jobs. `ui/` is reusable and knows
  nothing about the site; `layout/` is header, footer and the site chrome; `sections/` are
  the page blocks. Header and Footer are neither reusable UI nor landing sections, and
  mixing them into either folder is the first crack through which the structure degrades.
- **`src/content/`** — Markdown collections. Defining one means creating
  **`src/content.config.ts`** at the root of `src/`, not in `src/content/`: the legacy
  collections API was removed in Astro 6.
- **`src/lib/`** — site configuration and helpers. A `site-config.ts` validated with Zod at
  module top level is the recommended shape: a bad value then kills the build at first
  import instead of publishing broken metadata.
- **`src/styles/global.css`** — the `@theme` tokens. There is no `tailwind.config.js` and
  there should not be.

## Conventions

- Code, branch names and commit messages in **English**. UI text in **Spanish**.
  **Code comments in Spanish** — this differs from `template-app` on purpose.
- Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:` — one line.
- Comments explain **why**, never what the line already says. Keep them scarce: a warning
  where there is a real trap, not a narration of the file.
- Colours, spacing and radii come from the tokens in `global.css`. Never a literal colour in
  a component: the dark theme reassigns the same semantic tokens, so a hardcoded value stops
  following the theme.
- `dark:` variants are for exceptions only. System colours already follow the theme through
  the tokens.
- The three text levels must clear WCAG AA (4.5:1) against every surface token in **both**
  themes. Lighthouse only audits whichever theme the browser happens to be in, so a
  regression in the other one goes unnoticed. **Recalculate before lightening any of them.**

## URLs: three settings that must stay coherent

`trailingSlash: 'never'` and `build.format: 'file'` in `astro.config.ts`, `cleanUrls` and
`trailingSlash` in `vercel.json`. Together they leave exactly one servable canonical URL per
resource. Change one without the others and you get redirect chains.

With `build.format: 'file'` the `Astro.url.pathname` seen during the build is the **file**
path (`/servicios/seo.html`), not the URL a visitor gets. Anything computing a canonical has
to normalise it, or every canonical points at `/index.html`.

## Git workflow

- Trunk-based. `main` is protected — direct pushes are rejected by GitHub.
- Branches: `feature/<name>`, `fix/<name>`, `chore/<name>`, branched off `main`.
- All changes go through a PR. Squash merge only.
- Vercel deploys on merge to `main` and builds a preview per PR.
- CI runs `lint → typecheck → build → audit` in series, so the first error you see is the
  cheapest to fix and a CVE published this morning does not delay lint feedback.

## Architecture decisions

Do not propose or add any of this without being asked:

- **No backend, no serverless, no database.** The moment something needs one, it is a
  different project.
- **No CMS.** Content lives in `src/content/` as Markdown, validated at build time.
- **No React, Vue or Svelte.** If an interaction genuinely needs a framework, it goes in as
  a single Astro island with a written justification.
- **No i18n.** The sites built from this are monolingual `es-ES`. Adding `[lang]` routing
  later means revisiting canonicals, `hreflang` and the sitemap; do not half-build it now.
- **No cookie banner** by default. Keep fonts self-hosted and analytics cookieless. Adding
  an embedded video, a map or a chat widget breaks this and requires both a banner and a
  cookie policy.
- **No Vercel adapter.** A static site does not need one; `@astrojs/vercel` is only for
  on-demand rendering.
- **No CodeQL.** In `template-app` it analyses server-side Python. Here the output is static
  HTML and there is no server-side attack surface. This is a decision, not an oversight.
  gitleaks and `npm audit` do apply and are kept.

## Security

This is a **public repository**.

- Never commit secrets. All configuration through environment variables. `.env` is
  gitignored; `.env.example` is committed with placeholder values. Note that everything
  prefixed `PUBLIC_` reaches the browser — a static site compiles nothing private.
- **Security headers** in `vercel.json`: HSTS with preload, `X-Content-Type-Options`,
  `Referrer-Policy`, a `Permissions-Policy` that denies every API the site does not use,
  COOP/CORP and `X-Frame-Options`.
- **Secret scanning**: `gitleaks` runs on every PR over the **full** history, so a secret
  that ever landed keeps failing CI until it is purged — not merely removed in a later
  commit. It uses the MIT CLI from a digest-pinned image rather than `gitleaks-action`,
  which needs a paid licence for org-owned repositories. Dependabot does not track that
  digest; bump it by hand.
- **Dependency scanning**: `npm audit --audit-level=high` gates every PR. Dependabot
  proposes upgrades with a 7-day cooldown.

### If you add a CSP

`astro.config.ts` ships without one because an empty skeleton has nothing to hash. When the
site grows scripts, enable `security.csp` there — it emits a `<meta http-equiv>` per page
with auto-generated hashes — and keep `vercel.json` to the directives a `<meta>` cannot
carry. The browser applies the **intersection** of both, so a `default-src` in the header
would act as a fallback for `script-src` and block the very scripts the `<meta>` authorises.
**`vercel.json` must never contain `default-src`.** Symptom: works locally, blank in
production. Note also that Astro does not hash `is:inline` scripts — an anti-FOUC script has
to have its hash added by hand.

## Stack constraints

- **Astro 7** (`>=22.12.0` on Node), **Tailwind 4** CSS-first via `@tailwindcss/vite`.
  There is no `tailwind.config.js` and there should not be: tokens live in the `@theme`
  block of `global.css`.
- **Zod 4** through `astro/zod`. Use `z.url()` and `z.email()`, not `z.string().url()`.
- **Sätteri** is Astro 7's default Markdown processor. Tutorials written for Astro 5 that
  talk about `remarkPlugins` / `rehypePlugins` do not apply; the equivalents are
  `mdastPlugins` / `hastPlugins`. `@astrojs/mdx` needs the `@astrojs/markdown-satteri` peer.
- The Astro 7 compiler is Rust-based and **strict about invalid HTML**: every non-void tag
  must be closed. `compressHTML` defaults to `'jsx'`, which trims inline whitespace the way
  React does.
- **`src/fetch.ts` is a reserved filename** in Astro 7. Do not use it for a helper.

### Three pins that look like mistakes and are not

Someone will eventually try to "clean these up" and break the build. They are here on
purpose:

1. **`typescript` is pinned to `~6.0.3`** while npm's latest is 7.x. `@astrojs/check@0.9.10`
   declares the peer range `^5 || ^6`, so TypeScript 7 breaks `npm run typecheck` outright.
   Dependabot is configured to ignore its major bump. Unpin only after `@astrojs/check`
   widens the peer range.

2. **`overrides.eslint-plugin-jsx-a11y.eslint` in `package.json`.** `eslint-plugin-jsx-a11y`
   has had no release in ~22 months and still declares a peer of `eslint ^9`, while
   `eslint-plugin-astro@3` requires `eslint >=10`. Without the override `npm ci` fails with
   ERESOLVE. The scoped override was chosen over `--legacy-peer-deps`, which would disable
   peer checking across the entire tree. **Deleting it breaks installation.**

3. **ESLint, not oxlint.** `template-app` uses oxlint. oxlint does not parse `.astro` files,
   and here almost all the code will be `.astro` — a linter that ignores most of the
   repository is worthless however fast it is. Revisit only after verifying oxlint has
   gained Astro support.
