function ModerationPage() {
  const [filterStatus, setFilterStatus] = React.useState('En attente');
  const [currentPage, setCurrentPage] = React.useState(1);
  const [pageSize] = React.useState(10);
  const [news, setNews] = React.useState([]);
  const [loading, setLoading] = React.useState(false);
  const [programs, setPrograms] = React.useState([]);
  const [showApproveModal, setShowApproveModal] = React.useState(false);
  const [showRejectModal, setShowRejectModal] = React.useState(false);
  const [selectedNews, setSelectedNews] = React.useState(null);
  const [titleEdit, setTitleEdit] = React.useState('');
  const [contentEdit, setContentEdit] = React.useState('');
  const [comment, setComment] = React.useState('');
  const [rejectReason, setRejectReason] = React.useState('');

  // Charger les programmes pour résoudre les noms
  React.useEffect(() => {
    async function loadPrograms() {
      try {
        const res = await authFetch('/api/programs/');
        if (res.ok) {
          const data = await res.json();
          const progs = Array.isArray(data) ? data : (data.results || []);
          setPrograms(progs);
        }
      } catch (_) {}
    }
    loadPrograms();
  }, []);

  // Charger les news selon le filtre
  React.useEffect(() => {
    loadNews();
  }, [filterStatus]);

  async function loadNews() {
    setLoading(true);
    try {
      let endpoint = '/api/news/pending/';
      if (filterStatus === 'Approuvées') endpoint = '/api/news/approved/';
      else if (filterStatus === 'Refusées') endpoint = '/api/news/rejected/';

      const res = await authFetch(endpoint);
      if (res.ok) {
        const data = await res.json();
        const list = Array.isArray(data) ? data : (data.results || []);
        // Trier par date (plus récent en premier)
        list.sort((a, b) => {
          const dateA = new Date(a.written_at || a.created_at || 0);
          const dateB = new Date(b.written_at || b.created_at || 0);
          return dateB - dateA;
        });
        setNews(list);
        setCurrentPage(1);
      }
    } catch (e) {
      console.error('Erreur chargement news:', e);
    } finally {
      setLoading(false);
    }
  }

  function getProgramName(programId) {
    if (typeof programId === 'object' && programId && programId.name) return programId.name;
    const prog = programs.find(p => p.id === programId);
    return prog ? prog.name : `Programme #${programId}`;
  }

  function formatDate(dateStr) {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 60) return `Il y a ${diffMins}min`;
    if (diffHours < 24) return `Il y a ${diffHours}h`;
    return `${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()}`;
  }

  function getStatusBadge(newsItem) {
    const isPending = !newsItem.moderator_approved && !newsItem.invalidated;
    const isApproved = newsItem.moderator_approved;
    const isRejected = newsItem.invalidated;

    if (isPending) {
      return <span className="chip" style={{background:'#f59e0b', color:'#fff'}}>En attente</span>;
    } else if (isApproved) {
      return <span className="chip" style={{background:'#10b981', color:'#fff'}}>Approuvée</span>;
    } else {
      return <span className="chip" style={{background:'#ef4444', color:'#fff'}}>Refusée</span>;
    }
  }

  function getPendingCount() {
    return news.filter(n => !n.moderator_approved && !n.invalidated).length;
  }

  const filteredNews = React.useMemo(() => {
    if (filterStatus === 'En attente') {
      return news.filter(n => !n.moderator_approved && !n.invalidated);
    } else if (filterStatus === 'Approuvées') {
      return news.filter(n => n.moderator_approved);
    } else if (filterStatus === 'Refusées') {
      return news.filter(n => n.invalidated);
    }
    return news;
  }, [news, filterStatus]);

  const totalPages = Math.max(1, Math.ceil(filteredNews.length / pageSize));
  const startIdx = (currentPage - 1) * pageSize;
  const endIdx = startIdx + pageSize;
  const pagedNews = filteredNews.slice(startIdx, endIdx);

  async function handleApprove(newsItem) {
    setSelectedNews(newsItem);
    setTitleEdit(newsItem.title_draft || newsItem.title_final || '');
    setContentEdit(newsItem.content_draft || newsItem.content_final || '');
    setComment('');
    setShowApproveModal(true);
  }

  async function confirmApprove() {
    if (!selectedNews) return;
    setLoading(true);
    try {
      // 1. Mettre à jour title_final et content_final
      const updateRes = await authFetch(`/api/news/${selectedNews.id}/update/`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title_final: titleEdit.trim(),
          content_final: contentEdit.trim(),
        })
      });
      if (!updateRes.ok) {
        alert('Erreur lors de la mise à jour de la news');
        return;
      }

      // 2. Obtenir l'ID du modérateur depuis /api/me/
      let moderatorId = null;
      try {
        const meRes = await authFetch('/api/me/');
        if (meRes.ok) {
          const meData = await meRes.json();
          moderatorId = meData.id;
        }
      } catch (_) {}

      if (!moderatorId) {
        alert('Impossible de récupérer l\'ID du modérateur');
        return;
      }

      // 3. Créer la modération
      const moderationBody = {
        news: selectedNews.id,
        approved: true,
        moderator: moderatorId,
      };
      if (comment.trim()) moderationBody.comment = comment.trim();

      const modRes = await authFetch('/api/moderations/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(moderationBody)
      });

      if (!modRes.ok) {
        alert('Erreur lors de l\'approbation');
        return;
      }

      // 4. Mettre à jour la news (moderator_approved, etc.)
      const finalUpdateRes = await authFetch(`/api/news/${selectedNews.id}/update/`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          moderator_approved: true,
          moderator: moderatorId,
          moderated_at: new Date().toISOString(),
          invalidated: false,
          invalidation_reason: null,
        })
      });

      setShowApproveModal(false);
      await loadNews();
    } catch (e) {
      console.error('Erreur approbation:', e);
      alert('Erreur lors de l\'approbation');
    } finally {
      setLoading(false);
    }
  }

  async function handleReject(newsItem) {
    setSelectedNews(newsItem);
    setRejectReason('');
    setShowRejectModal(true);
  }

  async function confirmReject() {
    if (!selectedNews || !rejectReason.trim()) {
      alert('Veuillez indiquer une raison');
      return;
    }
    setLoading(true);
    try {
      // Obtenir l'ID du modérateur
      let moderatorId = null;
      try {
        const meRes = await authFetch('/api/me/');
        if (meRes.ok) {
          const meData = await meRes.json();
          moderatorId = meData.id;
        }
      } catch (_) {}

      if (!moderatorId) {
        alert('Impossible de récupérer l\'ID du modérateur');
        return;
      }

      // Créer la modération
      const moderationBody = {
        news: selectedNews.id,
        approved: false,
        moderator: moderatorId,
        comment: rejectReason.trim(),
      };

      const modRes = await authFetch('/api/moderations/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(moderationBody)
      });

      if (!modRes.ok) {
        alert('Erreur lors du refus');
        return;
      }

      // Mettre à jour la news
      const updateRes = await authFetch(`/api/news/${selectedNews.id}/update/`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          moderator_approved: false,
          moderator: moderatorId,
          moderated_at: new Date().toISOString(),
          invalidated: true,
          invalidation_reason: rejectReason.trim(),
        })
      });

      setShowRejectModal(false);
      await loadNews();
    } catch (e) {
      console.error('Erreur refus:', e);
      alert('Erreur lors du refus');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="container" style={{paddingTop: 20}}>
      <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom:16}}>
        <div className="section-title">Modération</div>
        {getPendingCount() > 0 && (
          <span className="chip" style={{background:'#ef4444', color:'#fff'}}>
            {getPendingCount()}
          </span>
        )}
      </div>

      {/* Filtres */}
      <div className="filters" style={{marginBottom:16}}>
        {['En attente', 'Approuvées', 'Refusées'].map(status => (
          <button
            key={status}
            className={'nav-btn' + (filterStatus === status ? ' active' : '')}
            onClick={() => setFilterStatus(status)}
          >
            {status}
          </button>
        ))}
      </div>

      {/* Liste des news */}
      {loading ? (
        <div className="card">Chargement…</div>
      ) : pagedNews.length === 0 ? (
        <div className="card">
          <div style={{textAlign:'center', padding:20}}>
            <div className="muted">
              {filterStatus === 'En attente' ? 'Aucune news en attente' : 'Aucune news'}
            </div>
          </div>
        </div>
      ) : (
        <div>
          <div className="grid cards">
            {pagedNews.map(n => (
              <div key={n.id} className="card">
                <div style={{display:'flex', justifyContent:'space-between', alignItems:'start', marginBottom:12}}>
                  <div style={{flex:1}}>
                    <div style={{fontWeight:700, marginBottom:8, fontSize:18}}>
                      {n.title_draft || n.title_final || 'Sans titre'}
                    </div>
                    {n.program && (
                      <span className="chip program">{getProgramName(n.program)}</span>
                    )}
                  </div>
                  {getStatusBadge(n)}
                </div>

                <div className="muted" style={{marginBottom:12, maxHeight:60, overflow:'hidden'}}>
                  {n.content_draft || n.content_final || 'Aucun contenu'}
                </div>

                <div style={{display:'flex', gap:16, fontSize:12, color:'#94a3b8', marginBottom:12}}>
                  <span>Auteur: {n.author_name || n.author || 'Inconnu'}</span>
                  <span>{formatDate(n.written_at || n.created_at)}</span>
                </div>

                {n.invalidation_reason && (
                  <div style={{padding:12, background:'#fee2e2', borderRadius:8, marginBottom:12, fontSize:12, color:'#991b1b'}}>
                    <strong>Raison:</strong> {n.invalidation_reason}
                  </div>
                )}

                {!n.moderator_approved && !n.invalidated && (
                  <div style={{display:'flex', gap:8, marginTop:12}}>
                    <button
                      className="nav-btn"
                      onClick={() => handleReject(n)}
                      style={{flex:1, borderColor:'#ef4444', color:'#ef4444'}}
                    >
                      Refuser
                    </button>
                    <button
                      className="btn"
                      onClick={() => handleApprove(n)}
                      style={{flex:1, background:'#10b981'}}
                    >
                      Approuver
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>

          {/* Pagination */}
          {totalPages > 1 && (
            <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', marginTop:16, padding:'0 16px'}}>
              <span className="muted">Page {currentPage} / {totalPages}</span>
              <div style={{display:'flex', gap:8}}>
                <button
                  className="nav-btn"
                  onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                  disabled={currentPage === 1}
                >
                  Précédent
                </button>
                <button
                  className="nav-btn"
                  onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                  disabled={currentPage === totalPages}
                >
                  Suivant
                </button>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Modal d'approbation */}
      {showApproveModal && selectedNews && (
        <div style={{
          position:'fixed', top:0, left:0, right:0, bottom:0, background:'rgba(0,0,0,0.5)',
          display:'flex', alignItems:'center', justifyContent:'center', zIndex:1000,
          padding:16
        }}>
          <div className="card" style={{maxWidth:600, width:'100%', maxHeight:'90vh', overflow:'auto'}}>
            <div style={{fontWeight:700, marginBottom:16, fontSize:18}}>
              Modifier avant approbation
            </div>
            <div style={{marginBottom:12}}>
              <label style={{display:'block', marginBottom:4, fontWeight:600}}>Titre (brouillon)</label>
              <input
                type="text"
                value={titleEdit}
                onChange={e => setTitleEdit(e.target.value)}
                style={{width:'100%', padding:8, border:'1px solid #e5e7eb', borderRadius:8}}
              />
            </div>
            <div style={{marginBottom:12}}>
              <label style={{display:'block', marginBottom:4, fontWeight:600}}>Contenu (brouillon)</label>
              <textarea
                value={contentEdit}
                onChange={e => setContentEdit(e.target.value)}
                rows={5}
                style={{width:'100%', padding:8, border:'1px solid #e5e7eb', borderRadius:8, resize:'vertical'}}
              />
            </div>
            <div style={{marginBottom:16}}>
              <label style={{display:'block', marginBottom:4, fontWeight:600}}>Commentaire (optionnel)</label>
              <textarea
                value={comment}
                onChange={e => setComment(e.target.value)}
                rows={3}
                style={{width:'100%', padding:8, border:'1px solid #e5e7eb', borderRadius:8, resize:'vertical'}}
              />
            </div>
            <div style={{display:'flex', gap:12}}>
              <button className="nav-btn" onClick={() => setShowApproveModal(false)} style={{flex:1}}>
                Annuler
              </button>
              <button className="btn" onClick={confirmApprove} style={{flex:1, background:'#10b981'}} disabled={loading}>
                {loading ? 'En cours...' : 'Approuver'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal de refus */}
      {showRejectModal && selectedNews && (
        <div style={{
          position:'fixed', top:0, left:0, right:0, bottom:0, background:'rgba(0,0,0,0.5)',
          display:'flex', alignItems:'center', justifyContent:'center', zIndex:1000,
          padding:16
        }}>
          <div className="card" style={{maxWidth:500, width:'100%'}}>
            <div style={{fontWeight:700, marginBottom:16, fontSize:18}}>
              Refuser la news
            </div>
            <div style={{marginBottom:16}}>
              <div className="muted" style={{marginBottom:8}}>Veuillez indiquer la raison du refus :</div>
              <textarea
                value={rejectReason}
                onChange={e => setRejectReason(e.target.value)}
                placeholder="Raison du refus..."
                rows={3}
                style={{width:'100%', padding:8, border:'1px solid #e5e7eb', borderRadius:8, resize:'vertical'}}
              />
            </div>
            <div style={{display:'flex', gap:12}}>
              <button className="nav-btn" onClick={() => setShowRejectModal(false)} style={{flex:1}}>
                Annuler
              </button>
              <button
                className="btn"
                onClick={confirmReject}
                style={{flex:1, background:'#ef4444'}}
                disabled={loading || !rejectReason.trim()}
              >
                {loading ? 'En cours...' : 'Refuser'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

