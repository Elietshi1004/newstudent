function ProgramsPage() {
  const { data: programs, loading: loadingPrograms } = useFetch(`/api/programs/`);
  const { data: subscriptions, loading: loadingSubs } = useFetch(`/api/subscriptions/`);

  const [busyProgramId, setBusyProgramId] = React.useState(0);
  const [errorMsg, setErrorMsg] = React.useState('');
  const [currentUserId, setCurrentUserId] = React.useState(0);

  React.useEffect(() => {
    let mounted = true;
    async function resolveUserId() {
      // Try from JWT, else via /api/me/
      const fromJwt = (typeof window !== 'undefined' && window.authUserId) ? window.authUserId() : 0;
      if (fromJwt) { if (mounted) setCurrentUserId(fromJwt); return; }
      try {
        const res = await authFetch('/api/me/');
        if (res && res.ok) {
          const j = await res.json();
          const id = j && (j.id || j.user_id || (j.user && j.user.id));
          if (id) { if (mounted) setCurrentUserId(id); return; }
        }
      } catch (_) {}
      if (mounted) setCurrentUserId(0);
    }
    resolveUserId();
    return () => { mounted = false; };
  }, []);

  const { subscribedSet, programToSubId } = React.useMemo(() => {
    const set = new Set();
    const map = new Map();
    (subscriptions || []).forEach(s => {
      const prog = (typeof s.program === 'object' && s.program) ? s.program.id : s.program;
      if (prog) {
        set.add(prog);
        map.set(prog, s.id);
      }
    });
    return { subscribedSet: set, programToSubId: map };
  }, [subscriptions]);

  async function subscribe(programId) {
    setErrorMsg('');
    try {
      setBusyProgramId(programId);
      // Always resolve user via /api/me/ to match app behavior
      let meId = currentUserId;
      if (!meId) {
        try {
          const meRes = await authFetch('/api/me/');
          if (meRes.ok) { const me = await meRes.json(); meId = me && me.id ? me.id : 0; }
        } catch (_) {}
      }
      if (!meId) {
        setErrorMsg("Impossible de déterminer l'utilisateur courant. Veuillez vous reconnecter.");
        return;
      }
      // Backend (comme mobile): attend { user, program }
      const res = await authFetch(`/api/subscriptions/`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user: meId, program: programId })
      });
      if (res.ok) {
        window.location.reload();
      } else {
        let detail = '';
        try { const j = await res.json(); detail = j && (j.detail || j.error || JSON.stringify(j)); } catch (_) {}
        setErrorMsg(detail || "Échec de l'abonnement. Veuillez réessayer.");
      }
    } finally {
      setBusyProgramId(0);
    }
  }

  async function unsubscribe(programId) {
    try {
      const subId = programToSubId.get(programId);
      if (!subId) return;
      setBusyProgramId(programId);
      const res = await authFetch(`/api/subscriptions/${subId}/`, { method: 'DELETE' });
      if (res.ok) window.location.reload();
    } finally {
      setBusyProgramId(0);
    }
  }

  return (
    <div className="container" style={{paddingTop: 20}}>
      <div className="section-title">Mes programmes</div>
      <div className="card" style={{marginBottom: 16}}>
        <div className="muted">Gérez vos abonnements aux programmes pour personnaliser les actualités.</div>
      </div>
      {errorMsg ? <div className="card" style={{borderColor:'#ef4444', color:'#ef4444'}}>{errorMsg}</div> : null}
      {(loadingPrograms || loadingSubs) ? (
        <div className="card">Chargement…</div>
      ) : (
        <div className="grid cards">
          {(programs || []).map(p => {
            const isSub = subscribedSet.has(p.id);
            return (
              <div key={p.id} className="card" style={{display:'flex',flexDirection:'column',gap:8}}>
                <div style={{display:'flex',justifyContent:'space-between',alignItems:'center',gap:8}}>
                  <div style={{fontWeight:700}}>{p.name}</div>
                  <span className="chip program">{p.code || 'Programme'}</span>
                </div>
                <div className="muted">{p.description || ''}</div>
                <div>
                  {isSub ? (
                    <button className="nav-btn" disabled={busyProgramId===p.id} onClick={()=>unsubscribe(p.id)}>
                      {busyProgramId===p.id ? '...' : 'Se désabonner'}
                    </button>
                  ) : (
                    <button className="btn" disabled={busyProgramId===p.id} onClick={()=>subscribe(p.id)}>
                      {busyProgramId===p.id ? '...' : "S'abonner"}
                    </button>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}


