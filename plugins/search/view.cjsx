React = require('react')
ReactDOM = require('react-dom')

module.exports.SearchComponent=
class SearchComponent extends React.Component
  constructor: (props) ->
    super props
    @query = ""

  render: ->
    <form id="search-field" className="form-inline" onSubmit={@search.bind(@)}>
      <div className="form-group">
        <input type="text" className="form-control" placeholder="Search" onChange={(e) => @query = e.target.value}/>
      </div>
    </form>

  search: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @props.search.pluginManager.plugins.locallibrary.filterLibrary @query

module.exports.show = (search, element) ->
  ReactDOM.render(
    <SearchComponent search=search />,
    element
  )
