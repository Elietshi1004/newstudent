// Gérer les vues de news
window.newsViews = {
  // Marquer une news comme vue
  async markAsViewed(newsId) {
    try {
      const res = await authFetch(`/api/news/${newsId}/view/`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
      });
      return res.ok;
    } catch (e) {
      console.error('Erreur marquage news vue:', e);
      return false;
    }
  },

  // Récupérer les news non lues
  async fetchUnreadNews() {
    try {
      const res = await authFetch('/api/news/unread/');
      if (res.ok) {
        const data = await res.json();
        return Array.isArray(data) ? data : (data.results || []);
      }
      return [];
    } catch (e) {
      console.error('Erreur récupération news non lues:', e);
      return [];
    }
  }
};

