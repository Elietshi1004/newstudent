function AuthPage({ onAuth }) {
  const [mode, setMode] = React.useState('login');
  const [username, setUsername] = React.useState('');
  const [password, setPassword] = React.useState('');
  const [email, setEmail] = React.useState('');
  const [loading, setLoading] = React.useState(false);
  const [error, setError] = React.useState('');

  async function handleSubmit(e) {
    e.preventDefault(); setLoading(true); setError('');
    try {
      if (mode === 'login') {
        const res = await fetch(`${API_BASE}/api/token/`, {
          method: 'POST', headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ username, password })
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.detail || 'Login échoué');
        auth.set({ access: data.access, refresh: data.refresh });
        onAuth();
      } else {
        const res = await fetch(`${API_BASE}/api/signup/`, {
          method: 'POST', headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ username, email, password })
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error || 'Inscription échouée');
        if (data.access && data.refresh) {
          auth.set({ access: data.access, refresh: data.refresh });
          onAuth();
        } else {
          setMode('login');
        }
      }
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="container" style={{paddingTop: 60, maxWidth: 460}}>
      <div className="card">
        <div className="section-title" style={{marginBottom: 16}}>
          {mode === 'login' ? 'Connexion' : 'Création de compte'}
        </div>
        {error && <div className="muted" style={{color:'var(--color-error)', marginBottom:12}}>{error}</div>}
        <form onSubmit={handleSubmit} className="grid" style={{gap:12}}>
          <input required placeholder="Nom d'utilisateur" value={username} onChange={e=>setUsername(e.target.value)} />
          {mode === 'signup' && (
            <input type="email" required placeholder="Email" value={email} onChange={e=>setEmail(e.target.value)} />
          )}
          <input required type="password" placeholder="Mot de passe" value={password} onChange={e=>setPassword(e.target.value)} />
          <button className="btn" type="submit" disabled={loading}>{loading ? '...' : (mode==='login'?'Se connecter':'Créer le compte')}</button>
        </form>
        <div className="muted" style={{marginTop:12}}>
          {mode==='login' ? (
            <span>Pas de compte ? <a href="#" onClick={(e)=>{e.preventDefault(); setMode('signup');}}>Inscription</a></span>
          ) : (
            <span>Déjà inscrit ? <a href="#" onClick={(e)=>{e.preventDefault(); setMode('login');}}>Connexion</a></span>
          )}
        </div>
      </div>
    </div>
  );
}


