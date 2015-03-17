
_ = require('lodash')

async = require('async')
mongojs = require('mongojs')
moment = require('moment')
validUrl = require('valid-url')

strings = require('./strings')


RE_EMAIL = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/
RE_MSISDN = /^(\+?27|0)(\d{9})$/
RE_MONGOID = /^[a-z0-9]{24}$/


date = {
  msg: strings.DATE
  test: (config, val, data, cb) ->
    if _.isNumber(val) or _.isBoolean(val) or _.isArray(val)
      return cb(false, val)
    if not val?
      return cb(true, val)
    val = val.trim()
    if _.size(val) is 0
      return cb(true, val)
    date = moment(val, config, true)
    if date.isValid() then cb(true, date.toDate())
    else cb(false, val)
}

email = {
  msg: strings.INVALID.EMAIL
  test: (config, val, data, cb) ->
    if not val?
      return cb(true, val)
    if _.size(val) < 1
      return cb(true, val)
    if _.isString(val)
      val = val.replace(/\s/g, '')
      match = RE_EMAIL.test(val)
      cb(RE_EMAIL.test(val), val)
    else
      cb(false, val)
}

encoding = {
  msg: strings.ENCODING
  test: (config, val, data, cb) ->
    if not val?
      return cb(true, val)
    if not _.isString(val)
      return cb(false, val)
    if config is 'url'
      if val.search(/[^\w\d%]/g) > -1
        return cb(false, val)
      try
        val = decodeURIComponent(val)
        cb(true, val)
      catch err
        cb(false, val)
    else
      cb(false, val)
}

latitude = {
  msg: strings.INVALID.LATITUDE
  test: (config, val, data, cb) ->
    val = parseFloat(val)
    if _.isNaN(val) then return cb(false, val)
    if not(-90 < val < 90) then return cb(false, val)
    cb(true, val)
}

longitude = {
  msg: strings.INVALID.LONGITUDE
  test: (config, val, data, cb) ->
    val = parseFloat(val)
    if _.isNaN(val) then return cb(false, val)
    if not(-180 < val < 180) then return cb(false, val)
    cb(true, val)
}

msisdn = {
  msg: strings.INVALID.MSISDN
  test: (config, val, data, cb) ->
    if not val?
      return cb(true, val)
    if _.size(val) < 1
      return cb(true, val)
    if _.isString(val)
      val = val.replace(/\s/g, '')
      match = RE_MSISDN.exec(val)
      if match is null
        cb(false, val)
      else
        cb(true, "27#{match[2]}")
    else
      cb(false, val)
}

integer = {
  msg: strings.INVALID.INTEGER
  test: (config, val, data, cb) ->
    result = parseInt(val)
    if _.isNaN(result)
      cb(false, val)
    else
      cb(true, result)
}

minlength = {
  msg: strings.TOO_SHORT
  test: (config, val, data, cb) -> cb(_.size(val) >= config, val)
}

maxlength = {
  msg: strings.TOO_LONG
  test: (config, val, data, cb) -> cb(_.size(val) <= config, val)
}

string = {
  msg: strings.INVALID.STRING
  test: (config, val, data, cb) ->
    if not val?
      cb(true, val)
    else
      cb(_.isString(val), val)
}

url = {
  msg: strings.INVALID.URI
  test: (config, val, data, cb) ->
    if not val?
      cb(true, val)
    else
      if _.isString(val)
        val = val.replace(/\s/g, '')
        if _.size(val) is 0
          cb(true, val)
        else
          cb(!!validUrl.isWebUri(val), val)
      else
        cb(false, val)
}


module.exports = {
  date
  email
  encoding
  msisdn
  integer
  latitude
  longitude
  minlength
  maxlength
  string
  url
  mongoid: {
    msg: strings.INVALID.MONGOID
    test: (config, val, data, cb) ->
      if _.isString(val)
        val = val.replace(/\s/g, '')
        if RE_MONGOID.test(val) is true
          cb(true, new mongojs.ObjectId(val))
        else
          cb(false, val)
      else
        cb(false, val)
  }
  required: {
    msg: strings.REQUIRED
    test: (config, val, data, cb) ->
      valid = false
      valid or= _.isBoolean(val)
      valid or= _.isNumber(val)
      valid or= _.size(val) > 0
      cb(valid, val)
  }
  emailmsisdn: {
    msg: strings.INVALID.EMAIL_MSISDN
    test: (config, val, data, done) ->
      async.waterfall([
        (cb) -> email.test(config, val, data, cb)
        (val, cb) -> msisdn.test(config, val, data, cb)
      ], done)
  }
  enum: {
    msg: strings.INVALID.VALUE
    test: (config, val, data, cb) -> cb(config.indexOf(val) > -1, val)
  }
  geocoordinates: {
    msg: strings.INVALID.GEO_COORDINATES
    test: (config, val, data, done) ->
      async.parallel({
        lat: (cb) -> latitude.test(config, val.lat, data, (result, val) ->
          if result is false then return cb(true)
          cb(null, val)
        )
        lng: (cb) -> longitude.test(config, val.lng, data, (result, val) ->
          if result is false then return cb(true)
          cb(null, val)
        )
      }, (err, result) ->
        if err? then return done(false, val)
        done(true, result)
      )
  }
  # available: {
  #   msg: strings.NOT_AVAILABLE
  #   test: (config, val, data, cb) ->
  #     data = {}
  #     data[config] = val
  #     API.available(data, (err, data) ->
  #       if err? then return cb(false)
  #       cb(data.available, val)
  #     )
  # }
  match: {
    msg: strings.MATCH_REQUIRED
    test: (config, val, data, cb) ->
      cb(data[config.field] is val, val)
  }
}
