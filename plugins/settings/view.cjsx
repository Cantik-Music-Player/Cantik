React = require 'react'
ReactDOM = require 'react-dom'

module.exports.SettingsComponent=
class SettingsComponent extends React.Component
  constructor: (props) ->
    super props

    @state = {display: 'block'}

    @settings = JSON.parse(JSON.stringify(props.settings.settings))  # Copy object

  hideSettings: ->
    @setState display: 'none'

  generateField: (name, value, type, plugin) ->
    <div key={"{#{name}-#{plugin}}"}>
      {@generateTextInput(name, value, plugin) if type is 'text'}
      {@generatePasswordInput(name, value, plugin) if type is 'password'}
    </div>

  setSetting: (plugin, name, e) ->
    @settings[plugin][name].value = e.target.value

  generateTextInput: (name, value, plugin) ->
    <div className="form-group">
      <label htmlFor={name} className="col-md-2 control-label">{name}</label>
      <div className="col-md-10">
        <input type="text" className="form-control" id={name} defaultValue={value} placeholder={name} onChange={@setSetting.bind(@, plugin, name)} />
      </div>
    </div>

  generatePasswordInput: (name, value, plugin) ->
    <div className="form-group">
      <label htmlFor={name} className="col-md-2 control-label">{name}</label>
      <div className="col-md-10">
        <input type="password" className="form-control" id={name} defaultValue={value} placeholder={name} onChange={@setSetting.bind(@, plugin, name)} />
      </div>
    </div>

  saveSettings: (e) ->
    @props.settings.setSettings @settings
    do @hideSettings

    # Stop event propagation
    if e?
      e.preventDefault()
      e.stopPropagation()

  render: ->
    <div className="modal" style={{display: @state.display}}>
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header">
            <button type="button" className="close" data-dismiss="modal" aria-hidden="true" onClick={@hideSettings.bind(@)}>×</button>
            <h4 className="modal-title">Settings</h4>
          </div>
          <div className="modal-body">
            <form onSubmit={@saveSettings.bind(@)}>
              {<fieldset>
                <legend>{plugin}</legend>
                {@generateField(name, settingDetails.value, settingDetails.type, plugin) for name, settingDetails of settings}
              </fieldset> for plugin, settings of @props.settings.settings}
            </form>
          </div>
          <div className="modal-footer">
            <button type="button" className="btn btn-default" onClick={@hideSettings.bind(@)}>Close</button>
            <button type="button" className="btn btn-primary" onClick={@saveSettings.bind(@)}>Save changes</button>
          </div>
        </div>
      </div>
    </div>

module.exports.show = (settings, element) ->
  ReactDOM.render(
    <SettingsComponent settings=settings />,
    element
  ).setState display: 'block'
