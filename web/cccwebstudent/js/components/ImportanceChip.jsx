function ImportanceChip({ importance }) {
  if (!importance) return null;
  const imp = String(importance).toLowerCase();
  if (imp === 'urgente') return <span className="chip urgent">Urgente</span>;
  if (imp === 'importante') return <span className="chip important">Importante</span>;
  return null;
}


