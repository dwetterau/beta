{ constants } = require '../lib/common'

# Convert an integer to a base 62 string
convertInteger = (num) ->
  result = ''
  while num > 0
    result += constants.BASE_62_MAP[num % 62]
    num = Math.floor(num / 62)
  return result

convertString = (string) ->
  num = 0
  base = 1
  for i in [0...string.length]
    num += base * constants.INVERTED_BASE_62_MAP[string.charAt(i)]
    base *= 62
  return num

exports.convertIdToString = (id) ->
  # Compute checksum
  original = id
  sum = 0
  while original > 0
    sum += original % 10
    original = Math.floor(original / 10)

  # Only want two characters
  sum %= (62 * 62)
  # Pad it to two characters if it's too small
  if sum < 62
    sum += 62
  return convertInteger(sum) + convertInteger(id)

exports.convertStringToId = (string) ->
  string = string.substring(2)
  return convertString(string)
