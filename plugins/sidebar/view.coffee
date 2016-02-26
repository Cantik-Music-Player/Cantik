module.exports.SidebarView =
class SidebarView
  constructor: ->
    @links = {}

  listLinks: (category) ->
    @links[category]

  listCategories: ->
    Object.keys(@links)

module.exports.SidebarComponent =
ng.core.Component({
  directives: [ng.common.NgFor],
  selector: '#sidebar',
  templateUrl: __dirname + '/html/index.html'
}).Class({
  constructor: ->
    Object.setPrototypeOf(@, SidebarView.prototype)
    @.constructor()
})

ng.platform.browser.bootstrap(module.exports.SidebarComponent)
