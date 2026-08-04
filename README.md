# ivantsov.tech

The personal site for Alex Ivantsov — Father, Operations Manager, SysAdmin,
Builder. It is a hub, not an app: a hero, the links worth surfacing, a short
manifesto, a projects page, and a longer about page. Live at
<https://ivantsov.tech>.

## Stack

| Piece | What it is |
| --- | --- |
| [Astro 5](https://astro.build) | Static site generator. No SSR adapter — every route is prerendered to HTML at build time. |
| [Tailwind CSS 4](https://tailwindcss.com) | Styling, wired through `@tailwindcss/vite` in `astro.config.mjs`. |
| Google Fonts | Inter, Playfair Display and JetBrains Mono, loaded in `src/layouts/Layout.astro`. |

There is no UI framework integration. The only shipped JavaScript is Astro's
`ClientRouter` (view transitions, pulled in by `Layout.astro`), which builds
to a ~15 KB bundle in `dist/_astro/`, plus the small inline scripts in
`Layout.astro`, `Nav.astro` and the two main pages. Keep it that way — new
npm dependencies need a real reason.

## Pages

| Route | Source |
| --- | --- |
| `/` | `src/pages/index.astro` — hero, featured cards, manifesto, connect list |
| `/projects` | `src/pages/projects.astro` — the four projects worth showing, each linking out |
| `/about` | `src/pages/about.astro` — bio, capabilities, skills matrix, principles, selected work |
| `/sms-privacy` | `src/pages/sms-privacy.astro` — privacy policy for the personal-assistant SMS service |
| `/sms-terms` | `src/pages/sms-terms.astro` — terms for the same service |

Shared chrome lives in `src/layouts/Layout.astro` (head, film grain, scroll
progress bar), `src/components/Nav.astro` and `src/components/Brand.astro`.

## Commands

Run from the repo root.

| Command | Action |
| --- | --- |
| `npm ci` | Install dependencies from the lockfile |
| `npm run dev` | Dev server on `localhost:4321` |
| `npm run build` | Build the static site to `./dist/` |
| `npm run preview` | Serve the built `./dist/` locally |
| `npm run astro -- --help` | Astro CLI passthrough |

CI also runs `npx astro check`. That command pulls `@astrojs/check` and
`typescript` on demand; neither is a declared dependency of this project.

## Deploy

Push to `main` and the site ships. `.github/workflows/deploy.yml` builds the
`Dockerfile` and pushes the image to GHCR as
`ghcr.io/exploitacious/ivantsov.tech`, tagged `latest` plus the commit SHA.
The Dockerfile is two stages: `node:lts` runs `npm run build`, then
`nginx:alpine` serves the resulting `dist/` with `nginx.conf`. Pulling and
running the new image happens outside this repo.

Commits that only touch `**.md` are skipped by the deploy workflow
(`paths-ignore`), so documentation edits do not rebuild the image.

Two supporting workflows: `ci.yml` (astro check plus a build smoke test on
every PR and push to `main`) and `ghcr-cleanup.yml` (manual dispatch, keeps
the ten most recent tagged images).

## Brand

The visual language — the IVA mark, the `IVANTSOV · TECH` lockup, the colour
ramp, the white-alpha text ladder, the motion curve — is specified in the
`Exploitacious/design-system` project. That project is the source of truth;
this repo consumes it. It is a private repository, so no link is given here —
a private-repo URL 404s for every public visitor of this site.

What that means in practice:

- `src/components/Brand.astro` is a hand port of the design system's
  `components/layout/Brand.jsx`. Change the mark or the wordmark there first,
  then port it here.
- `public/brand/` holds the distributable logo files (`logo.svg`,
  `logo-mono.svg`, `logo-tile.svg`, `logo-tile-cyan.svg`), and
  `public/favicon.svg` the favicon. They sit in `public/` rather than
  `src/assets/` because they are consumed as stable, unhashed URLs by avatars
  and link previews, not imported through the build pipeline. All five are
  byte-identical copies of the design system's `assets/`.
- Text hierarchy is alpha, not hue. The ladder is `.16 / .24 / .32 / .38 /
  .45 / .50 / .56 / .64 / .78 / .88 / .92` white, matching the design system's
  `tokens/colors.css`. Pure white is reserved for the hero name and the
  wordmark. Pick an existing rung rather than inventing one.
- The categorical accent palette at the top of `src/styles/global.css` is
  declared but deliberately unused. Cyan owns every interactive state and
  emerald owns status; the accents are there for future tags and charts, one
  hue per view.
