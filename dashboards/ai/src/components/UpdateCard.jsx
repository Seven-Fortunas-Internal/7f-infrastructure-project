import './UpdateCard.css'

function UpdateCard({ update }) {
  const formatDate = (dateString) => {
    try {
      const date = new Date(dateString)
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    } catch {
      return dateString
    }
  }

  return (
    <article className="update-card">
      <div className="update-header">
        <span className="source-badge">{update.source}</span>
        <time className="date">{formatDate(update.published)}</time>
      </div>
      <h3 className="title">
        <a href={update.link} target="_blank" rel="noopener noreferrer">
          {update.title}
        </a>
      </h3>
      <p className="summary">{update.summary}</p>
      <div className="update-footer">
        <span className="type-badge">{update.type || 'rss'}</span>
      </div>
    </article>
  )
}

export default UpdateCard
