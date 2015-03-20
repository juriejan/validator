
_ = require('lodash')

async = require('async')

strings = require('./strings')
validators = require('./validators')


Validator = (validation={}) ->
  return {
    validateRule: (state, item, cb) ->
      [field, val, message] = state
      [rule, config] = item
      validator = validators[rule]
      test = _.bind(validator.test, @)
      test(config, val, (err, success, val, fault) ->
        if err? then return cb(err)
        if not success
          message = _.template(validator.msg)({config, fault, val})
          cb(true, [field, val, message])
        else
          cb(null, [field, val, message])
      )
    validateField: (item, cb) ->
      [field, val, rules] = item
      validateRule = _.bind(@.validateRule, @)
      if not rules? then return cb(null, [field, val, strings.UNEXPECTED])
      rules = _.pairs(rules)
      async.reduce(rules, [field, val, null], validateRule, (err, result) ->
        if err is true then return cb(null, result)
        else if err? then return cb(err)
        cb(null, result)
      )
    validate: (data, cb) ->
      @.data = data
      validateField = _.bind(@.validateField, @)
      items = _.pairs(@.data)
      _.each(items, (o) => o[2] = validation[o[0]])
      async.map(items, validateField, (err, result) =>
        if err? then return cb(err)
        _.each(@.data, (v, k) =>
          data[k] = _.find(result, (o) -> o[0] is k)[1]
        )
        result = _.filter(result, (o) -> o[2]?)
        result = _.map(result, (o) -> [o[0], o[2]])
        cb(err, _.object(result))
      )
  }


module.exports = {
  Validator
  validators
  strings
}