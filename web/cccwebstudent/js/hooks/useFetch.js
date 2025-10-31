function useFetch(url) {
  const [data, setData] = React.useState(null);
  const [loading, setLoading] = React.useState(false);
  const [error, setError] = React.useState('');
  React.useEffect(() => {
    let mounted = true;
    async function run() {
      setLoading(true); setError('');
      try {
        const res = await authFetch(url);
        const json = await res.json();
        const list = Array.isArray(json) ? json : (json.results || []);
        if (mounted) setData(list);
      } catch (e) {
        if (mounted) setError('Erreur de chargement');
      } finally { if (mounted) setLoading(false); }
    }
    run();
    return () => { mounted = false; };
  }, [url, auth.access]);
  return { data, loading, error };
}


