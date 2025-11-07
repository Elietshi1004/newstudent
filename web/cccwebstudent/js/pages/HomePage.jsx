function getFirstThumb(news) {
  if (!news || !news.attachments || !news.attachments.length) return '';
  const img = news.attachments.find(a => {
    const mime = a.mime || '';
    const f = String(a.file || '').toLowerCase();
    return mime.indexOf('image/') === 0 || f.endsWith('.jpg') || f.endsWith('.jpeg') || f.endsWith('.png') || f.endsWith('.gif') || f.endsWith('.webp');
  }) || news.attachments[0];
  return img && img.file ? img.file : '';
}

function HomePage({ onSelect }) {
  const { data: programs } = useFetch(`/api/programs/`);
  const { data: subscriptions } = useFetch(`/api/subscriptions/`);
  const { data: news, loading } = useFetch(`/api/news/?moderator_approved=true`);
  const [unreadNewsIds, setUnreadNewsIds] = React.useState(new Set());

  const loadUnreadNews = React.useCallback(async () => {
    const unread = await newsViews.fetchUnreadNews();
    setUnreadNewsIds(new Set(unread.map(n => n.id)));
  }, []);

  React.useEffect(() => {
    if (news) loadUnreadNews();
  }, [news, loadUnreadNews]);

  const subscribedIds = React.useMemo(() => {
    const set = new Set();
    (subscriptions || []).forEach(s => {
      const pid = (typeof s.program === 'object' && s.program) ? s.program.id : s.program;
      if (pid) set.add(pid);
    });
    return set;
  }, [subscriptions]);

  const programIdToName = React.useMemo(() => {
    const map = new Map();
    (programs || []).forEach(p => { map.set(p.id, p.name); });
    return map;
  }, [programs]);

  // Filtrer les news par abonnements et trier par importance et date
  const filteredNews = React.useMemo(() => {
    if (!news) return [];
    let arr = news.filter(n => {
      const pid = (typeof n.program === 'object' && n.program) ? n.program.id : n.program;
      return subscribedIds.size === 0 ? false : subscribedIds.has(pid);
    });
    
    // Trier par importance puis date
    const importanceOrder = { 'urgente': 0, 'importante': 1, 'moyenne': 2, 'faible': 3 };
    arr.sort((a, b) => {
      const impA = importanceOrder[a.importance] || 3;
      const impB = importanceOrder[b.importance] || 3;
      if (impA !== impB) return impA - impB;
      return new Date(b.written_at) - new Date(a.written_at);
    });
    
    return arr;
  }, [news, subscribedIds]);

  const featuredNews = filteredNews[0];
  const otherNews = filteredNews.slice(1, 7);

  if (loading) {
    return (
      <div className="home-container">
        <div className="home-loading">
          <div className="spinner"></div>
          <p>Chargement des actualités...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="home-container">
      {/* Hero Section - News en vedette */}
      {featuredNews && (
        <div className="hero-section" onClick={() => onSelect && onSelect(featuredNews)}>
          {getFirstThumb(featuredNews) && (
            <div className="hero-image-wrapper">
              <img 
                src={getFirstThumb(featuredNews)} 
                alt="Featured" 
                className="hero-image"
              />
              <div className="hero-overlay"></div>
            </div>
          )}
          <div className="hero-content">
            <div className="hero-badges">
              <span className="hero-chip program">
                {typeof featuredNews.program === 'object' ? 
                  (featuredNews.program && featuredNews.program.name ? featuredNews.program.name : 'Programme') : 
                  (programIdToName.get(featuredNews.program) || 'Programme')}
              </span>
              <ImportanceChip importance={featuredNews.importance} />
              {unreadNewsIds.has(featuredNews.id) && (
                <span className="hero-chip new">Nouveau</span>
              )}
            </div>
            <h1 className="hero-title">
              {featuredNews.title_final || featuredNews.title_draft || 'Sans titre'}
            </h1>
            <p className="hero-excerpt">
              {(featuredNews.content_final || featuredNews.content_draft || '').slice(0, 200)}
              {(featuredNews.content_final || featuredNews.content_draft || '').length > 200 ? '…' : ''}
            </p>
            <div className="hero-meta">
              <span className="hero-date">
                {new Date(featuredNews.written_at).toLocaleDateString('fr-FR', { 
                  day: 'numeric', 
                  month: 'long', 
                  year: 'numeric' 
                })}
              </span>
            </div>
          </div>
        </div>
      )}

      {/* Section À propos de la plateforme */}
      <div className="home-section about-section">
        <div className="about-content">
          <div className="about-icon">🎓</div>
          <h2 className="about-title">À propos de la plateforme</h2>
          <p className="about-description">
            Bienvenue sur la plateforme d'informations pour étudiants de Kinshasa. 
            Notre mission est de vous tenir informé de toutes les actualités importantes 
            concernant vos programmes d'études, les événements du campus, les opportunités 
            d'emploi et bien plus encore.
          </p>
          <div className="about-features">
            <div className="about-feature">
              <span className="feature-icon">📢</span>
              <div>
                <h3>Actualités en temps réel</h3>
                <p>Recevez les dernières informations de vos programmes</p>
              </div>
            </div>
            <div className="about-feature">
              <span className="feature-icon">🔔</span>
              <div>
                <h3>Notifications personnalisées</h3>
                <p>Soyez alerté des news importantes qui vous concernent</p>
              </div>
            </div>
            <div className="about-feature">
              <span className="feature-icon">📚</span>
              <div>
                <h3>Gestion de programmes</h3>
                <p>Abonnez-vous aux programmes qui vous intéressent</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Section Actualités */}
      <div className="home-section">
        <div className="section-header">
          <div className="section-header-content">
            <h2 className="section-title-main">
              <span className="section-icon">📰</span>
              Dernières actualités
            </h2>
            <p className="section-subtitle">Restez informé de tout ce qui se passe</p>
          </div>
        </div>

        {filteredNews.length === 0 ? (
          <div className="empty-state">
            <div className="empty-icon">📭</div>
            <h3>Aucune actualité disponible</h3>
            <p>Abonnez-vous à des programmes pour voir leurs actualités ici.</p>
          </div>
        ) : (
          <div className="news-grid">
            {otherNews.map(n => {
              const isUnread = unreadNewsIds.has(n.id);
              const thumb = getFirstThumb(n);
              return (
                <article 
                  key={n.id} 
                  className="news-card-modern" 
                  onClick={() => onSelect && onSelect(n)}
                >
                  {isUnread && <div className="news-badge-unread"></div>}
                  
                  {thumb ? (
                    <div className="news-card-image">
                      <img src={thumb} alt="News" />
                      <div className="news-card-overlay"></div>
                      {(n.importance === 'urgente' || n.importance === 'importante') && (
                        <div className={`news-card-importance ${n.importance}`}>
                          {n.importance === 'urgente' ? '⚠️ Urgente' : '⭐ Importante'}
                        </div>
                      )}
                    </div>
                  ) : (
                    <div className="news-card-image-placeholder">
                      <span>📄</span>
                    </div>
                  )}
                  
                  <div className="news-card-content">
                    <div className="news-card-header">
                      <span className="news-card-program">
                        {typeof n.program === 'object' ? 
                          (n.program && n.program.name ? n.program.name : 'Programme') : 
                          (programIdToName.get(n.program) || 'Programme')}
                      </span>
                      {!thumb && <ImportanceChip importance={n.importance} />}
                    </div>
                    
                    <h3 className="news-card-title">
                      {n.title_final || n.title_draft || 'Sans titre'}
                    </h3>
                    
                    <p className="news-card-excerpt">
                      {(n.content_final || n.content_draft || '').slice(0, 120)}
                      {(n.content_final || n.content_draft || '').length > 120 ? '…' : ''}
                    </p>
                    
                    <div className="news-card-footer">
                      <span className="news-card-date">
                        {new Date(n.written_at).toLocaleDateString('fr-FR', { 
                          day: 'numeric', 
                          month: 'short' 
                        })}
                      </span>
                      <span className="news-card-arrow">→</span>
                    </div>
                  </div>
                </article>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}


