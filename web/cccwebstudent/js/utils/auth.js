const API_BASE = 'http://10.51.109.188:8000';
const TOKEN_KEY = 'ccc_access_token';
const REFRESH_KEY = 'ccc_refresh_token';

window.auth = {
  get access() { return localStorage.getItem(TOKEN_KEY) || ''; },
  get refresh() { return localStorage.getItem(REFRESH_KEY) || ''; },
  set: ({ access, refresh }) => { if (access) localStorage.setItem(TOKEN_KEY, access); if (refresh) localStorage.setItem(REFRESH_KEY, refresh); },
  clear: () => { localStorage.removeItem(TOKEN_KEY); localStorage.removeItem(REFRESH_KEY); }
};

window.authFetch = async function(path, options = {}) {
  const rel = path.startsWith('/api/') ? path : path.replace(API_BASE, '');
  const headers = Object.assign({ 'Content-Type': 'application/json' }, options.headers || {});
  if (auth.access) headers['Authorization'] = `Bearer ${auth.access}`;
  const doFetch = (h) => fetch(`${API_BASE}${rel}`, { ...options, headers: h || headers });
  let res = await doFetch();
  if (res.status === 401 && auth.refresh) {
    const rr = await fetch(`${API_BASE}/api/token/refresh/`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ refresh: auth.refresh })
    });
    if (rr.ok) {
      const rj = await rr.json();
      auth.set({ access: rj.access });
      const h2 = { ...headers, Authorization: `Bearer ${auth.access}` };
      res = await doFetch(h2);
    }
  }
  return res;
};

// Decode base64url helper
function b64urlDecode(input) {
  try {
    const pad = '='.repeat((4 - (input.length % 4)) % 4);
    const base64 = (input + pad).replace(/-/g, '+').replace(/_/g, '/');
    const str = atob(base64);
    try {
      return decodeURIComponent(escape(str));
    } catch (_) {
      return str;
    }
  } catch (_) {
    return '';
  }
}

// Extract user id from JWT access token (DRF SimpleJWT uses `user_id`)
window.authUserId = function() {
  try {
    const token = window.auth.access;
    if (!token || token.indexOf('.') === -1) return 0;
    const payloadSeg = token.split('.')[1];
    const json = b64urlDecode(payloadSeg);
    const payload = JSON.parse(json || '{}');
    return payload.user_id || (payload.user && payload.user.id) || payload.id || 0;
  } catch (_) {
    return 0;
  }
};


