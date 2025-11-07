function AuthPage({ onAuth }) {
  const [mode, setMode] = React.useState('login');
  const [username, setUsername] = React.useState('');
  const [password, setPassword] = React.useState('');
  const [email, setEmail] = React.useState('');
  const [loading, setLoading] = React.useState(false);
  const [error, setError] = React.useState('');
  const [showPassword, setShowPassword] = React.useState(false);

  async function handleSubmit(e) {
    e.preventDefault(); 
    setLoading(true); 
    setError('');
    try {
      if (mode === 'login') {
        const res = await fetch(`${API_BASE}/api/token/`, {
          method: 'POST', 
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ username, password })
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.detail || data.error || 'Login échoué');
        auth.set({ access: data.access, refresh: data.refresh });
        onAuth();
      } else {
        const res = await fetch(`${API_BASE}/api/signup/`, {
          method: 'POST', 
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ username, email, password })
        });
        const data = await res.json();
        if (!res.ok) {
          const errorMsg = data.error || (data.username ? data.username[0] : '') || (data.email ? data.email[0] : '') || 'Inscription échouée';
          throw new Error(errorMsg);
        }
        if (data.access && data.refresh) {
          auth.set({ access: data.access, refresh: data.refresh });
          onAuth();
        } else {
          setMode('login');
          setError('Compte créé avec succès ! Connectez-vous maintenant.');
        }
      }
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="auth-page-container">
      <div className="auth-page-wrapper">
        {/* Logo et branding */}
        <div className="auth-header">
          <div className="auth-logo">
            <span className="auth-logo-icon">🎓</span>
            <h1 className="auth-brand">CCC Étudiants</h1>
          </div>
          <p className="auth-tagline">
            {mode === 'login' 
              ? 'Bienvenue ! Connectez-vous pour accéder à votre espace' 
              : 'Rejoignez la communauté étudiante'}
          </p>
        </div>

        {/* Formulaire */}
        <div className="auth-card">
          {/* Onglets Login/Signup */}
          <div className="auth-tabs">
            <button 
              type="button"
              className={`auth-tab ${mode === 'login' ? 'active' : ''}`}
              onClick={() => { setMode('login'); setError(''); }}
            >
              <span className="auth-tab-icon">🔐</span>
              Connexion
            </button>
            <button 
              type="button"
              className={`auth-tab ${mode === 'signup' ? 'active' : ''}`}
              onClick={() => { setMode('signup'); setError(''); }}
            >
              <span className="auth-tab-icon">✨</span>
              Inscription
            </button>
          </div>

          {/* Message d'erreur */}
          {error && (
            <div className="auth-error">
              <span className="auth-error-icon">⚠️</span>
              <span>{error}</span>
            </div>
          )}

          {/* Formulaire */}
          <form onSubmit={handleSubmit} className="auth-form">
            <div className="auth-input-group">
              <label className="auth-label">
                <span className="auth-label-icon">👤</span>
                Nom d'utilisateur
              </label>
              <input
                type="text"
                className="auth-input"
                placeholder="Entrez votre nom d'utilisateur"
                value={username}
                onChange={e => setUsername(e.target.value)}
                required
                disabled={loading}
              />
            </div>

            {mode === 'signup' && (
              <div className="auth-input-group">
                <label className="auth-label">
                  <span className="auth-label-icon">📧</span>
                  Email
                </label>
                <input
                  type="email"
                  className="auth-input"
                  placeholder="Entrez votre adresse email"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  required
                  disabled={loading}
                />
              </div>
            )}

            <div className="auth-input-group">
              <label className="auth-label">
                <span className="auth-label-icon">🔒</span>
                Mot de passe
              </label>
              <div className="auth-password-wrapper">
                <input
                  type={showPassword ? 'text' : 'password'}
                  className="auth-input"
                  placeholder="Entrez votre mot de passe"
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  required
                  disabled={loading}
                />
                <button
                  type="button"
                  className="auth-password-toggle"
                  onClick={() => setShowPassword(!showPassword)}
                  tabIndex={-1}
                >
                  {showPassword ? '🙈' : '👁️'}
                </button>
              </div>
            </div>

            <button 
              type="submit" 
              className="auth-submit-btn"
              disabled={loading}
            >
              {loading ? (
                <span className="auth-loading">
                  <span className="auth-spinner"></span>
                  <span>Chargement...</span>
                </span>
              ) : (
                <span>
                  {mode === 'login' ? 'Se connecter' : 'Créer mon compte'}
                  <span className="auth-submit-arrow">→</span>
                </span>
              )}
            </button>
          </form>

          {/* Lien de basculement */}
          <div className="auth-switch">
            {mode === 'login' ? (
              <span>
                Pas encore de compte ?{' '}
                <a 
                  href="#" 
                  onClick={(e) => {
                    e.preventDefault(); 
                    setMode('signup'); 
                    setError('');
                  }}
                  className="auth-switch-link"
                >
                  Créer un compte
                </a>
              </span>
            ) : (
              <span>
                Déjà un compte ?{' '}
                <a 
                  href="#" 
                  onClick={(e) => {
                    e.preventDefault(); 
                    setMode('login'); 
                    setError('');
                  }}
                  className="auth-switch-link"
                >
                  Se connecter
                </a>
              </span>
            )}
          </div>
        </div>

        {/* Footer de la page auth */}
        <div className="auth-footer">
          <p>En vous connectant, vous acceptez nos conditions d'utilisation</p>
        </div>
      </div>
    </div>
  );
}


