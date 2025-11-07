function ProfilePage({ onNavigate, roleNames: propRoleNames }) {
  const [user, setUser] = React.useState(null);
  const [roles, setRoles] = React.useState([]);

  React.useEffect(() => {
    let mounted = true;
    async function load() {
      // Load user strictly via /api/me/
      let me = null;
      try {
        const res = await authFetch('/api/me/');
        if (res.ok) { me = await res.json(); }
      } catch (_) {}
      if (mounted) setUser(me);

      if (mounted && propRoleNames && propRoleNames.length) {
        setRoles(propRoleNames);
      } else {
        // Fallback if no roles passed, attempt to fetch once
        try {
          const res = await authFetch('/api/me/');
          if (res.ok) {
            const meData = await res.json();
            if (meData && Array.isArray(meData.roles)) {
              setRoles(meData.roles.map(r => r.name ? r.name : r));
            }
          }
        } catch (_) {}
      }
    }
    load();
    return () => { mounted = false; };
  }, [propRoleNames]);

  const normalizedRoles = React.useMemo(() => {
    if (!roles || !roles.length) return Array.isArray(propRoleNames) ? propRoleNames.map(r => r.toLowerCase()) : [];
    return roles.map(r => String(r).toLowerCase());
  }, [roles, propRoleNames]);

  const isStudentUser = window.isStudent ? window.isStudent(normalizedRoles) : normalizedRoles.includes('étudiant');
  const isPubliantFinal = window.isPubliant ? window.isPubliant(normalizedRoles) : normalizedRoles.includes('publiant');

  return (
    <div className="container" style={{paddingTop: 20}}>
      <div className="section-title">Mon profil</div>
      <div className="card" style={{marginBottom: 16}}>
        <div style={{display:'flex',justifyContent:'space-between',alignItems:'center',gap:8,flexWrap:'wrap'}}>
          <div>
            <div style={{fontWeight:700}}>{user && (user.full_name || user.username || user.email) || 'Utilisateur'}</div>
            <div className="muted">{user && user.email}</div>
          </div>
          <div style={{display:'flex',gap:6,flexWrap:'wrap'}}>
            {normalizedRoles.map((r, i) => <span key={i} className="chip program" style={{textTransform:'capitalize'}}>{r}</span>)}
          </div>
        </div>
      </div>

      {isPubliantFinal && (
        <div
          className="card"
          style={{marginBottom:12, cursor:'pointer'}}
          onClick={()=>onNavigate && onNavigate('MY_PUBLICATIONS')}
        >
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'center',gap:16}}>
            <div style={{display:'flex',alignItems:'center',gap:12}}>
              <div style={{fontSize:22}}>📰</div>
              <div>
                <div style={{fontWeight:700}}>Mes news</div>
                <div className="muted">Retrouvez toutes vos actualités publiées</div>
              </div>
            </div>
            <button className="nav-btn">Ouvrir</button>
          </div>
        </div>
      )}

      {isPubliantFinal && (
        <div
          className="card"
          style={{marginBottom:12, cursor:'pointer'}}
          onClick={()=>onNavigate && onNavigate('CREATE_NEWS')}
        >
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'center',gap:16}}>
            <div style={{display:'flex',alignItems:'center',gap:12}}>
              <div style={{fontSize:22}}>✍️</div>
              <div>
                <div style={{fontWeight:700}}>Créer une news</div>
                <div className="muted">Rédigez une nouvelle actualité pour vos programmes</div>
              </div>
            </div>
            <button className="nav-btn">Créer</button>
          </div>
        </div>
      )}

      {isStudentUser && (
        <div className="card" style={{marginBottom:12, cursor:'pointer'}} onClick={()=>onNavigate && onNavigate('PROGRAMS')}>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'center'}}>
            <div>
              <div style={{fontWeight:700}}>Mes programmes</div>
              <div className="muted">Gérer mes abonnements</div>
            </div>
            <button className="nav-btn">Gérer</button>
          </div>
        </div>
      )}

      {isStudentUser && (
        <div className="card" style={{marginBottom:12}}>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'center'}}>
            <div>
              <div style={{fontWeight:700}}>Préférences de notification</div>
              <div className="muted">Bientôt disponible sur le web</div>
            </div>
            <button className="nav-btn" disabled>Configurer</button>
          </div>
        </div>
      )}

    </div>
  );
}


