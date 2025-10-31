function Placeholder({ title, children }) {
  return (
    <div className="container" style={{paddingTop: 20}}>
      <div className="section-title">{title}</div>
      <div className="card">{children || 'Bientôt disponible'}</div>
    </div>
  );
}


