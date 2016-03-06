LastFmNode = require('lastfm').LastFmNode

module.exports =
class LastfmScrobbler
  constructor: (@pluginManager, @element) ->
    @lastfm = new LastFmNode({
      api_key: 'xxxxxxxxxx',
      secret: 'xxxxxxxxxxxx'
    })

    # TODO(Use settings)
    @username = 'Gunners91'
    @token = null

    if not token?
      @lastfm.request('auth.getToken', {user: @username}).on('success', (data) =>
        console.log "http://www.last.fm/api/auth/?api_key=xxxxx&token=#{data.token}"
        @lastfm.session({user: @username, token: data.token}).on('error', (err) ->
          console.log err))
