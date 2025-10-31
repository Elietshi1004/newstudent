function ProfilePage({ onNavigate }) {
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

      // Load roles of current user (align with app: /api/userroles/)
      let fetchedRoles = [];
      try {
        const res = await authFetch('/api/userroles/');
        if (res.ok) {
          const list = await res.json();
          fetchedRoles = Array.isArray(list) ? list : (list.results || []);
        }
      } catch (_) {}
      if (mounted) setRoles(fetchedRoles);
    }
    load();
    return () => { mounted = false; };
  }, []);

  const roleNames = React.useMemo(() => {
    const names = [];
    (roles || []).forEach(r => {
      if (typeof r.role === 'object' && r.role && r.role.name) names.push(r.role.name);
      else if (r.name) names.push(r.name);
      else if (r.role_name) names.push(r.role_name);
    });
    return names.map(s => String(s).toLowerCase());
  }, [roles]);

  const isStudent = roleNames.includes('etudiant') || roleNames.includes('student');
  const isPubliant = roleNames.includes('publiant') || roleNames.includes('publisher') || roleNames.includes('auteur');

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
            {roleNames.map((r, i) => <span key={i} className="chip program" style={{textTransform:'capitalize'}}>{r}</span>)}
          </div>
        </div>
      </div>

      {isPubliant && (
        <div className="card" style={{marginBottom:12, cursor:'pointer'}} onClick={()=>onNavigate && onNavigate('MY_PUBLICATIONS')}>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'center'}}>
            <div>
              <div style={{fontWeight:700}}>Voir mes publications</div>
              <div className="muted">Consultez vos actualités publiées</div>
            </div>
            <button className="nav-btn">Ouvrir</button>
          </div>
        </div>
      )}

      {isStudent && (
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

      {isStudent && (
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


