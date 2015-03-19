
_ = require('lodash')

async = require('async')
mongojs = require('mongojs')
moment = require('moment')
validurl = require('valid-url')

strings = require('./strings')


RE_EMAIL = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/
RE_MSISDN = /^(\+?27|0)(\d{9})$/
RE_MONGOID = /^[a-z0-9]{24}$/

RE_ENCODING_URL = /[^\w\d%+.\-\*]/g


# available = {
#   msg: strings.NOT_AVAILABLE
#   test: (config, val, cb) ->
#     data = {}
#     data[config] = val
#     API.available(data, (err, data) ->
#       if err? then return cb(false)
#       cb(data.available, val)
#     )
# }

array = {
  msg: strings.ARRAY
  test: (config, val, cb) ->
    if not val? then return cb(null, true, val)
    if _.isString(val) and _.size(val) is 0
      return cb(null, true, val)
    if not _.isArray(val) then return cb(null, false, val)

    items = _.map(val, (o) -> [null, config, o])
    validateField = _.bind(@.validateField, @)
    async.map(items, validateField, (err, result) ->
      if err? then return cb(err)
      _.each(val, (o, n) => val[n] = result[n][1])
      fault = _.find(result, (o) -> o[2]?)
      if fault?
        cb(null, false, val, fault[2])
      else
        cb(null, true, val)
    )
}

boolean = {
  msg: strings.INVALID.BOOLEAN
  test: (config, val, cb) ->
    if not val?
      return cb(null, true, val)
    if _.isString(val)
      val = val.replace(/\s/g, '')
      if _.size(val) is 0 then return cb(null, true, val)
    if val is true or val is 'true' or val < 0 or val > 0
      return cb(null, true, true)
    if val is false or val is 'false' or val is 0
      return cb(null, true, false)
    cb(null, false, val)
}

date = {
  msg: strings.DATE
  test: (config, val, cb) ->
    if _.isNumber(val) or _.isBoolean(val) or _.isArray(val)
      return cb(null, false, val)
    if not val?
      return cb(null, true, val)
    val = val.trim()
    if _.size(val) is 0
      return cb(null, true, val)
    date = moment(val, config, true)
    if date.isValid() then cb(null, true, date.toDate())
    else cb(null, false, val)
}

email = {
  msg: strings.INVALID.EMAIL
  test: (config, val, cb) ->
    if not val?
      return cb(null, true, val)
    if _.size(val) is 0
      return cb(null, true, val)
    if _.isString(val)
      val = val.replace(/\s/g, '')
      match = RE_EMAIL.test(val)
      cb(null, RE_EMAIL.test(val), val)
    else
      cb(null, false, val)
}

emailmsisdn = {
  msg: strings.INVALID.EMAIL_MSISDN
  test: (config, val, done) ->
    result = false
    async.waterfall([
      (cb) =>
        emailTest = _.bind(email.test, @)
        emailTest(config, val, (err, success, val) ->
          if err? then return cb(err)
          result = result or success
          cb(null, val)
        )
      (val, cb) =>
        msisdnTest = _.bind(msisdn.test, @)
        msisdnTest(config, val, (err, success, val) ->
          if err? then return cb(err)
          result = result or success
          cb(null, val)
        )
    ], (err, val) ->
      if err? then return done(err)
      done(null, result, val)
    )
}

encoding = {
  msg: strings.ENCODING
  test: (config, val, cb) ->
    if not val?
      return cb(null, true, val)
    if not _.isString(val)
      return cb(null, false, val)
    if config is 'url'
      fault = val.search(RE_ENCODING_URL)
      if fault > -1 then return cb(null, false, val, val[fault])
      try
        val = decodeURIComponent(val)
        val = val.replace(/\+/g, ' ')
        cb(null, true, val)
      catch err
        cb(null, false, val)
    else
      cb(null, false, val)
}

enumerate = {
  msg: strings.INVALID.VALUE
  test: (config, val, cb) -> cb(null, config.indexOf(val) > -1, val)
}

geocoordinates = {
  msg: strings.INVALID.GEO_COORDINATES
  test: (config, val, done) ->
    async.parallel({
      lat: (cb) -> latitude.test(config, val.lat, data, (err, result, val) ->
        if result is false then return cb(true)
        cb(null, val)
      )
      lng: (cb) -> longitude.test(config, val.lng, data, (err, result, val) ->
        if result is false then return cb(true)
        cb(null, val)
      )
    }, (err, result) ->
      if err? then return done(false, val)
      done(null, true, result)
    )
}

latitude = {
  msg: strings.INVALID.LATITUDE
  test: (config, val, cb) ->
    val = parseFloat(val)
    if _.isNaN(val) then return cb(null, false, val)
    if not(-90 < val < 90) then return cb(null, false, val)
    cb(null, true, val)
}

longitude = {
  msg: strings.INVALID.LONGITUDE
  test: (config, val, cb) ->
    val = parseFloat(val)
    if _.isNaN(val) then return cb(null, false, val)
    if not(-180 < val < 180) then return cb(null, false, val)
    cb(null, true, val)
}

integer = {
  msg: strings.INVALID.INTEGER
  test: (config, val, cb) ->
    result = parseInt(val)
    if _.isNaN(result)
      cb(null, false, val)
    else
      cb(null, true, result)
}

match = {
  msg: strings.MATCH_REQUIRED
  test: (config, val, cb) ->
    cb(null, data[config.field] is val, val)
}

maxlength = {
  msg: strings.TOO_LONG
  test: (config, val, cb) -> cb(null, _.size(val) <= config, val)
}

minlength = {
  msg: strings.TOO_SHORT
  test: (config, val, cb) -> cb(null, _.size(val) >= config, val)
}

mongoid = {
  msg: strings.INVALID.MONGOID
  test: (config, val, cb) ->
    if not val?
      return cb(null, true, val)
    if not _.isString(val)
      return cb(null, false, val)
    if _.size(val) is 0
      return cb(null, true, val)
    val = val.replace(/\s/g, '')
    if RE_MONGOID.test(val) is true
      cb(null, true, new mongojs.ObjectId(val))
    else
      cb(null, false, val)
}

msisdn = {
  msg: strings.INVALID.MSISDN
  test: (config, val, cb) ->
    if not val?
      return cb(null, true, val)
    if _.size(val) is 0
      return cb(null, true, val)
    if _.isString(val)
      val = val.replace(/\s/g, '')
      match = RE_MSISDN.exec(val)
      if match is null
        cb(null, false, val)
      else
        cb(null, true, "27#{match[2]}")
    else
      cb(null, false, val)
}

reference = {
  msg: strings.REFERENCE_NOT_FOUND
  test: (config, val, cb) ->
    if not val?
      return cb(null, true, val)
    if not _.isString(val)
      return cb(null, false, val)
    if _.size(val) is 0
      return cb(null, true, val)
    query = {}
    query[config.field] = val
    config.db.collection(config.type)
    .findOne(query, {_id:1}, (err, doc) ->
      if err? then return cb(err)
      if doc?
        cb(null, true, doc._id)
      else
        cb(null, false, val)
    )
}

required = {
  msg: strings.REQUIRED
  test: (config, val, cb) ->
    valid = false
    valid or= _.isBoolean(val)
    valid or= _.isNumber(val)
    valid or= _.size(val) > 0
    cb(null, valid, val)
}

string = {
  msg: strings.INVALID.STRING
  test: (config, val, cb) ->
    if not val?
      cb(null, true, val)
    else
      cb(null, _.isString(val), val)
}

url = {
  msg: strings.INVALID.URI
  test: (config, val, cb) ->
    if not val?
      cb(null, true, val)
    else
      if _.isString(val)
        val = val.replace(/\s/g, '')
        if _.size(val) is 0
          cb(null, true, val)
        else
          cb(null, !!validurl.isWebUri(val), val)
      else
        cb(null, false, val)
}

weekday = {
  msg: strings.INVALID.WEEKDAY
  test: (config, val, cb) ->
    if not val? then return cb(null, true, val)
    if _.isString(val)
      val = val.replace(/\s/g, '')
      if _.size(val) is 0
        return cb(null, true, val)
      parsed = moment._locale.weekdaysParse(val)
      if parsed is 0 then parsed = 7
      return cb(null, !!parsed, parsed or val)
    if _.isNumber(val)
      return cb(null, (val > 0 and val < 8), val)
    cb(null, false, val)
}


module.exports = {
  array
  boolean
  date
  email
  emailmsisdn
  encoding
  enum: enumerate
  geocoordinates
  msisdn
  integer
  latitude
  longitude
  match
  maxlength
  minlength
  mongoid
  reference
  required
  string
  url
  weekday
}
