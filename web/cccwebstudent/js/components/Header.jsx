const pages = {
  HOME: 'HOME', NEWS: 'NEWS', PROGRAMS: 'PROGRAMS', ADMIN: 'ADMIN', MODERATION: 'MODERATION', PROFILE: 'PROFILE'
};

function Header({ current, onNavigate, onLogout, roleNames = [] }) {
  // Debug pour voir les rôles reçus
  React.useEffect(() => {
    console.log('Header - roleNames reçus:', roleNames);
    console.log('Header - isAdmin:', isAdmin(roleNames));
  }, [roleNames]);

  const isAdminUser = isAdmin(roleNames);
  const isModeratorUser = isModerator(roleNames);
  const isPubliantUser = isPubliant(roleNames);
  const isStudentUser = isStudent(roleNames);

  // Construire les onglets selon les rôles (comme dans role_based_bottom_bar.dart)
  const navItems = [
    {id: pages.HOME, label: 'Accueil'} // Toujours visible
  ];

  // Pour les admins : seulement Accueil, Admin et Profil (pas Actualités ni Programmes)
  if (isAdminUser) {
    navItems.push({id: pages.ADMIN, label: 'Admin'});
    navItems.push({id: pages.PROFILE, label: 'Profil'});
  } else {
    // Pour les modérateurs (pas admin) : Modération
    if (isModeratorUser && !isAdminUser) {
      navItems.push({id: pages.MODERATION, label: 'Modération'});
    }
    // Pour les non-admins : Actualités et Programmes
    navItems.push({id: pages.NEWS, label: 'Actualités'});
    navItems.push({id: pages.PROGRAMS, label: 'Programmes'});
    navItems.push({id: pages.PROFILE, label: 'Profil'});
  }

  return (
    <header>
      <div className="container" style={{display:'flex',alignItems:'center',justifyContent:'space-between',gap:12}}>
        <div className="brand">
          <div className="logo">C</div>
          <div>
            <div style={{fontWeight:800}}>CCC Étudiants</div>
            <div className="muted">Actualités universitaires</div>
          </div>
        </div>
        <nav>
          {navItems.map(it => (
            <button key={it.id} className={'nav-btn'+(current===it.id?' active':'')} onClick={()=>onNavigate(it.id)}>
              {it.label}
            </button>
          ))}
        </nav>
        <button className="nav-btn" onClick={onLogout}>Déconnexion</button>
      </div>
    </header>
  );
}


