function getFirstThumb(news) {
  if (!news || !news.attachments || !news.attachments.length) return '';
  const img = news.attachments.find(a => {
    const mime = a.mime || '';
    const f = String(a.file || '').toLowerCase();
    return mime.indexOf('image/') === 0 || f.endsWith('.jpg') || f.endsWith('.jpeg') || f.endsWith('.png') || f.endsWith('.gif') || f.endsWith('.webp');
  }) || news.attachments[0];
  return img && img.file ? img.file : '';
}

function NewsPage({ onSelect, canViewStats = false }) {
  const { data: programs } = useFetch(`/api/programs/`);
  const { data: subscriptions } = useFetch(`/api/subscriptions/`);
  const { data: news, loading } = useFetch(`/api/news/?moderator_approved=true`);
  const [programId, setProgramId] = React.useState('');
  const [year, setYear] = React.useState('');
  const [q, setQ] = React.useState('');
  const [unreadNewsIds, setUnreadNewsIds] = React.useState(new Set());
  const [showUnreadOnly, setShowUnreadOnly] = React.useState(false);
  const [viewsStats, setViewsStats] = React.useState([]);
  const [loadingStats, setLoadingStats] = React.useState(false);
  const [statsError, setStatsError] = React.useState('');
  const [isStatsExpanded, setIsStatsExpanded] = React.useState(true);

  // Charger les news non lues
  const loadUnreadNews = React.useCallback(async () => {
    const unread = await newsViews.fetchUnreadNews();
    setUnreadNewsIds(new Set(unread.map(n => n.id)));
  }, []);

  React.useEffect(() => {
    let mounted = true;
    async function loadUnread() {
      await loadUnreadNews();
    }
    loadUnread();
    return () => { mounted = false; };
  }, [news, loadUnreadNews]);

  // Recharger les news non lues quand la page devient visible (après retour de détail)
  React.useEffect(() => {
    const handleVisibilityChange = () => {
      if (!document.hidden) {
        loadUnreadNews();
      }
    };
    document.addEventListener('visibilitychange', handleVisibilityChange);
    return () => document.removeEventListener('visibilitychange', handleVisibilityChange);
  }, [loadUnreadNews]);

  const programIdToName = React.useMemo(() => {
    const map = new Map();
    (programs || []).forEach(p => { map.set(p.id, p.name); });
    return map;
  }, [programs]);

  const subscribedIds = React.useMemo(() => {
    const set = new Set();
    (subscriptions || []).forEach(s => {
      const pid = (typeof s.program === 'object' && s.program) ? s.program.id : s.program;
      if (pid) set.add(pid);
    });
    return set;
  }, [subscriptions]);

  const list = React.useMemo(() => {
    if (!news) return [];
    let arr = news;
    if (programId) {
      arr = arr.filter(n => {
        const prog = (typeof n.program === 'object' && n.program) ? n.program.id : n.program;
        return String(prog) === programId;
      });
    }
    if (year) {
      arr = arr.filter(n => new Date(n.written_at).getFullYear() === Number(year));
    }
    if (q.trim()) {
      const k = q.toLowerCase();
      arr = arr.filter(n =>
        (n.title_final || n.title_draft || '').toLowerCase().includes(k) ||
        (n.content_final || n.content_draft || '').toLowerCase().includes(k)
      );
    }
    return arr;
  }, [news, programId, year, q]);

  const years = React.useMemo(() => {
    if (!news) return [];
    return [...new Set(news.map(n => new Date(n.written_at).getFullYear()))].sort((a,b)=>b-a);
  }, [news]);

  const unreadCount = unreadNewsIds.size;

  const sortedStats = React.useMemo(() => {
    return [...viewsStats].sort((a, b) => (b.views_count || 0) - (a.views_count || 0));
  }, [viewsStats]);

  const fetchViewStats = React.useCallback(async () => {
    if (!canViewStats) return;
    setLoadingStats(true);
    setStatsError('');
    try {
      const res = await authFetch(`/api/news/views/`);
      if (!res.ok) {
        throw new Error('Impossible de charger les statistiques de vues');
      }
      const data = await res.json();
      setViewsStats(Array.isArray(data) ? data : []);
    } catch (e) {
      console.error(e);
      setStatsError(e.message || 'Erreur lors du chargement des statistiques');
      setViewsStats([]);
    } finally {
      setLoadingStats(false);
    }
  }, [canViewStats]);

  React.useEffect(() => {
    if (!canViewStats) {
      setViewsStats([]);
      setStatsError('');
      setLoadingStats(false);
      return;
    }
    fetchViewStats();
  }, [canViewStats, fetchViewStats, news]);

  const filteredList = React.useMemo(() => {
    return list.filter(n => {
      const pid = (typeof n.program === 'object' && n.program) ? n.program.id : n.program;
      if (subscribedIds.size === 0 || !subscribedIds.has(pid)) {
        return false;
      }
      if (showUnreadOnly && !unreadNewsIds.has(n.id)) {
        return false;
      }
      return true;
    });
  }, [list, subscribedIds, showUnreadOnly, unreadNewsIds]);

  // Trier par importance puis date
  const sortedList = React.useMemo(() => {
    const importanceOrder = { 'urgente': 0, 'importante': 1, 'moyenne': 2, 'faible': 3 };
    return [...filteredList].sort((a, b) => {
      const impA = importanceOrder[a.importance] || 3;
      const impB = importanceOrder[b.importance] || 3;
      if (impA !== impB) return impA - impB;
      return new Date(b.written_at) - new Date(a.written_at);
    });
  }, [filteredList]);

  return (
    <div className="news-page-container">
      {/* Header avec titre */}
      <div className="news-page-header">
        <h1 className="news-page-title">
          <span className="news-page-icon">📰</span>
          Toutes les actualités
        </h1>
        <p className="news-page-subtitle">
          Explorez toutes les actualités de vos programmes
        </p>
      </div>

      {/* Filtres modernes */}
      <div className="news-filters-modern">
        <div className="filter-group">
          <label className="filter-label">🔍 Recherche</label>
          <input 
            type="text" 
            className="filter-input-search"
            placeholder="Rechercher une actualité..." 
            value={q} 
            onChange={e=>setQ(e.target.value)} 
          />
        </div>
        <div className="filter-group">
          <label className="filter-label">📚 Programme</label>
          <select 
            className="filter-select"
            value={programId} 
            onChange={e=>setProgramId(e.target.value)}
          >
            <option value="">Tous les programmes</option>
            {(programs||[]).filter(p=>subscribedIds.has(p.id)).map(p => (
              <option key={p.id} value={p.id}>{p.name}</option>
            ))}
          </select>
        </div>
        <div className="filter-group">
          <label className="filter-label">📅 Année</label>
          <select 
            className="filter-select"
            value={year} 
            onChange={e=>setYear(e.target.value)}
          >
            <option value="">Toutes les années</option>
            {years.map(y => <option key={y} value={y}>{y}</option>)}
          </select>
        </div>
        <div className="filter-group">
          <label className="filter-label">👀 Statut</label>
          <button
            type="button"
            className={`filter-chip${showUnreadOnly ? ' active' : ''}`}
            onClick={() => setShowUnreadOnly(v => !v)}
          >
            <span className="filter-chip-icon">📬</span>
            <span>Non lues</span>
            {unreadCount > 0 && (
              <span className="filter-chip-badge">
                {unreadCount > 99 ? '99+' : unreadCount}
              </span>
            )}
          </button>
        </div>
      </div>

      {/* Compteur de résultats */}
      {!loading && sortedList.length > 0 && (
        <div className="news-results-count">
          <span>{sortedList.length} actualité{sortedList.length > 1 ? 's' : ''} trouvée{sortedList.length > 1 ? 's' : ''}</span>
        </div>
      )}

      {/* Statistiques de vues */}
      {canViewStats && (
        <div className={`news-views-panel${isStatsExpanded ? '' : ' collapsed'}`}>
          <div className="news-views-header">
            <div>
              <h2>Statistiques de vues</h2>
              <p>Nombre total de lectures pour les actualités publiées</p>
            </div>
            <div className="news-views-actions">
              <button
                type="button"
                className="news-views-toggle"
                onClick={() => setIsStatsExpanded(v => !v)}
              >
                {isStatsExpanded ? 'Masquer' : 'Afficher'}
              </button>
              <button
                type="button"
                className="news-views-refresh"
                onClick={fetchViewStats}
                disabled={loadingStats}
              >
                {loadingStats ? 'Actualisation…' : 'Rafraîchir'}
              </button>
            </div>
          </div>
          {isStatsExpanded && (
            <React.Fragment>
              {statsError && <div className="news-views-error">{statsError}</div>}
              {!loadingStats && !statsError && sortedStats.length === 0 && (
                <div className="news-views-empty">Aucune vue enregistrée pour le moment.</div>
              )}
              <div className="news-views-grid">
                {sortedStats.map(stat => (
                  <div key={stat.id} className="news-views-card">
                    <div className="news-views-count">{stat.views_count != null ? stat.views_count : 0}</div>
                    <div className="news-views-meta">
                      <span className="news-views-label">vues</span>
                      <h3 className="news-views-title">{stat.title_final || 'Actualité'}</h3>
                    </div>
                  </div>
                ))}
              </div>
            </React.Fragment>
          )}
        </div>
      )}

      {/* Loading */}
      {loading ? (
        <div className="news-loading">
          <div className="spinner"></div>
          <p>Chargement des actualités...</p>
        </div>
      ) : sortedList.length === 0 ? (
        <div className="news-empty-state">
          <div className="empty-icon">📭</div>
          <h3>Aucune actualité trouvée</h3>
          <p>Essayez de modifier vos filtres ou abonnez-vous à plus de programmes.</p>
        </div>
      ) : (
        <div className="news-grid-modern">
          {sortedList.map(n => {
            const isUnread = unreadNewsIds.has(n.id);
            const thumb = getFirstThumb(n);
            return (
              <article 
                key={n.id} 
                className="news-card-modern" 
                onClick={()=>onSelect && onSelect(n)}
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
                      {typeof n.program==='object' ? 
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
                        month: 'short',
                        year: 'numeric'
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
  );
}

if (typeof window !== 'undefined') {
  window.NewsPage = NewsPage;
}


