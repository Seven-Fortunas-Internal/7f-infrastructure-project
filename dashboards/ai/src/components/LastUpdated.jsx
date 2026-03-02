import './LastUpdated.css'

function LastUpdated({ timestamp }) {
  if (!timestamp) return null

  const formatTimestamp = (ts) => {
    try {
      const date = new Date(ts)
      return date.toLocaleString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        timeZoneName: 'short'
      })
    } catch {
      return ts
    }
  }

  return (
    <div className="last-updated">
      <span className="label">Last updated:</span>
      <time className="timestamp">{formatTimestamp(timestamp)}</time>
    </div>
  )
}

export default LastUpdated
