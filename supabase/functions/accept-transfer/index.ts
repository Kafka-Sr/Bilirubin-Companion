import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const callerClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      { auth: { autoRefreshToken: false, persistSession: false } }
    )

    const { data: { user: callerUser }, error: userErr } = await callerClient.auth.getUser()
    if (userErr || !callerUser) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const { data: callerProfile, error: profileErr } = await callerClient
      .from('user_profiles')
      .select('role, hospital_id')
      .eq('user_id', callerUser.id)
      .single()

    if (profileErr || callerProfile?.role !== 'admin') {
      return new Response(JSON.stringify({ error: 'Only admins can accept transfers' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const { transferId } = await req.json()
    if (!transferId) {
      return new Response(JSON.stringify({ error: 'transferId is required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Fetch the transfer row
    const { data: transfer, error: transferErr } = await adminClient
      .from('transfer_requests')
      .select('transfer_id, baby_id, from_hospital_id, to_hospital_id, status')
      .eq('transfer_id', transferId)
      .single()

    if (transferErr || !transfer) {
      return new Response(JSON.stringify({ error: 'Transfer not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    if (transfer.status !== 'pending') {
      return new Response(JSON.stringify({ error: 'Transfer is not pending' }), {
        status: 409,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    if (transfer.to_hospital_id !== callerProfile.hospital_id) {
      return new Response(JSON.stringify({ error: 'This transfer is not addressed to your hospital' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const babyId = transfer.baby_id
    const toHospitalId = transfer.to_hospital_id

    // Step a: mark transfer accepted
    const { error: markErr } = await adminClient
      .from('transfer_requests')
      .update({
        status: 'accepted',
        resolved_by: callerUser.id,
        resolved_at: new Date().toISOString(),
      })
      .eq('transfer_id', transferId)

    if (markErr) {
      return new Response(JSON.stringify({ error: 'Failed to update transfer status' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Step b: move the baby to the new hospital
    const { error: babyErr } = await adminClient
      .from('babies')
      .update({ hospital_id: toHospitalId })
      .eq('baby_id', babyId)

    if (babyErr) {
      return new Response(JSON.stringify({ error: 'Failed to update baby hospital' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Step c: move parent_access rows and collect parent IDs
    const { data: parentAccessRows, error: paFetchErr } = await adminClient
      .from('parent_access')
      .select('parent_id')
      .eq('baby_id', babyId)

    if (paFetchErr) {
      return new Response(JSON.stringify({ error: 'Failed to fetch parent access rows' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    if (parentAccessRows && parentAccessRows.length > 0) {
      const { error: paUpdateErr } = await adminClient
        .from('parent_access')
        .update({ hospital_id: toHospitalId })
        .eq('baby_id', babyId)

      if (paUpdateErr) {
        return new Response(JSON.stringify({ error: 'Failed to update parent_access hospital' }), {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }

      // Step d+e: move linked parent user_profiles to the new hospital
      const parentIds = parentAccessRows.map((row: { parent_id: string }) => row.parent_id)
      const { error: profileUpdateErr } = await adminClient
        .from('user_profiles')
        .update({ hospital_id: toHospitalId })
        .in('user_id', parentIds)

      if (profileUpdateErr) {
        return new Response(JSON.stringify({ error: 'Failed to update parent profiles hospital' }), {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }
    }

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
