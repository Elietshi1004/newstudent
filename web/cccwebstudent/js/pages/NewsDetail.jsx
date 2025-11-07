function getFirstImage(news) {
  if (!news || !news.attachments || !news.attachments.length) return '';
  const img = news.attachments.find(a => {
    const mime = a.mime || '';
    const f = String(a.file || '').toLowerCase();
    return mime.indexOf('image/') === 0 || f.endsWith('.jpg') || f.endsWith('.jpeg') || f.endsWith('.png') || f.endsWith('.gif') || f.endsWith('.webp');
  }) || news.attachments[0];
  return img && img.file ? img.file : '';
}

function NewsDetail({ news, onBack, onNewsViewed }) {
  if (!news) return null;
  const img = getFirstImage(news);
  const title = news.title_final || news.title_draft || 'Sans titre';
  const content = news.content_final || news.content_draft || '';
  const [progName, setProgName] = React.useState(typeof news.program === 'object' && news.program ? (news.program.name || 'Programme') : '');
  
  // Marquer la news comme vue quand elle s'affiche
  React.useEffect(() => {
    if (news && news.moderator_approved && news.id) {
      newsViews.markAsViewed(news.id).then(() => {
        // Notifier le parent que la news a été vue
        if (onNewsViewed) onNewsViewed(news.id);
      });
    }
  }, [news, onNewsViewed]);

  React.useEffect(() => {
    if (!progName && news && news.program && typeof news.program !== 'object') {
      const id = news.program;
      (async () => {
        try {
          const res = await authFetch(`/api/programs/${id}/`);
          if (res.ok) {
            const p = await res.json();
            setProgName(p && p.name ? p.name : 'Programme');
          } else {
            setProgName('Programme');
          }
        } catch (_) {
          setProgName('Programme');
        }
      })();
    }
  }, [news, progName]);
  const programName = progName || (typeof news.program === 'object' && news.program ? (news.program.name || 'Programme') : 'Programme');
  
  return (
    <div className="news-detail-container">
      {/* Bouton retour */}
      <button className="news-detail-back-btn" onClick={onBack}>
        <span className="back-icon">←</span>
        <span>Retour</span>
      </button>

      {/* Article principal */}
      <article className="news-detail-article">
        {/* Header avec badges */}
        <div className="news-detail-header">
          <div className="news-detail-badges">
            <span className="news-detail-chip program">{programName}</span>
            <ImportanceChip importance={news.importance} />
          </div>
          <div className="news-detail-meta">
            <span className="news-detail-date-icon">📅</span>
            <span className="news-detail-date">
              {new Date(news.written_at).toLocaleDateString('fr-FR', { 
                weekday: 'long',
                day: 'numeric', 
                month: 'long',
                year: 'numeric'
              })}
            </span>
          </div>
        </div>

        {/* Image principale */}
        {img && (
          <div className="news-detail-image-wrapper">
            <img src={img} alt="Illustration" className="news-detail-image" />
          </div>
        )}

        {/* Titre */}
        <h1 className="news-detail-title">{title}</h1>

        {/* Contenu */}
        <div className="news-detail-content">
          <div className="news-detail-text" dangerouslySetInnerHTML={{__html: content.replace(/\n/g, '<br />')}} />
        </div>

        {/* Footer avec actions */}
        <div className="news-detail-footer">
          <div className="news-detail-share">
            <span className="share-label">Partager :</span>
            <button className="share-btn" title="Copier le lien">
              🔗
            </button>
          </div>
        </div>
      </article>
    </div>
  );
}


