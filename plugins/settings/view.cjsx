React = require 'react'
ReactDOM = require 'react-dom'

module.exports.SettingsComponent=
class SettingsComponent extends React.Component
  constructor: (props) ->
    super props

    @state = {display: 'block'}


  hideSettings: ->
    @setState display: 'none'

  generateField: (name, value, type) ->
    @generateTextInput(name, value) if type is 'text'

  generateTextInput: (name, value) ->
    <div className="form-group">
      <label htmlFor={name} className="col-md-2 control-label">{name}</label>
      <div className="col-md-10">
        <input type="text" className="form-control" id={name} defaultValue={value} placeholder={name} />
      </div>
    </div>

  render: ->
    <div className="modal" style={{display: @state.display}}>
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header">
            <button type="button" className="close" data-dismiss="modal" aria-hidden="true" onClick={@hideSettings.bind(@)}>×</button>
            <h4 className="modal-title">Settings</h4>
          </div>
          <div className="modal-body">
            <form>
              {<fieldset>
                <legend>{plugin}</legend>
                {@generateField(name, settingDetails.value, settingDetails.type) for name, settingDetails of settings}
              </fieldset> for plugin, settings of @props.settings}
            </form>
          </div>
          <div className="modal-footer">
            <button type="button" className="btn btn-default" data-dismiss="modal">Close</button>
            <button type="button" className="btn btn-primary">Save changes</button>
          </div>
        </div>
      </div>
    </div>

module.exports.show = (settings, element) ->
  ReactDOM.render(
    <SettingsComponent settings=settings />,
    element
  ).setState display: 'block'
