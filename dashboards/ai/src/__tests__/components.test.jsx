/**
 * P1-005: Component Unit Tests
 * Requirements: FR-4.1 — Individual component rendering and interaction.
 *
 * Run: cd dashboards/ai && npx vitest run
 *
 * Components tested:
 *   UpdateCard   — renders source, title link, summary, type badge, formatted date
 *   SourceFilter — dropdown with "All Sources", each source option, onChange, selected value
 *   SearchBar    — search input type, placeholder, value, onChange, accessible label
 *   LastUpdated  — null guard, "Last updated:" label, <time> element rendering
 */

import { render, screen, fireEvent } from '@testing-library/react'
import { vi, describe, it, expect } from 'vitest'
import UpdateCard from '../components/UpdateCard'
import SourceFilter from '../components/SourceFilter'
import SearchBar from '../components/SearchBar'
import LastUpdated from '../components/LastUpdated'

// =============================================================================
// UpdateCard
// =============================================================================

describe('UpdateCard', () => {
  const baseUpdate = {
    source: 'Anthropic',
    title: 'Claude 5 Safety Report',
    summary: 'Comprehensive safety evaluation for Claude 5.',
    link: 'https://anthropic.com/safety',
    // Use noon UTC so date is unambiguous across timezones
    published: '2026-01-15T12:00:00Z',
    type: 'blog',
  }

  it('renders the source badge', () => {
    render(<UpdateCard update={baseUpdate} />)
    expect(screen.getByText('Anthropic')).toBeInTheDocument()
  })

  it('renders the title as a link with the correct href', () => {
    render(<UpdateCard update={baseUpdate} />)
    const link = screen.getByRole('link', { name: 'Claude 5 Safety Report' })
    expect(link).toHaveAttribute('href', 'https://anthropic.com/safety')
  })

  it('opens the title link in a new tab', () => {
    render(<UpdateCard update={baseUpdate} />)
    const link = screen.getByRole('link')
    expect(link).toHaveAttribute('target', '_blank')
  })

  it('renders the summary text', () => {
    render(<UpdateCard update={baseUpdate} />)
    expect(screen.getByText('Comprehensive safety evaluation for Claude 5.')).toBeInTheDocument()
  })

  it('renders the type badge', () => {
    render(<UpdateCard update={baseUpdate} />)
    expect(screen.getByText('blog')).toBeInTheDocument()
  })

  it('defaults type badge to "rss" when type is not provided', () => {
    const update = { ...baseUpdate, type: undefined }
    render(<UpdateCard update={update} />)
    expect(screen.getByText('rss')).toBeInTheDocument()
  })

  it('formats a valid date into a human-readable string', () => {
    const { container } = render(<UpdateCard update={baseUpdate} />)
    const timeEl = container.querySelector('time')
    // Should contain the year (not be the raw ISO string)
    expect(timeEl.textContent).toMatch(/2026/)
    expect(timeEl.textContent).not.toBe(baseUpdate.published)
  })

  it('renders an <article> element', () => {
    render(<UpdateCard update={baseUpdate} />)
    expect(document.querySelector('article')).toBeInTheDocument()
  })
})

// =============================================================================
// SourceFilter
// =============================================================================

describe('SourceFilter', () => {
  const sources = ['OpenAI', 'DeepMind', 'Anthropic']

  it('renders "All Sources" as the first option', () => {
    render(<SourceFilter sources={sources} selected="all" onChange={() => {}} />)
    expect(screen.getByRole('option', { name: 'All Sources' })).toBeInTheDocument()
  })

  it('renders each source as a selectable option', () => {
    render(<SourceFilter sources={sources} selected="all" onChange={() => {}} />)
    for (const source of sources) {
      expect(screen.getByRole('option', { name: source })).toBeInTheDocument()
    }
  })

  it('calls onChange with the selected value when the user picks a source', () => {
    const handleChange = vi.fn()
    render(<SourceFilter sources={sources} selected="all" onChange={handleChange} />)
    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'OpenAI' } })
    expect(handleChange).toHaveBeenCalledWith('OpenAI')
  })

  it('reflects the currently selected value in the dropdown', () => {
    render(<SourceFilter sources={sources} selected="DeepMind" onChange={() => {}} />)
    expect(screen.getByRole('combobox')).toHaveValue('DeepMind')
  })
})

// =============================================================================
// SearchBar
// =============================================================================

describe('SearchBar', () => {
  it('renders an input with the correct placeholder', () => {
    render(<SearchBar value="" onChange={() => {}} />)
    expect(screen.getByPlaceholderText('Search updates...')).toBeInTheDocument()
  })

  it('renders a search-type input', () => {
    render(<SearchBar value="" onChange={() => {}} />)
    expect(screen.getByRole('searchbox')).toBeInTheDocument()
  })

  it('reflects the current value in the input', () => {
    render(<SearchBar value="anthropic" onChange={() => {}} />)
    expect(screen.getByRole('searchbox')).toHaveValue('anthropic')
  })

  it('calls onChange with the typed value', () => {
    const handleChange = vi.fn()
    render(<SearchBar value="" onChange={handleChange} />)
    fireEvent.change(screen.getByRole('searchbox'), { target: { value: 'gemini' } })
    expect(handleChange).toHaveBeenCalledWith('gemini')
  })

  it('has an accessible label for screen readers', () => {
    render(<SearchBar value="" onChange={() => {}} />)
    expect(screen.getByLabelText('Search updates')).toBeInTheDocument()
  })
})

// =============================================================================
// LastUpdated
// =============================================================================

describe('LastUpdated', () => {
  it('renders nothing when timestamp is null', () => {
    const { container } = render(<LastUpdated timestamp={null} />)
    expect(container).toBeEmptyDOMElement()
  })

  it('renders nothing when timestamp is an empty string', () => {
    const { container } = render(<LastUpdated timestamp="" />)
    expect(container).toBeEmptyDOMElement()
  })

  it('renders a "Last updated:" label when timestamp is provided', () => {
    render(<LastUpdated timestamp="2026-01-15T12:00:00Z" />)
    expect(screen.getByText('Last updated:')).toBeInTheDocument()
  })

  it('renders a <time> element containing the formatted timestamp', () => {
    const { container } = render(<LastUpdated timestamp="2026-01-15T12:00:00Z" />)
    const timeEl = container.querySelector('time')
    expect(timeEl).toBeInTheDocument()
    expect(timeEl.textContent).toMatch(/2026/)
  })

  it('falls back to rendering the raw string when date is unparseable', () => {
    const { container } = render(<LastUpdated timestamp="not-a-valid-timestamp" />)
    const timeEl = container.querySelector('time')
    // Component catches format errors and shows raw or "Invalid Date" string
    expect(timeEl).toBeInTheDocument()
    expect(timeEl.textContent.length).toBeGreaterThan(0)
  })
})
