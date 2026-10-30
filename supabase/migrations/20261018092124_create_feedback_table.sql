/*
# Create private internal feedback table

1. New Tables
- `internal_feedback`
  - `id` (uuid, primary key)
  - `rating` (int, 1-3, the low star rating that triggered the private form)
  - `name` (text, optional, patient may remain anonymous)
  - `phone` (text, optional)
  - `message` (text, required, the patient's complaint/suggestion)
  - `department` (text, optional, which department/service the feedback relates to)
  - `status` (text, default 'new', used by management dashboard: new/reviewed/resolved)
  - `created_at` (timestamptz, default now())
2. Security
- Enable RLS on `internal_feedback`.
- INSERT only for anon + authenticated (patients submit, they cannot read back others' feedback).
- No SELECT/UPDATE/DELETE for anon — feedback is private to hospital management.
  (Management reads via service-role key in a separate admin context, not exposed here.)
3. Notes
- This is single-tenant, no auth screen. Patients submit private feedback that goes
  only to hospital management — it is intentionally NOT publicly readable, which is why
  SELECT is denied to anon/authenticated here (INSERT-only table).
*/

CREATE TABLE IF NOT EXISTS internal_feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  rating int NOT NULL CHECK (rating >= 1 AND rating <= 3),
  name text,
  phone text,
  message text NOT NULL,
  department text,
  status text NOT NULL DEFAULT 'new',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE internal_feedback ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_insert_feedback" ON internal_feedback;
CREATE POLICY "anon_insert_feedback"
ON internal_feedback FOR INSERT
TO anon, authenticated
WITH CHECK (true);

-- No SELECT/UPDATE/DELETE policies: management accesses via service-role key only.