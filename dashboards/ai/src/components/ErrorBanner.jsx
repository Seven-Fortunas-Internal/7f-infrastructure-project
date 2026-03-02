import './ErrorBanner.css'

function ErrorBanner({ failedSources }) {
  if (!failedSources || failedSources.length === 0) {
    return null
  }

  return (
    <div className="error-banner" role="alert">
      <div className="error-icon">⚠️</div>
      <div className="error-content">
        <strong>Some sources failed to update</strong>
        <p className="failed-sources">
          {failedSources.join(', ')} ({failedSources.length} {failedSources.length === 1 ? 'source' : 'sources'})
        </p>
      </div>
    </div>
  )
}

export default ErrorBanner
