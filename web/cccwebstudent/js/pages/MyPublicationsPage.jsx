function MyPublicationsPage({ onSelect, onBack }) {
  const userId = (typeof window !== 'undefined' && window.authUserId) ? window.authUserId() : 0;
  const { data: news, loading } = useFetch(userId ? `/api/news/?author_id=${userId}&moderator_approved=true` : `/api/news/?author_id=0`);

  return (
    <div className="container" style={{paddingTop: 20}}>
      <button className="nav-btn" onClick={onBack}>&larr; Retour</button>
      <div className="section-title" style={{marginTop: 10}}>Mes publications</div>
      {loading ? (
        <div className="card">Chargement…</div>
      ) : (
        <div className="grid cards">
          {(news || []).length === 0 ? (
            <div className="card">Aucune publication trouvée.</div>
          ) : (news || []).map(n => (
            <article key={n.id} className="card" style={{cursor:'pointer'}} onClick={()=>onSelect && onSelect(n)}>
              <div style={{display:'flex',justifyContent:'space-between',alignItems:'center',gap:8,marginBottom:8}}>
                <span className="chip program">{typeof n.program==='object' ? (n.program && n.program.name ? n.program.name : 'Programme') : `Programme ${n.program}`}</span>
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


