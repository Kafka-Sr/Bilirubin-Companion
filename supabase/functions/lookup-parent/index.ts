import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })

  try {
    const { email } = await req.json()

    const authHeader = req.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) return json({ error: 'Unauthorized' }, 401)
    const token = authHeader.replace('Bearer ', '')

    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const { data: { user: caller }, error: authErr } = await admin.auth.getUser(token)
    if (authErr || !caller) return json({ error: 'Unauthorized' }, 401)

    const { data: callerProfile } = await admin
      .from('user_profiles')
      .select('role')
      .eq('user_id', caller.id)
      .single()

    if (!['admin', 'staff', 'nurse'].includes(callerProfile?.role)) {
      return json({ error: 'Unauthorized' }, 403)
    }

    const { data: { users } } = await admin.auth.admin.listUsers({ perPage: 1000 })
    const target = users.find((u) => u.email?.toLowerCase() === email.toLowerCase())

    if (!target) return json({ error: 'No account found with that email' }, 404)

    const { data: profile } = await admin
      .from('user_profiles')
      .select('role')
      .eq('user_id', target.id)
      .single()

    if (profile?.role !== 'parent') {
      return json({ error: 'That account is not a parent account' }, 400)
    }

    return json({ userId: target.id, email: target.email })
  } catch (e) {
    return json({ error: String(e) }, 500)
  }
})

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, 'Content-Type': 'application/json' },
  })
}
