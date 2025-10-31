function AdminPage() {
  const [tab, setTab] = React.useState(0); // 0: programs, 1: users, 2: roles

  // Programs
  const { data: programs, loading: loadingPrograms } = useFetch(`/api/programs/`);

  // Users
  const { data: users, loading: loadingUsers } = useFetch(`/api/users/`);
  const [query, setQuery] = React.useState('');
  const filteredUsers = React.useMemo(() => {
    if (!users) return [];
    if (!query.trim()) return users;
    const k = query.toLowerCase();
    return users.filter(u =>
      (u.username || '').toLowerCase().indexOf(k) !== -1 ||
      (u.email || '').toLowerCase().indexOf(k) !== -1
    );
  }, [users, query]);

  // Roles and userroles
  const { data: roles, loading: loadingRoles } = useFetch(`/api/roles/`);
  const { data: userroles, loading: loadingUserRoles } = useFetch(`/api/userroles/`);

  async function createProgram() {
    const name = prompt('Nom du programme:');
    if (!name) return;
    const code = prompt('Code du programme:');
    if (!code) return;
    const res = await authFetch(`/api/programs/`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: name, code: code })
    });
    if (res.ok) { window.location.reload(); } else { alert('Erreur création programme'); }
  }

  async function editProgram(p) {
    const name = prompt('Nom du programme:', p.name || '');
    if (!name) return;
    const code = prompt('Code du programme:', p.code || '');
    if (!code) return;
    const res = await authFetch(`/api/programs/${p.id}/`, {
      method: 'PUT', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: name, code: code })
    });
    if (res.ok) { window.location.reload(); } else { alert('Erreur modification programme'); }
  }

  async function deleteProgram(p) {
    if (!confirm(`Supprimer le programme "${p.name}" ?`)) return;
    const res = await authFetch(`/api/programs/${p.id}/`, { method: 'DELETE' });
    if (res.ok) { window.location.reload(); } else { alert('Erreur suppression programme'); }
  }

  function rolesForUser(userId) {
    if (!userroles || !roles) return [];
    const roleIdSet = new Set();
    userroles.forEach(ur => { if (ur.user === userId) roleIdSet.add(ur.role); });
    const list = [];
    roles.forEach(r => { if (roleIdSet.has(r.id)) list.push(r); });
    return list;
  }

  async function manageRolesForUser(user) {
    if (!roles || !userroles) return;
    // Build a simple selection string
    const current = rolesForUser(user.id).map(r => r.id);
    const names = roles.map(r => `${r.id}:${r.name}`).join(', ');
    const input = prompt(`Sélectionnez des IDs de rôles (séparés par virgule):\n${names}`, current.join(','));
    if (input === null) return;
    const selected = input.split(',').map(s => Number(s.trim())).filter(Boolean);
    const original = new Set(current);
    const selectedSet = new Set(selected);
    const toAdd = [];
    const toRemove = [];
    selectedSet.forEach(id => { if (!original.has(id)) toAdd.push(id); });
    original.forEach(id => { if (!selectedSet.has(id)) toRemove.push(id); });

    // Add roles
    for (let i = 0; i < toAdd.length; i++) {
      const rid = toAdd[i];
      const res = await authFetch(`/api/userroles/`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user: user.id, role: rid })
      });
      if (!res.ok) { alert('Erreur à l\'ajout d\'un rôle'); return; }
    }
    // Remove roles
    for (let i = 0; i < toRemove.length; i++) {
      const rid = toRemove[i];
      // find link id
      const link = (userroles || []).find(ur => ur.user === user.id && ur.role === rid);
      if (link && link.id) {
        const res = await authFetch(`/api/userroles/${link.id}/`, { method: 'DELETE' });
        if (!res.ok) { alert('Erreur à la suppression d\'un rôle'); return; }
      }
    }
    window.location.reload();
  }

  return (
    <div className="container" style={{paddingTop: 20}}>
      <div className="section-title">Administration</div>
      <div style={{display:'flex', gap:8, marginBottom:16}}>
        <button className={'nav-btn'+(tab===0?' active':'')} onClick={()=>setTab(0)}>Programmes</button>
        <button className={'nav-btn'+(tab===1?' active':'')} onClick={()=>setTab(1)}>Utilisateurs</button>
        <button className={'nav-btn'+(tab===2?' active':'')} onClick={()=>setTab(2)}>Rôles</button>
      </div>

      {tab===0 && (
        <div>
          <div className="card" style={{marginBottom:12}}>
            <button className="btn" onClick={createProgram}>Ajouter un programme</button>
          </div>
          {loadingPrograms ? (
            <div className="card">Chargement…</div>
          ) : (
            <div className="grid cards">
              {(programs||[]).map(p => (
                <div key={p.id} className="card" style={{display:'flex',justifyContent:'space-between',alignItems:'center',gap:8}}>
                  <div>
                    <div style={{fontWeight:700}}>{p.name}</div>
                    <div className="muted">Code: {p.code}</div>
                  </div>
                  <div style={{display:'flex', gap:8}}>
                    <button className="nav-btn" onClick={()=>editProgram(p)}>Modifier</button>
                    <button className="nav-btn" onClick={()=>deleteProgram(p)} style={{borderColor:'#ef4444', color:'#ef4444'}}>Supprimer</button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {tab===1 && (
        <div>
          <div className="card" style={{marginBottom:12}}>
            <input placeholder="Rechercher un utilisateur (nom ou email)" value={query} onChange={e=>setQuery(e.target.value)} style={{width:'100%'}} />
          </div>
          {(loadingUsers || loadingRoles || loadingUserRoles) ? (
            <div className="card">Chargement…</div>
          ) : (
            <div className="grid cards">
              {filteredUsers.map(u => (
                <div key={u.id} className="card" style={{display:'flex',justifyContent:'space-between',alignItems:'center',gap:8}}>
                  <div>
                    <div style={{fontWeight:700}}>{u.username}</div>
                    <div className="muted">{u.email}</div>
                    <div style={{marginTop:6, display:'flex', gap:6, flexWrap:'wrap'}}>
                      {rolesForUser(u.id).map(r => (
                        <span key={r.id} className="chip program">{r.name}</span>
                      ))}
                    </div>
                  </div>
                  <div>
                    <button className="nav-btn" onClick={()=>manageRolesForUser(u)}>Gérer les rôles</button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {tab===2 && (
        <div>
          {loadingRoles ? (
            <div className="card">Chargement…</div>
          ) : (
            <div className="grid cards">
              {(roles||[]).map(r => (
                <div key={r.id} className="card">
                  <div style={{fontWeight:700}}>{r.name}</div>
                  {r.description ? <div className="muted">{r.description}</div> : null}
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}


