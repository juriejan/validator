
_ = require('lodash')

async = require('async')

strings = require('./strings')
validators = require('./validators')


Validator = (validation={}) ->
  return {
    strings: strings
    validateRule: (field, data) -> (o, cb) ->
      [rule, config] = o
      value = data[field]
      validator = validators[rule]
      validator.test(config, value, data, (result, val) ->
        if result
          if val? then data[field] = val
          cb()
        else
          cb(_.template(validator.msg)({config}))
      )
    validateField: (data) -> (o, cb) ->
      [field, rules] = o
      validateRule = _.bind(@.validateRule(field, data), @)
      async.eachSeries(_.pairs(rules), validateRule, (err) ->
        cb(null, [field, err])
      )
    validate: (data, cb) ->
      _.each(data, (v, k) ->
        if _.isString(data[k]) then data[k] = v.trim()
      )
      validateField = _.bind(@.validateField(data), @)
      async.map(_.pairs(validation), validateField, (err, result) ->
        result = _.filter(result, (o) -> o[1]?)
        cb(err, _.object(result))
      )
  }


module.exports = {
  Validator
  validators
  strings
}
