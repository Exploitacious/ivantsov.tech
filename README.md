# ivantsov.tech

The personal site for Alex Ivantsov: father, operations manager, sysadmin,
builder. It is a hub, not an app: a hero, the family links, a short
statement, a projects page, and a longer about page that doubles as a resume. Live at
<https://ivantsov.tech>.

## Stack

| Piece | What it is |
| --- | --- |
| [Astro 5](https://astro.build) | Static site generator. No SSR adapter: every route is prerendered to HTML at build time. |
| [Tailwind CSS 4](https://tailwindcss.com) | Styling, wired through `@tailwindcss/vite` in `astro.config.mjs`. |
| Google Fonts | Instrument Sans (headings and body, width axis used for headings) and JetBrains Mono (numbers, the wordmark, code-like data), loaded in `src/layouts/Layout.astro`. |
| `astro:assets` | Photos go through `<Image>`, which emits resized WebP at build time (sharp ships with Astro). |

There is no UI framework integration. The only shipped JavaScript is Astro's
`ClientRouter` (view transitions, pulled in by `Layout.astro`), which builds
to a ~15 KB bundle in `dist/_astro/`, plus the small inline scripts in
`Layout.astro` (theme before first paint) and `Nav.astro` (theme toggle and
mobile menu). Keep it that way: new npm dependencies need a real reason.

## Pages

| Route | Source |
| --- | --- |
| `/` | `src/pages/index.astro`: dark hero, family links, projects and about teasers, statement, connect list |
| `/projects` | `src/pages/projects.astro`: an index of open-source work and private production builds |
| `/about` | `src/pages/about.astro`: metrics, bio, capabilities, the one-record example table, skills, principles, shipped work |
| `/sms-privacy` | `src/pages/sms-privacy.astro`: privacy policy for the personal-assistant SMS service |
| `/sms-terms` | `src/pages/sms-terms.astro`: terms for the same service |

Shared chrome lives in `src/layouts/Layout.astro` (head, fonts, theme
bootstrap, skip link), `src/components/Nav.astro`, `src/components/Footer.astro`
and `src/components/Brand.astro`. Each main page keeps its words in data at
the top of the file, so a copy pass does not have to touch markup.

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

The IVA mark and the `IVANTSOV · TECH` lockup are specified in the
`Exploitacious/design-system` project, which is the source of truth for them.
It is a private repository, so no link is given here: a private-repo URL
404s for every public visitor of this site.

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
- Since the 2026-11-21 redesign the page colors are this site's own, not the
  design system's ramp. `src/styles/global.css` defines paper, surface, ink,
  muted, faint, rule, accent and band tokens for a light theme and a dark
  theme, exposed to Tailwind as `bg-paper`, `text-ink`, `text-accent` and so
  on. Use a token; do not reintroduce white-alpha text or raw hex in markup.
  Contrast for each token is noted beside it.
- The mark and the lockup stay in the design system's cyan and `#dfeaf2`, so
  they only ever sit on the dark band (nav, home hero, footer). The band is a
  neutral `#151515` sampled from the portrait's backdrop so the masked photo
  blends into the hero; change one and check the other.
- The first visit follows the OS color scheme; the nav toggle saves a choice
  to `localStorage`.
- The categorical accent palette at the top of `src/styles/global.css` is
  declared but deliberately unused, kept for future tags and charts, one hue
  per view.
