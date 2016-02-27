# Normalize a string by removing space
# and setting to lowercase
module.exports.normalizeString = (str) ->
  str.replace(' ', '-').toLowerCase()
