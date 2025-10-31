function App() {
  const [authed, setAuthed] = React.useState(!!auth.access);
  const [current, setCurrent] = React.useState('HOME');
  const [selectedNews, setSelectedNews] = React.useState(null);
  const [roleNames, setRoleNames] = React.useState([]);
  const [loadingRoles, setLoadingRoles] = React.useState(true);

  // Charger les rôles de l'utilisateur
  React.useEffect(() => {
    if (!authed) return;
    let mounted = true;
    async function loadRoles() {
      try {
        const roles = await getUserRoles();
        const names = extractRoleNames(roles);
        console.log('Noms de rôles extraits:', names);
        console.log('Est admin?', isAdmin(names));
        if (mounted) {
          setRoleNames(names);
          setLoadingRoles(false);
        }
      } catch (e) {
        console.error('Erreur lors du chargement des rôles:', e);
        if (mounted) {
          setRoleNames([]);
          setLoadingRoles(false);
        }
      }
    }
    loadRoles();
    return () => { mounted = false; };
  }, [authed]);

  const handleLogout = () => { 
    auth.clear(); 
    setAuthed(false); 
    setRoleNames([]);
    setCurrent('HOME');
  };

  // Protéger l'accès à Admin : rediriger si pas admin
  React.useEffect(() => {
    if (!loadingRoles) {
      if (current === 'ADMIN' && !isAdmin(roleNames)) {
        setCurrent('HOME');
      }
      // Protéger l'accès à Modération : rediriger si pas modérateur (ou si admin)
      if (current === 'MODERATION' && (!isModerator(roleNames) || isAdmin(roleNames))) {
        setCurrent('HOME');
      }
    }
  }, [current, roleNames, loadingRoles]);

  if (!authed) return <AuthPage onAuth={()=>setAuthed(true)} />;
  return (
    <div>
      <Header current={current} onNavigate={setCurrent} onLogout={handleLogout} roleNames={roleNames} />
      {current === 'HOME' && <HomePage onSelect={(n)=>{ setSelectedNews(n); setCurrent('DETAIL'); }} />}
      {current === 'NEWS' && !selectedNews && <NewsPage onSelect={(n)=>{ setSelectedNews(n); setCurrent('DETAIL'); }} />}
      {current === 'DETAIL' && <NewsDetail news={selectedNews} onBack={()=>{ setSelectedNews(null); setCurrent('NEWS'); }} />}
      {current === 'PROGRAMS' && <ProgramsPage />}
      {current === 'ADMIN' && isAdmin(roleNames) && <AdminPage />}
      {current === 'MODERATION' && isModerator(roleNames) && !isAdmin(roleNames) && <ModerationPage />}
      {current === 'PROFILE' && <ProfilePage onNavigate={setCurrent} />}
      {current === 'MY_PUBLICATIONS' && <MyPublicationsPage onSelect={(n)=>{ setSelectedNews(n); setCurrent('DETAIL'); }} onBack={()=>setCurrent('PROFILE')} />}
    </div>
  );
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);


