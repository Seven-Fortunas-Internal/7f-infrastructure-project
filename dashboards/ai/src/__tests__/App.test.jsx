/**
 * P0-004: App.jsx Degradation Scenario Tests
 * Requirement: FR-4.1 — Dashboard must gracefully handle 6 degradation scenarios.
 *
 * Run: cd dashboards/ai && npx vitest run
 *
 * Scenarios tested:
 *  S1 — Loading state: shows spinner while fetch is in flight
 *  S2 — Fetch error: shows error message when cached_updates.json fails
 *  S3 — Empty updates: shows "No updates found" when data is empty
 *  S4 — Failed sources: shows ErrorBanner when metadata has failed_sources
 *  S5 — Successful load: renders update cards from fetched data
 *  S6 — Search filter: filters updates by title/summary/source
 *  S7 — Source filter: filters by selected source
 *  S8 — LastUpdated: shows timestamp from metadata
 */

import { render, screen, waitFor, fireEvent } from '@testing-library/react'
import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest'
import App from '../App.jsx'

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

const MOCK_UPDATES = [
  {
    source: 'OpenAI',
    title: 'GPT-5 Release Announcement',
    summary: 'OpenAI announces GPT-5 with improved reasoning capabilities.',
    link: 'https://openai.com/gpt5',
    published: '2026-01-15',
    type: 'rss',
  },
  {
    source: 'DeepMind',
    title: 'Gemini Ultra 2.0 Benchmark Results',
    summary: 'DeepMind publishes benchmark showing state-of-the-art performance.',
    link: 'https://deepmind.google/gemini',
    published: '2026-01-14',
    type: 'rss',
  },
  {
    source: 'Anthropic',
    title: 'Claude 5 Safety Report',
    summary: 'Anthropic releases comprehensive safety evaluation for Claude 5.',
    link: 'https://anthropic.com/safety',
    published: '2026-01-13',
    type: 'blog',
  },
]

const MOCK_METADATA = {
  last_updated: '2026-01-15T12:00:00Z',
  failed_sources: [],
}

const MOCK_METADATA_WITH_FAILURES = {
  last_updated: '2026-01-15T12:00:00Z',
  failed_sources: ['HuggingFace', 'ArXiv'],
}

// ---------------------------------------------------------------------------
// Fetch mock helpers
// ---------------------------------------------------------------------------

function mockFetch(updatesResponse, metadataResponse = MOCK_METADATA) {
  global.fetch = vi.fn().mockImplementation((url) => {
    if (url.includes('cached_updates.json')) {
      if (updatesResponse instanceof Error) {
        return Promise.reject(updatesResponse)
      }
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve(updatesResponse),
      })
    }
    if (url.includes('cache_metadata.json')) {
      if (metadataResponse instanceof Error) {
        return Promise.reject(metadataResponse)
      }
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve(metadataResponse),
      })
    }
    return Promise.reject(new Error(`Unexpected URL: ${url}`))
  })
}

beforeEach(() => {
  vi.clearAllMocks()
})

afterEach(() => {
  vi.restoreAllMocks()
})

// ---------------------------------------------------------------------------
// S1: Loading state
// ---------------------------------------------------------------------------

describe('S1 — Loading state', () => {
  it('shows loading indicator while fetch is in flight', () => {
    global.fetch = vi.fn(() => new Promise(() => {}))
    render(<App />)
    expect(screen.getByText(/loading/i)).toBeInTheDocument()
  })

  it('does not show error message during loading', () => {
    global.fetch = vi.fn(() => new Promise(() => {}))
    render(<App />)
    expect(screen.queryByText(/failed to load/i)).not.toBeInTheDocument()
  })
})

// ---------------------------------------------------------------------------
// S2: Fetch error
// ---------------------------------------------------------------------------

describe('S2 — Fetch error state', () => {
  it('shows error message when cached_updates.json fails', async () => {
    mockFetch(new Error('Network error'))
    render(<App />)
    await waitFor(() => {
      expect(screen.getByText(/failed to load dashboard data/i)).toBeInTheDocument()
    })
  })

  it('does not show updates when fetch fails', async () => {
    mockFetch(new Error('Network error'))
    render(<App />)
    await waitFor(() => {
      expect(screen.queryByRole('article')).not.toBeInTheDocument()
    })
  })

  it('error state shows no loading indicator', async () => {
    mockFetch(new Error('Network error'))
    render(<App />)
    await waitFor(() => {
      expect(screen.queryByText(/loading/i)).not.toBeInTheDocument()
    })
  })
})

// ---------------------------------------------------------------------------
// S3: Empty updates list
// ---------------------------------------------------------------------------

describe('S3 — Empty updates list', () => {
  it('shows "No updates found" when data is empty', async () => {
    mockFetch({ updates: [] })
    render(<App />)
    await waitFor(() => {
      expect(screen.getByText(/no updates found/i)).toBeInTheDocument()
    })
  })

  it('renders no update cards when list is empty', async () => {
    mockFetch({ updates: [] })
    render(<App />)
    await waitFor(() => {
      expect(screen.queryByRole('article')).not.toBeInTheDocument()
    })
  })

  it('still shows the header when updates are empty', async () => {
    mockFetch({ updates: [] })
    render(<App />)
    await waitFor(() => {
      expect(screen.getByRole('heading', { level: 1 })).toBeInTheDocument()
    })
  })
})

// ---------------------------------------------------------------------------
// S4: Failed sources — ErrorBanner
// ---------------------------------------------------------------------------

describe('S4 — Failed sources banner', () => {
  it('shows ErrorBanner when metadata has failed_sources', async () => {
    mockFetch({ updates: MOCK_UPDATES }, MOCK_METADATA_WITH_FAILURES)
    render(<App />)
    await waitFor(() => {
      expect(screen.getByRole('alert')).toBeInTheDocument()
    })
  })

  it('ErrorBanner lists failed source names', async () => {
    mockFetch({ updates: MOCK_UPDATES }, MOCK_METADATA_WITH_FAILURES)
    render(<App />)
    await waitFor(() => {
      expect(screen.getByText(/HuggingFace/)).toBeInTheDocument()
      expect(screen.getByText(/ArXiv/)).toBeInTheDocument()
    })
  })

  it('does not show ErrorBanner when all sources succeed', async () => {
    mockFetch({ updates: MOCK_UPDATES }, MOCK_METADATA)
    render(<App />)
    await waitFor(() => {
      expect(screen.queryByRole('alert')).not.toBeInTheDocument()
    })
  })

  it('does not show ErrorBanner when metadata fails to load', async () => {
    mockFetch({ updates: MOCK_UPDATES }, new Error('metadata unavailable'))
    render(<App />)
    await waitFor(() => {
      expect(screen.queryByRole('alert')).not.toBeInTheDocument()
    })
  })
})

// ---------------------------------------------------------------------------
// S5: Successful load
// ---------------------------------------------------------------------------

describe('S5 — Successful data load', () => {
  it('renders one article card per update', async () => {
    mockFetch({ updates: MOCK_UPDATES })
    render(<App />)
    await waitFor(() => {
      expect(screen.getAllByRole('article')).toHaveLength(MOCK_UPDATES.length)
    })
  })

  it('renders update titles', async () => {
    mockFetch({ updates: MOCK_UPDATES })
    render(<App />)
    await waitFor(() => {
      expect(screen.getByText('GPT-5 Release Announcement')).toBeInTheDocument()
      expect(screen.getByText('Claude 5 Safety Report')).toBeInTheDocument()
    })
  })

  it('renders source badges for each update', async () => {
    mockFetch({ updates: MOCK_UPDATES })
    render(<App />)
    await waitFor(() => {
      // At least one element with each source name
      expect(screen.getAllByText('OpenAI').length).toBeGreaterThan(0)
      expect(screen.getAllByText('DeepMind').length).toBeGreaterThan(0)
    })
  })

  it('shows LastUpdated timestamp when metadata loads', async () => {
    mockFetch({ updates: MOCK_UPDATES }, MOCK_METADATA)
    render(<App />)
    await waitFor(() => {
      expect(screen.getByText(/last updated/i)).toBeInTheDocument()
    })
  })
})

// ---------------------------------------------------------------------------
// S6: Search filter
// ---------------------------------------------------------------------------

describe('S6 — Search filter', () => {
  it('filters updates by title text', async () => {
    mockFetch({ updates: MOCK_UPDATES })
    render(<App />)
    await waitFor(() => screen.getAllByRole('article'))

    const searchInput = screen.getByRole('searchbox')
    fireEvent.change(searchInput, { target: { value: 'GPT-5' } })

    await waitFor(() => {
      expect(screen.getAllByRole('article')).toHaveLength(1)
      expect(screen.getByText('GPT-5 Release Announcement')).toBeInTheDocument()
    })
  })

  it('filters updates by summary text', async () => {
    mockFetch({ updates: MOCK_UPDATES })
    render(<App />)
    await waitFor(() => screen.getAllByRole('article'))

    fireEvent.change(screen.getByRole('searchbox'), { target: { value: 'benchmark' } })

    await waitFor(() => {
      expect(screen.getAllByRole('article')).toHaveLength(1)
    })
  })

  it('shows "No updates found" when search matches nothing', async () => {
    mockFetch({ updates: MOCK_UPDATES })
    render(<App />)
    await waitFor(() => screen.getAllByRole('article'))

    fireEvent.change(screen.getByRole('searchbox'), { target: { value: 'xyznotfound' } })

    await waitFor(() => {
      expect(screen.getByText(/no updates found/i)).toBeInTheDocument()
    })
  })

  it('search is case-insensitive', async () => {
    mockFetch({ updates: MOCK_UPDATES })
    render(<App />)
    await waitFor(() => screen.getAllByRole('article'))

    fireEvent.change(screen.getByRole('searchbox'), { target: { value: 'claude' } })

    await waitFor(() => {
      expect(screen.getAllByRole('article')).toHaveLength(1)
    })
  })
})

// ---------------------------------------------------------------------------
// S7: Source filter
// ---------------------------------------------------------------------------

describe('S7 — Source filter', () => {
  it('shows all updates when "all" is selected', async () => {
    mockFetch({ updates: MOCK_UPDATES })
    render(<App />)
    await waitFor(() => {
      expect(screen.getAllByRole('article')).toHaveLength(MOCK_UPDATES.length)
    })
  })

  it('populates source dropdown with unique source names', async () => {
    mockFetch({ updates: MOCK_UPDATES })
    render(<App />)
    await waitFor(() => {
      expect(screen.getByRole('option', { name: 'Anthropic' })).toBeInTheDocument()
      expect(screen.getByRole('option', { name: 'OpenAI' })).toBeInTheDocument()
    })
  })

  it('filters to single source when selected', async () => {
    mockFetch({ updates: MOCK_UPDATES })
    render(<App />)
    await waitFor(() => screen.getAllByRole('article'))

    const select = screen.getByRole('combobox')
    fireEvent.change(select, { target: { value: 'Anthropic' } })

    await waitFor(() => {
      expect(screen.getAllByRole('article')).toHaveLength(1)
      expect(screen.getByText('Claude 5 Safety Report')).toBeInTheDocument()
    })
  })
})

// ---------------------------------------------------------------------------
// S8: LastUpdated component
// Note: UpdateCard also renders <time class="date">, so we query by
// class="timestamp" which is specific to the LastUpdated component.
// ---------------------------------------------------------------------------

describe('S8 — LastUpdated timestamp', () => {
  it('shows last updated timestamp from metadata', async () => {
    mockFetch({ updates: MOCK_UPDATES }, MOCK_METADATA)
    const { container } = render(<App />)
    await waitFor(() => {
      // LastUpdated renders <time class="timestamp">
      expect(container.querySelector('time.timestamp')).toBeTruthy()
    })
  })

  it('does not show last updated when metadata is unavailable', async () => {
    mockFetch({ updates: MOCK_UPDATES }, new Error('no metadata'))
    const { container } = render(<App />)
    await waitFor(() => {
      // Updates load, but LastUpdated's <time class="timestamp"> must be absent
      expect(screen.getAllByRole('article').length).toBeGreaterThan(0)
      expect(container.querySelector('time.timestamp')).toBeNull()
    })
  })
})
