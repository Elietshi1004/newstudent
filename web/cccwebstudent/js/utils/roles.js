// Gestion des rôles utilisateur pour l'application web
// Utilise /api/me/ qui retourne les rôles dans le champ 'roles'

// Récupérer les rôles de l'utilisateur depuis /api/me/
window.getUserRoles = async function() {
  try {
    const res = await authFetch('/api/me/');
    if (!res.ok) return [];
    const data = await res.json();
    // Debug: afficher ce qui est reçu
    console.log('Données /api/me/', data);
    if (!data || !data.roles) {
      console.log('Pas de rôles dans /api/me/');
      return [];
    }
    // Les rôles peuvent être un tableau d'objets {id, name} ou juste un tableau
    const roles = Array.isArray(data.roles) ? data.roles : [];
    console.log('Rôles extraits:', roles);
    return roles;
  } catch (e) {
    console.error('Erreur lors de la récupération des rôles:', e);
    return [];
  }
};

// Extraire les noms de rôles en minuscules pour comparaison
window.extractRoleNames = function(roles) {
  const names = [];
  if (!Array.isArray(roles)) return names;
  roles.forEach(r => {
    if (typeof r === 'string') {
      names.push(r.toLowerCase());
    } else if (r && typeof r === 'object') {
      if (r.name) names.push(String(r.name).toLowerCase());
      else if (r.role_name) names.push(String(r.role_name).toLowerCase());
    }
  });
  return names;
};

// Vérifier si l'utilisateur a un rôle spécifique (comparaison exacte)
window.hasRole = function(roleNames, roleName) {
  if (!Array.isArray(roleNames)) return false;
  const nameLower = String(roleName).toLowerCase();
  return roleNames.some(rn => rn === nameLower);
};

// Helpers spécifiques (hasRole fait déjà la comparaison en minuscules)
window.isAdmin = function(roleNames) {
  return hasRole(roleNames, 'Admin');
};

window.isModerator = function(roleNames) {
  return hasRole(roleNames, 'Modérateur') || hasRole(roleNames, 'Moderator');
};

window.isPubliant = function(roleNames) {
  return hasRole(roleNames, 'Publiant') || hasRole(roleNames, 'Publisher') || hasRole(roleNames, 'Auteur');
};

window.isStudent = function(roleNames) {
  return hasRole(roleNames, 'Étudiant') || hasRole(roleNames, 'Student');
};

