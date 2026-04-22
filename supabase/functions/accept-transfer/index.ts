import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })

  try {
    const { transferId } = await req.json()

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
      .select('role, hospital_id')
      .eq('user_id', caller.id)
      .single()

    if (callerProfile?.role !== 'admin') {
      return json({ error: 'Only admins can accept transfers' }, 403)
    }

    const { data: transfer, error: fetchErr } = await admin
      .from('transfer_requests')
      .select('*')
      .eq('id', transferId)
      .single()

    if (fetchErr || !transfer) return json({ error: 'Transfer not found' }, 404)

    if (transfer.to_hospital_id !== callerProfile.hospital_id) {
      return json({ error: 'You are not the receiving hospital for this transfer' }, 403)
    }

    if (transfer.status !== 'pending') {
      return json({ error: `Transfer is already ${transfer.status}` }, 400)
    }

    await admin
      .from('transfer_requests')
      .update({
        status: 'accepted',
        resolved_by: caller.id,
        resolved_at: new Date().toISOString(),
      })
      .eq('id', transferId)

    return json({ success: true })
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
