# Normalize a string by removing space
# and setting to lowercase
module.exports.normalizeString = (str) ->
  str.replace(' ', '-').toLowerCase()

# Format a number of seconds to mm:ss
module.exports.formatTime = (seconds) ->
  (new Date).clearTime()
            .addSeconds(seconds)
            .toString('mm:ss')
