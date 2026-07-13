create extension if not exists pgcrypto;
create table if not exists public.agent_blueprints (
 id uuid primary key default gen_random_uuid(), created_at timestamptz not null default now(), submission_type text not null check(submission_type in('spark','lab')),
 employee_id text not null check(char_length(employee_id) between 4 and 12), display_name text, department text not null, role text,
 agent_name text, job_to_be_done text not null, frequency text, time_spent text, pain_value text, workflow_steps jsonb, exception_handling text,
 data_needed text not null, tools_needed text, output_definition text not null, definition_of_done text, next_recipient text, success_check text, can_do text, cannot_do text, human_gate text not null,
 risk_level text check(risk_level in('low','medium','high')), hero_interest text check(hero_interest in('lead','supported','learn','unsure')),
 readiness_signals jsonb, consent text not null, blueprint_score int check(blueprint_score between 0 and 100), score_breakdown jsonb,
 status text not null default 'submitted', source text, user_agent text
);
create table if not exists public.workshop_admins(user_id uuid primary key references auth.users(id) on delete cascade);
alter table public.agent_blueprints enable row level security;alter table public.workshop_admins enable row level security;
create policy "participants can submit" on public.agent_blueprints for insert to anon,authenticated with check(true);
create policy "admins can read" on public.agent_blueprints for select to authenticated using(exists(select 1 from public.workshop_admins a where a.user_id=auth.uid()));
create policy "admin sees own membership" on public.workshop_admins for select to authenticated using(user_id=auth.uid());
create index if not exists agent_bp_employee_idx on public.agent_blueprints(employee_id);create index if not exists agent_bp_type_idx on public.agent_blueprints(submission_type);create index if not exists agent_bp_interest_idx on public.agent_blueprints(hero_interest);
-- หลังสร้าง Admin ใน Authentication: insert into public.workshop_admins(user_id) values ('AUTH-USER-UUID');
-- เผื่อ project เก่าที่รันตารางนี้ไปแล้วก่อนมี Workflow Map (definition_of_done / next_recipient):
alter table public.agent_blueprints add column if not exists definition_of_done text;
alter table public.agent_blueprints add column if not exists next_recipient text;
-- MIT Pilot Workflow Canvas alignment: Trigger (#1), Evidence & Audit Log (#7), Target Maturity Phase (#9)
alter table public.agent_blueprints add column if not exists trigger_event text;
alter table public.agent_blueprints add column if not exists audit_evidence text;
alter table public.agent_blueprints add column if not exists maturity_phase text check(maturity_phase in('crawl','walk','run'));

create table if not exists public.app_settings(key text primary key, value boolean not null default false);
alter table public.app_settings enable row level security;
create policy "everyone can read settings" on public.app_settings for select to anon,authenticated using(true);
create policy "admins can update settings" on public.app_settings for update to authenticated using(exists(select 1 from public.workshop_admins a where a.user_id=auth.uid())) with check(exists(select 1 from public.workshop_admins a where a.user_id=auth.uid()));
create policy "admins can insert settings" on public.app_settings for insert to authenticated with check(exists(select 1 from public.workshop_admins a where a.user_id=auth.uid()));
insert into public.app_settings(key,value) values('lab_enabled',false) on conflict(key) do nothing;
-- ปิด/เปิด Blueprint Lab ได้จากหน้า Admin โดยตรง หรือรันคำสั่งนี้ก็ได้: update public.app_settings set value=true where key='lab_enabled';
