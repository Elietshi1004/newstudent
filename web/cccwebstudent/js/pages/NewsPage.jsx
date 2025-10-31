function getFirstThumb(news) {
  if (!news || !news.attachments || !news.attachments.length) return '';
  const img = news.attachments.find(a => {
    const mime = a.mime || '';
    const f = String(a.file || '').toLowerCase();
    return mime.indexOf('image/') === 0 || f.endsWith('.jpg') || f.endsWith('.jpeg') || f.endsWith('.png') || f.endsWith('.gif') || f.endsWith('.webp');
  }) || news.attachments[0];
  return img && img.file ? img.file : '';
}

function NewsPage({ onSelect }) {
  const { data: programs } = useFetch(`/api/programs/`);
  const { data: subscriptions } = useFetch(`/api/subscriptions/`);
  const { data: news, loading } = useFetch(`/api/news/?moderator_approved=true`);
  const [programId, setProgramId] = React.useState('');
  const [year, setYear] = React.useState('');
  const [q, setQ] = React.useState('');

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

  return (
    <div className="container" style={{paddingTop: 20}}>
      <div className="card" style={{marginBottom: 16}}>
        <div className="section-title">Filtrer</div>
        <div className="filters">
          <select value={programId} onChange={e=>setProgramId(e.target.value)}>
            <option value="">Mes programmes</option>
            {(programs||[]).filter(p=>subscribedIds.has(p.id)).map(p => (
              <option key={p.id} value={p.id}>{p.name}</option>
            ))}
          </select>
          <select value={year} onChange={e=>setYear(e.target.value)}>
            <option value="">Toutes les années</option>
            {years.map(y => <option key={y} value={y}>{y}</option>)}
          </select>
          <input placeholder="Recherche..." value={q} onChange={e=>setQ(e.target.value)} />
        </div>
      </div>

      {loading ? (
        <div className="card">Chargement...</div>
      ) : (
        <div className="grid cards">
          {list.filter(n => {
            const pid = (typeof n.program === 'object' && n.program) ? n.program.id : n.program;
            return subscribedIds.size === 0 ? false : subscribedIds.has(pid);
          }).map(n => (
            <article key={n.id} className="card" style={{cursor:'pointer'}} onClick={()=>onSelect && onSelect(n)}>
              <div style={{display:'flex',justifyContent:'space-between',alignItems:'center',gap:8,marginBottom:8}}>
                <span className="chip program">{typeof n.program==='object' ? (n.program && n.program.name ? n.program.name : 'Programme') : (programIdToName.get(n.program) || 'Programme')}</span>
                <ImportanceChip importance={n.importance} />
              </div>
              {getFirstThumb(n) ? (
                <div style={{margin:'6px 0 10px'}}>
                  <img src={getFirstThumb(n)} alt="vignette" style={{width:'100%', height:160, objectFit:'cover', borderRadius:10, border:'1px solid #e5e7eb'}} />
                </div>
              ) : null}
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


