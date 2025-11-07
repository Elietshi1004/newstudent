function Footer({ onNavigate }) {
  return (
    <footer className="home-footer">
      <div className="footer-content">
        <div className="footer-section">
          <h3 className="footer-title">Plateforme CCC Étudiants</h3>
          <p className="footer-description">
            Votre source d'informations pour rester connecté avec votre communauté étudiante.
          </p>
        </div>
        
        <div className="footer-section">
          <h4 className="footer-heading">Navigation</h4>
          <ul className="footer-links">
            <li><a href="#" onClick={(e) => { e.preventDefault(); if (onNavigate) onNavigate('HOME'); }}>Accueil</a></li>
            <li><a href="#" onClick={(e) => { e.preventDefault(); if (onNavigate) onNavigate('NEWS'); }}>Actualités</a></li>
            <li><a href="#" onClick={(e) => { e.preventDefault(); if (onNavigate) onNavigate('PROGRAMS'); }}>Programmes</a></li>
            <li><a href="#" onClick={(e) => { e.preventDefault(); if (onNavigate) onNavigate('PROFILE'); }}>Profil</a></li>
          </ul>
        </div>

        <div className="footer-section">
          <h4 className="footer-heading">Ressources</h4>
          <ul className="footer-links">
            <li><a href="#" onClick={(e) => { e.preventDefault(); }}>Aide</a></li>
            <li><a href="#" onClick={(e) => { e.preventDefault(); }}>Contact</a></li>
            <li><a href="#" onClick={(e) => { e.preventDefault(); }}>Règlement</a></li>
            <li><a href="#" onClick={(e) => { e.preventDefault(); }}>FAQ</a></li>
          </ul>
        </div>

        <div className="footer-section">
          <h4 className="footer-heading">Contact</h4>
          <ul className="footer-contact">
            <li>📍 Kinshasa, RDC</li>
            <li>📧 contact@ccc-etudiants.cd</li>
            <li>📱 +243 XXX XXX XXX</li>
          </ul>
        </div>
      </div>
      
      <div className="footer-bottom">
        <p>&copy; {new Date().getFullYear()} CCC Étudiants. Tous droits réservés.</p>
      </div>
    </footer>
  );
}

