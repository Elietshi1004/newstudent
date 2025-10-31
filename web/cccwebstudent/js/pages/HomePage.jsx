function HomePage({ onSelect }) {
  return (
    <div className="container" style={{paddingTop: 20}}>
      <div className="grid" style={{gridTemplateColumns: '1.2fr .8fr'}}>
        <div>
          <div className="section-title">Dernières actualités</div>
          <NewsPage onSelect={onSelect} />
        </div>
        <div className="grid" style={{gap:12}}>
          <div className="card">
            <div className="section-title">À propos</div>
            <p className="muted">Plateforme d'informations pour étudiants — Kinshasa.</p>
          </div>
          <div className="card">
            <div className="section-title">Liens utiles</div>
            <ul className="muted" style={{margin:0,paddingLeft:18}}>
              <li>Programmes</li>
              <li>Règlement</li>
              <li>Contact</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}


