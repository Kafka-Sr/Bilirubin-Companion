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

    // Resolve the caller's own user ID from their JWT
    const { data: { user: callerUser }, error: userErr } = await callerClient.auth.getUser()
    if (userErr || !callerUser) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Verify caller is admin — filter explicitly to their own profile so
    // .single() doesn't fail when RLS returns the full hospital roster
    const { data: callerProfile, error: profileErr } = await callerClient
      .from('user_profiles')
      .select('role, hospital_id')
      .eq('user_id', callerUser.id)
      .single()

    if (profileErr || callerProfile?.role !== 'admin') {
      return new Response(JSON.stringify({ error: 'Only admins can look up parents' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const callerHospitalId = callerProfile.hospital_id

    const { email } = await req.json()
    if (!email) {
      return new Response(JSON.stringify({ error: 'Email is required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Look up parent by email using auth admin API
    const { data: users, error: listErr } = await adminClient.auth.admin.listUsers()
    if (listErr) {
      return new Response(JSON.stringify({ error: 'Failed to search users' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const matchedUser = users.users.find(
      (u) => u.email?.toLowerCase() === email.toLowerCase()
    )
    if (!matchedUser) {
      return new Response(JSON.stringify({ error: 'User not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Verify they have a parent profile in the same hospital
    const { data: profile } = await adminClient
      .from('user_profiles')
      .select('full_name, role')
      .eq('user_id', matchedUser.id)
      .eq('role', 'parent')
      .eq('hospital_id', callerHospitalId)
      .maybeSingle()

    if (!profile) {
      return new Response(JSON.stringify({ error: 'No parent profile found for this email' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    return new Response(
      JSON.stringify({ userId: matchedUser.id, fullName: profile.full_name, email }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
