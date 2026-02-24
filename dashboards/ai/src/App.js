import React, { useState, useEffect } from 'react';
import './App.css';

// Component: UpdateCard
function UpdateCard({ update }) {
  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  return (
    <div className="update-card">
      <div className="update-header">
        <span className="update-source">{update.source}</span>
        <span className="update-date">{formatDate(update.published)}</span>
      </div>
      <h3 className="update-title">
        <a href={update.link} target="_blank" rel="noopener noreferrer">
          {update.title}
        </a>
      </h3>
      {update.summary && (
        <p className="update-summary">{update.summary}</p>
      )}
      <div className="update-tags">
        {update.tags && update.tags.map((tag, index) => (
          <span key={index} className="tag">{tag}</span>
        ))}
      </div>
    </div>
  );
}

// Component: SourceFilter
function SourceFilter({ sources, selectedSource, onSourceChange }) {
  return (
    <div className="source-filter">
      <label htmlFor="source-select">Filter by Source:</label>
      <select
        id="source-select"
        value={selectedSource}
        onChange={(e) => onSourceChange(e.target.value)}
        className="source-select"
      >
        <option value="">All Sources</option>
        {sources.map((source, index) => (
          <option key={index} value={source}>{source}</option>
        ))}
      </select>
    </div>
  );
}

// Component: SearchBar
function SearchBar({ searchTerm, onSearchChange }) {
  return (
    <div className="search-bar">
      <input
        type="text"
        placeholder="Search updates..."
        value={searchTerm}
        onChange={(e) => onSearchChange(e.target.value)}
        className="search-input"
      />
    </div>
  );
}

// Component: ErrorBanner
function ErrorBanner({ failedSources }) {
  if (failedSources.length === 0) return null;

  return (
    <div className="error-banner">
      <strong>⚠️ {failedSources.length} source(s) failed to update:</strong>
      <ul className="failed-sources-list">
        {failedSources.map((source, index) => (
          <li key={index}>{source}</li>
        ))}
      </ul>
    </div>
  );
}

// Component: LastUpdated
function LastUpdated({ timestamp }) {
  const formatTimestamp = (ts) => {
    if (!ts) return 'Never';
    const date = new Date(ts);
    return date.toLocaleString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <div className="last-updated">
      Last updated: {formatTimestamp(timestamp)}
    </div>
  );
}

// Main App Component
function App() {
  const [updates, setUpdates] = useState([]);
  const [filteredUpdates, setFilteredUpdates] = useState([]);
  const [sources, setSources] = useState([]);
  const [selectedSource, setSelectedSource] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [failedSources, setFailedSources] = useState([]);
  const [lastUpdated, setLastUpdated] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Load data on mount
  useEffect(() => {
    const loadData = async () => {
      try {
        // Load cached updates
        const response = await fetch('./data/cached_updates.json');
        if (!response.ok) {
          throw new Error(`Failed to load data: ${response.statusText}`);
        }

        const data = await response.json();

        // Extract updates
        const allUpdates = data.updates || [];
        setUpdates(allUpdates);
        setFilteredUpdates(allUpdates);

        // Extract unique sources
        const uniqueSources = [...new Set(allUpdates.map(u => u.source))].sort();
        setSources(uniqueSources);

        // Extract failed sources
        setFailedSources(data.failed_sources || []);

        // Extract last updated timestamp
        setLastUpdated(data.last_updated);

        setLoading(false);
      } catch (err) {
        console.error('Error loading dashboard data:', err);
        setError(err.message);
        setLoading(false);
      }
    };

    loadData();
  }, []);

  // Filter updates when source or search term changes
  useEffect(() => {
    let filtered = updates;

    // Filter by source
    if (selectedSource) {
      filtered = filtered.filter(u => u.source === selectedSource);
    }

    // Filter by search term
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      filtered = filtered.filter(u =>
        u.title.toLowerCase().includes(term) ||
        (u.summary && u.summary.toLowerCase().includes(term))
      );
    }

    setFilteredUpdates(filtered);
  }, [updates, selectedSource, searchTerm]);

  if (loading) {
    return (
      <div className="app">
        <div className="container">
          <div className="loading">Loading AI Advancements Dashboard...</div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="app">
        <div className="container">
          <div className="error">Error: {error}</div>
        </div>
      </div>
    );
  }

  return (
    <div className="app">
      <div className="container">
        <header className="header">
          <h1>AI Advancements Dashboard</h1>
          <p className="subtitle">Latest AI research, news, and developments</p>
          <LastUpdated timestamp={lastUpdated} />
        </header>

        <ErrorBanner failedSources={failedSources} />

        <div className="controls">
          <SearchBar searchTerm={searchTerm} onSearchChange={setSearchTerm} />
          <SourceFilter
            sources={sources}
            selectedSource={selectedSource}
            onSourceChange={setSelectedSource}
          />
        </div>

        <div className="stats">
          <span>Showing {filteredUpdates.length} of {updates.length} updates</span>
        </div>

        <div className="updates-grid">
          {filteredUpdates.length > 0 ? (
            filteredUpdates.map((update, index) => (
              <UpdateCard key={index} update={update} />
            ))
          ) : (
            <div className="no-results">
              No updates found. Try adjusting your filters.
            </div>
          )}
        </div>

        <footer className="footer">
          <p>Seven Fortunas AI Intelligence • Auto-updated every 6 hours</p>
        </footer>
      </div>
    </div>
  );
}

export default App;
