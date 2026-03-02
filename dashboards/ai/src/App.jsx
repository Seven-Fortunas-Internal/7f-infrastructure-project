import { useState, useEffect } from 'react'
import UpdateCard from './components/UpdateCard'
import SourceFilter from './components/SourceFilter'
import ErrorBanner from './components/ErrorBanner'
import LastUpdated from './components/LastUpdated'
import SearchBar from './components/SearchBar'
import './App.css'

function App() {
  const [updates, setUpdates] = useState([])
  const [metadata, setMetadata] = useState(null)
  const [selectedSource, setSelectedSource] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    // Load data from cached_updates.json
    fetch('./data/cached_updates.json')
      .then(res => res.json())
      .then(data => {
        setUpdates(data.updates || [])
        setLoading(false)
      })
      .catch(err => {
        setError('Failed to load dashboard data')
        setLoading(false)
      })

    // Load cache metadata
    fetch('./data/cache_metadata.json')
      .then(res => res.json())
      .then(data => setMetadata(data))
      .catch(() => {}) // Silent fail for metadata
  }, [])

  // Filter updates by source
  const filteredBySource = selectedSource === 'all'
    ? updates
    : updates.filter(update => update.source === selectedSource)

  // Filter by search query
  const filteredUpdates = filteredBySource.filter(update => {
    if (!searchQuery) return true
    const query = searchQuery.toLowerCase()
    return (
      update.title?.toLowerCase().includes(query) ||
      update.summary?.toLowerCase().includes(query) ||
      update.source?.toLowerCase().includes(query)
    )
  })

  // Get unique sources
  const sources = [...new Set(updates.map(u => u.source))].sort()

  // Get failed sources from metadata
  const failedSources = metadata?.failed_sources || []

  if (loading) {
    return <div className="loading">Loading dashboard...</div>
  }

  if (error) {
    return <div className="error">{error}</div>
  }

  return (
    <div className="app">
      <header className="header">
        <h1>AI Advancements Dashboard</h1>
        <p className="subtitle">Latest updates from OpenAI, DeepMind, Anthropic, and more</p>
      </header>

      {failedSources.length > 0 && (
        <ErrorBanner failedSources={failedSources} />
      )}

      {metadata && (
        <LastUpdated timestamp={metadata.last_updated} />
      )}

      <div className="controls">
        <SearchBar value={searchQuery} onChange={setSearchQuery} />
        <SourceFilter
          sources={sources}
          selected={selectedSource}
          onChange={setSelectedSource}
        />
      </div>

      <div className="updates-grid">
        {filteredUpdates.length === 0 ? (
          <p className="no-results">No updates found</p>
        ) : (
          filteredUpdates.map((update, index) => (
            <UpdateCard key={index} update={update} />
          ))
        )}
      </div>

      <footer className="footer">
        <p>Seven Fortunas AI Dashboard &copy; 2026</p>
        <p className="footer-note">
          Powered by automated RSS aggregation |
          Updates every 6 hours via GitHub Actions
        </p>
      </footer>
    </div>
  )
}

export default App
