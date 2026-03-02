import './SourceFilter.css'

function SourceFilter({ sources, selected, onChange }) {
  return (
    <div className="source-filter">
      <label htmlFor="source-select">Filter by source:</label>
      <select
        id="source-select"
        value={selected}
        onChange={(e) => onChange(e.target.value)}
        className="source-select"
      >
        <option value="all">All Sources</option>
        {sources.map(source => (
          <option key={source} value={source}>
            {source}
          </option>
        ))}
      </select>
    </div>
  )
}

export default SourceFilter
