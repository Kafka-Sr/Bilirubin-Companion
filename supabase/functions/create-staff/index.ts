import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })

  try {
    const { email, password, role } = await req.json()

    if (!['admin', 'nurse', 'parent'].includes(role)) {
      return json({ error: 'Role must be admin, nurse, or parent' }, 400)
    }

    const authHeader = req.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) return json({ error: 'Unauthorized' }, 401)
    const token = authHeader.replace('Bearer ', '')

    // Use admin client to verify JWT — works with both HS256 and ES256.
    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const { data: { user: caller }, error: authErr } = await admin.auth.getUser(token)
    if (authErr || !caller) return json({ error: 'Unauthorized' }, 401)

    const { data: callerProfile } = await admin
      .from('user_profiles')
      .select('role, hospital_id')
      .eq('user_id', caller.id)
      .single()

    if (callerProfile?.role !== 'admin') {
      return json({ error: 'Only admins can create staff accounts' }, 403)
    }

    const { data: newUser, error: createErr } = await admin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
    })

    if (createErr) return json({ error: createErr.message }, 400)

    const { error: profileErr } = await admin
      .from('user_profiles')
      .insert({
        user_id: newUser.user.id,
        role,
        hospital_id: callerProfile.hospital_id,
        email,
      })

    if (profileErr) {
      await admin.auth.admin.deleteUser(newUser.user.id)
      return json({ error: profileErr.message }, 500)
    }

    return json({ success: true, userId: newUser.user.id })
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
