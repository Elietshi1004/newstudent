function MyPublicationsPage({ onSelect, onBack, onCreate }) {
  const userId = (typeof window !== 'undefined' && window.authUserId) ? window.authUserId() : 0;
  const { data: news, loading } = useFetch(userId ? `/api/news/?author_id=${userId}&moderator_approved=true` : `/api/news/?author_id=0`);
  const { data: programs } = useFetch('/api/programs/');
  const [viewsStats, setViewsStats] = React.useState([]);
  const [loadingStats, setLoadingStats] = React.useState(false);
  const [statsError, setStatsError] = React.useState('');
  const [isStatsExpanded, setIsStatsExpanded] = React.useState(true);

  const programIdToName = React.useMemo(() => {
    const map = new Map();
    (programs || []).forEach(p => { map.set(p.id, p.name); });
    return map;
  }, [programs]);

  const resolveProgramName = React.useCallback((newsItem) => {
    if (!newsItem) return 'Programme';
    if (typeof newsItem.program === 'object' && newsItem.program) {
      if (newsItem.program.name) return newsItem.program.name;
      if (newsItem.program.id) {
        return programIdToName.get(newsItem.program.id) || 'Programme';
      }
    }
    const pid = newsItem.program_id || newsItem.program;
    if (pid != null) {
      return programIdToName.get(pid) || `Programme ${pid}`;
    }
    return 'Programme';
  }, [programIdToName]);

  const fetchStats = React.useCallback(async () => {
    if (!Array.isArray(news) || news.length === 0) {
      setViewsStats([]);
      return;
    }
    setLoadingStats(true);
    setStatsError('');
    try {
      const res = await authFetch('/api/news/views/');
      if (!res.ok) throw new Error('Impossible de charger les statistiques');
      const data = await res.json();
      const statsList = Array.isArray(data) ? data : [];
      const authorIds = new Set(news.map(n => n.id));
      const filtered = statsList.filter(stat => authorIds.has(stat.id));
      filtered.sort((a, b) => (b.views_count || 0) - (a.views_count || 0));
      setViewsStats(filtered);
    } catch (e) {
      console.error(e);
      setStatsError(e.message || 'Erreur lors du chargement des statistiques');
      setViewsStats([]);
    } finally {
      setLoadingStats(false);
    }
  }, [news]);

  React.useEffect(() => {
    if (Array.isArray(news)) {
      fetchStats();
    }
  }, [news, fetchStats]);

  return (
    <div className="container" style={{paddingTop: 20}}>
      <div className="my-publications-toolbar">
        <button className="nav-btn" onClick={onBack}>&larr; Retour</button>
        <div className="my-publications-actions">
          <div className="section-title" style={{marginTop: 0}}>Mes publications</div>
          {onCreate && (
            <button className="nav-btn" onClick={onCreate}>+ Créer une news</button>
          )}
        </div>
      </div>
      {Array.isArray(news) && news.length > 0 && (
        <div className={`news-views-panel${isStatsExpanded ? '' : ' collapsed'}`} style={{marginBottom:24}}>
          <div className="news-views-header">
            <div>
              <h2>Statistiques de vues</h2>
              <p>Nombre de lectures sur vos actualités publiées</p>
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
                onClick={fetchStats}
                disabled={loadingStats}
              >
                {loadingStats ? 'Actualisation…' : 'Rafraîchir'}
              </button>
            </div>
          </div>
          {isStatsExpanded && (
            <React.Fragment>
              {statsError && <div className="news-views-error">{statsError}</div>}
              {!loadingStats && !statsError && viewsStats.length === 0 && (
                <div className="news-views-empty">Aucune vue enregistrée pour vos publications.</div>
              )}
              <div className="news-views-grid">
                {viewsStats.map(stat => (
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
      {loading ? (
        <div className="card">Chargement…</div>
      ) : (
        <div className="grid cards">
          {(news || []).length === 0 ? (
            <div className="card">Aucune publication trouvée.</div>
          ) : (news || []).map(n => (
            <article key={n.id} className="card" style={{cursor:'pointer'}} onClick={()=>onSelect && onSelect(n)}>
              <div style={{display:'flex',justifyContent:'space-between',alignItems:'center',gap:8,marginBottom:8}}>
                <span className="chip program">{resolveProgramName(n)}</span>
                <ImportanceChip importance={n.importance} />
              </div>
              <h3 style={{margin:'6px 0 8px',fontSize:18}}>{n.title_final || n.title_draft || 'Sans titre'}</h3>
              <p className="muted" style={{margin:'0 0 10px'}}>
                {(n.content_final || n.content_draft || '').slice(0,160)}{(n.content_final||n.content_draft||'').length>160?'…':''}
              </p>
              <div className="muted">{new Date(n.written_at).toLocaleDateString('fr-FR')}</div>
            </article>
          ))}
        </div>
      )}
    </div>
  );
}


window.MyPublicationsPage = MyPublicationsPage;


