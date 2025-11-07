function CreateNewsPage({ onBack, onCreated }) {
  const { data: programs, loading: loadingPrograms } = useFetch('/api/programs/');
  const userId = (typeof window !== 'undefined' && window.authUserId) ? window.authUserId() : null;
  const [programId, setProgramId] = React.useState('');
  const [title, setTitle] = React.useState('');
  const [content, setContent] = React.useState('');
  const [importance, setImportance] = React.useState('moyenne');
  const [file, setFile] = React.useState(null);
  const [submitting, setSubmitting] = React.useState(false);
  const [error, setError] = React.useState('');
  const [success, setSuccess] = React.useState('');

  const importanceOptions = React.useMemo(() => [
    { id: 'faible', label: 'Faible', emoji: '🟢' },
    { id: 'moyenne', label: 'Moyenne', emoji: '🔵' },
    { id: 'importante', label: 'Importante', emoji: '🟡' },
    { id: 'urgente', label: 'Urgente', emoji: '🔴' }
  ], []);

  const handleFileChange = React.useCallback((e) => {
    const selected = e.target.files && e.target.files[0];
    if (!selected) {
      setFile(null);
      return;
    }
    const allowed = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (allowed.includes(selected.type)) {
      setFile(selected);
      setError('');
    } else {
      setError('Format de fichier non supporté. Utilisez JPG, PNG, GIF ou WEBP.');
    }
  }, []);

  const resetForm = React.useCallback(() => {
    setProgramId('');
    setTitle('');
    setContent('');
    setImportance('moyenne');
    setFile(null);
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (!programId) {
      setError('Veuillez sélectionner un programme.');
      return;
    }
    if (!title.trim()) {
      setError('Veuillez indiquer un titre.');
      return;
    }
    if (content.trim().length < 20) {
      setError('Le contenu doit contenir au moins 20 caractères.');
      return;
    }
    if (!userId) {
      setError('Impossible de déterminer votre profil. Veuillez vous reconnecter.');
      return;
    }

    setSubmitting(true);
    try {
      const payload = {
        program: Number(programId),
        title_draft: title.trim(),
        content_draft: content.trim(),
        importance,
        author: userId
      };

      const createRes = await authFetch('/api/news/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const createData = await createRes.json();
      if (!createRes.ok) {
        const detail = createData.detail || createData.error || 'Création impossible';
        throw new Error(detail);
      }

      const newsId = createData.id || (createData.news && createData.news.id);
      if (file && newsId) {
        const formData = new FormData();
        formData.append('news', String(newsId));
        formData.append('file', file);
        const headers = {};
        if (auth.access) headers['Authorization'] = `Bearer ${auth.access}`;
        const uploadRes = await fetch(`${API_BASE}/api/attachments/`, {
          method: 'POST',
          headers,
          body: formData
        });
        if (!uploadRes.ok) {
          console.warn('Upload image échoué:', await uploadRes.text());
        }
      }

      setSuccess('Actualité créée et soumise pour modération.');
      resetForm();
      if (typeof onCreated === 'function') {
        onCreated();
      }
    } catch (err) {
      console.error(err);
      setError(err.message || 'Erreur inattendue lors de la création');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="create-news-container">
      <div className="create-news-header">
        <button className="nav-btn" onClick={onBack}>&larr; Retour</button>
        <div>
          <h1>Créer une actualité</h1>
          <p>Proposez une nouvelle information à soumettre à la modération</p>
        </div>
      </div>

      <form className="create-news-form" onSubmit={handleSubmit}>
        {error && <div className="form-alert error">{error}</div>}
        {success && <div className="form-alert success">{success}</div>}

        <label className="form-label">Programme concerné</label>
        {loadingPrograms ? (
          <div className="form-loading">Chargement des programmes…</div>
        ) : (
          <select
            className="form-select"
            value={programId}
            onChange={e => setProgramId(e.target.value)}
            required
          >
            <option value="">Sélectionner un programme</option>
            {(programs || []).map(p => (
              <option key={p.id} value={p.id}>{p.name}</option>
            ))}
          </select>
        )}

        <label className="form-label">Titre</label>
        <input
          className="form-input"
          placeholder="Titre de l’actualité"
          value={title}
          onChange={e => setTitle(e.target.value)}
          required
        />

        <label className="form-label">Contenu</label>
        <textarea
          className="form-textarea"
          placeholder="Décrivez l’actualité en détail"
          rows={8}
          value={content}
          onChange={e => setContent(e.target.value)}
          required
        />

        <label className="form-label">Importance</label>
        <div className="importance-grid">
          {importanceOptions.map(opt => (
            <button
              key={opt.id}
              type="button"
              className={`importance-chip${importance === opt.id ? ' active' : ''}`}
              onClick={() => setImportance(opt.id)}
            >
              <span className="importance-emoji">{opt.emoji}</span>
              {opt.label}
            </button>
          ))}
        </div>

        <label className="form-label">Image (optionnelle)</label>
        <div className="file-upload">
          <input
            type="file"
            id="news-file-input"
            accept="image/*"
            onChange={handleFileChange}
          />
          <label htmlFor="news-file-input" className="file-upload-label">
            <span>Choisir une image</span>
            <small>JPG, PNG, GIF, WEBP</small>
          </label>
          <div className="file-upload-name">
            {file ? file.name : 'Aucun fichier sélectionné'}
          </div>
        </div>

        <button className="submit-btn" type="submit" disabled={submitting || loadingPrograms}>
          {submitting ? 'Envoi en cours…' : 'Soumettre pour modération'}
        </button>
      </form>

      <div className="create-news-hint">
        <strong>Important :</strong> votre publication sera revue par l’équipe de modération avant diffusion.
      </div>
    </div>
  );
}

window.CreateNewsPage = CreateNewsPage;

