# AGENTS.md

## What this project is
- A static frontend workshop app for collecting AI agent ideas and blueprints.
- Single-page app: one `index.html` with a tab-style nav that swaps between three views (no page reloads).
- Runs entirely in the browser using ES modules and Supabase client-side access.
- No Node build step, no package manager files, no backend code in this repo.
- Not a git repo (no version history) — this AGENTS.md is the source of truth for project state and past decisions.

## Key files
- `index.html` — all three views (Agent Spark, Blueprint Lab, Admin Dashboard) plus their `<template>` markup and the top nav.
- `app.js` — all client logic: Agent Spark flow, Blueprint Lab wizard (Workflow Map, guardrails, scoring), admin dashboard (list/detail/JSON export), nav view-switching, and the Blueprint Lab feature flag.
- `config.js` — environment config; only `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `APP_NAME`.
- `supabase.sql` — Supabase schema, RLS policies, admin membership table, and `app_settings` (feature flags). Safe to re-run in full (uses `if not exists` / `add column if not exists` / `on conflict do nothing`).
- `styles.css`, `spark.css`, `lab-map.css` — shared, Spark-specific, and Blueprint Lab Workflow-Map-specific styling.
- `tidlor-pcl--600.png` — Tidlor logo shown in the top nav.
- `tidlor_ai_agent_workshop.html` — a one-off Tailwind design mockup used as the visual reference for the current single-page layout. Not linked from `index.html`, not served, not maintained — reference only, safe to ignore or delete.
- `Lab/` — a standalone Blueprint Lab prototype (`lab.html`/`lab.js`/`lab-map.css`) a collaborator built to redesign the Workflow Map step. Its logic was ported into `app.js`; the folder itself is not part of the live site — reference only.

## Development / runtime
- Run with a local HTTP server, e.g. `npx serve .`.
- Files load as browser ES modules, including `@supabase/supabase-js@2/+esm` from CDN.
- There is no build command or bundler.

## Important conventions and constraints
- Client code must never use Supabase `service_role` key.
- Use only the anon public key in `config.js`; unconfigured mode falls back to browser `localStorage`.
- `supabase.sql` enables RLS:
  - anon inserts into `agent_blueprints`
  - authenticated reads/writes on `agent_blueprints`/`app_settings` only if `auth.uid()` exists in `workshop_admins`
- Admin feature expects Supabase auth and the existing `agent_blueprints` schema.
- The user-facing UI is Thai; preserve copy and required-field logic when editing forms.
- Blueprint Lab visibility is controlled by the `app_settings.lab_enabled` row in Supabase, not a hardcoded constant — toggle it from the Admin dashboard (switch + explicit "บันทึก" save button at the top of the dashboard, once logged in) or via SQL. In unconfigured/localStorage demo mode it's always on.
- Blueprint Lab's Workflow Map requires a **minimum of 1 step, not 3**. This is deliberate, not a bug to "fix": the workshop's own philosophy is that a good agent is narrow/focused, so forcing a minimum step count penalizes legitimately simple agents. The `skill` scoring dimension is ratio-based (completeness ÷ step count), not `count × weight`, for the same reason — don't revert it to reward more steps.

## Data flow
- Spark flow submits `submission_type: 'spark'` with fields like `job_to_be_done`, `data_needed`, `output_definition`, `human_gate`, `hero_interest`, and `readiness_signals`.
- Lab flow submits `submission_type: 'lab'` with richer blueprint state, computed `blueprint_score`, and `score_breakdown`. `workflow_steps` is a Workflow Map: each step is `{action, data, no_data, tool, no_tool, output, owner}`, not a plain string — `data_needed`/`tools_needed` are derived from it at submit time, not entered directly. `definition_of_done` and `next_recipient` are separate required columns.
- Admin dashboard reads all submissions with `select('*')` (not an explicit column list) so new fields always show up automatically. It supports search/type filtering, an expandable "ดูรายละเอียด" detail view per submission (native `<details>`), per-card JSON download, and multi-select (checkbox + "select all shown") bulk JSON download — selection persists across filter/search changes since it's tracked by row id, not DOM position.

## Known gotchas (hit these already this session — don't re-debug from scratch)
- `SUPABASE_URL` must be the **Project URL** (`https://<ref>.supabase.co`) from Supabase Dashboard → Settings → API. It is easy to accidentally paste the **Database host** (`db.<ref>.supabase.co`) from the Connection String page instead — that breaks `createClient()` at module load and takes down the entire page, not just Supabase features.
- Logging into the Admin dashboard only proves Supabase Auth works. Every admin-gated read/write (`agent_blueprints` select, `app_settings` insert/update) additionally requires the logged-in user's `auth.uid()` to exist as a row in `public.workshop_admins`. If it's missing: dashboard silently shows "0 ไอเดีย" (SELECT rows get filtered, no error) but saving the Lab flag throws a real RLS error (INSERT/UPDATE don't fail silently).
- `app_settings` writes use `.upsert(..., {onConflict:'key'})`, not `.update()`. A plain `.update()` on a row that doesn't exist yet succeeds with 0 rows affected and **no error** — it looks like a successful save in the UI but nothing persists, and the value reverts on refresh.

## Backlog / planned, not started
- **JSON → `SKILL.md` draft generator.** Take one or more of the JSON blueprints exported from the Admin dashboard and generate a draft Claude Skill file: `job_to_be_done`/`agent_name` → description, `workflow_steps` (action/data/tool/output/owner) → step-by-step instructions, `can_do`/`cannot_do`/`human_gate` → guardrails/constraints. Should produce a *draft for human review*, not a finished skill — the raw employee input isn't precise enough to ship unedited.

## How to work on this repo
- Do not introduce backend/server code in this repository unless the project explicitly expands beyond static hosting.
- Keep config changes isolated to `config.js` and rely on Supabase environment/security rules rather than hidden client-side secrets.
- If you change data schema, update both `supabase.sql` and the relevant submission code in `app.js`.

## Useful quick references
- Local dev: `npx serve .`
- Supabase schema, RLS, and feature flags: `supabase.sql`
- Browser config: `config.js`
- All client logic (Spark, Lab, Admin, nav, feature flag): `app.js`
