function getFirstImage(news) {
  if (!news || !news.attachments || !news.attachments.length) return '';
  const img = news.attachments.find(a => {
    const mime = a.mime || '';
    const f = String(a.file || '').toLowerCase();
    return mime.indexOf('image/') === 0 || f.endsWith('.jpg') || f.endsWith('.jpeg') || f.endsWith('.png') || f.endsWith('.gif') || f.endsWith('.webp');
  }) || news.attachments[0];
  return img && img.file ? img.file : '';
}

function NewsDetail({ news, onBack }) {
  if (!news) return null;
  const img = getFirstImage(news);
  const title = news.title_final || news.title_draft || 'Sans titre';
  const content = news.content_final || news.content_draft || '';
  const [progName, setProgName] = React.useState(typeof news.program === 'object' && news.program ? (news.program.name || 'Programme') : '');
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
    <div className="container" style={{paddingTop:20}}>
      <button className="nav-btn" onClick={onBack}>&larr; Retour</button>
      <div className="card" style={{marginTop:12}}>
        <div style={{display:'flex', gap:10, alignItems:'center', marginBottom:10}}>
          <span className="chip program">{programName}</span>
          <ImportanceChip importance={news.importance} />
        </div>
        {img ? (
          <div style={{margin:'8px 0 12px'}}>
            <img src={img} alt="illustration" style={{width:'100%', height:240, objectFit:'cover', borderRadius:12, border:'1px solid #e5e7eb'}} />
          </div>
        ) : null}
        <h2 style={{margin:'6px 0 12px'}}>{title}</h2>
        <div className="muted" style={{marginBottom:12}}>{new Date(news.written_at).toLocaleString('fr-FR')}</div>
        <p style={{whiteSpace:'pre-wrap', lineHeight:1.6}}>{content}</p>
      </div>
    </div>
  );
}


