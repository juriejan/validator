
_ = require('lodash')

async = require('async')

strings = require('./strings')
validators = require('./validators')


Validator = (validation={}) ->
  return {
    validateRule: (state, field, data) -> (cb) ->
      [rule, config] = state.rules.pop()
      value = data[field]
      validator = validators[rule]
      validator.test(config, value, data, (err, result, val, fault) ->
        if err? then return cb(err)
        data[field] = val
        if not result
          state.message = _.template(validator.msg)({config, fault, val})
        cb()
      )
    validateField: (data) -> (o, cb) ->
      [field, rules] = o
      rules = _.pairs(rules)
      rules.reverse()
      state = {message:null, rules}
      validateRule = _.bind(@.validateRule(state, field, data), @)
      async.until((() -> state.message? or _.size(state.rules) is 0), validateRule, (err) ->
        cb(null, [field, state.message])
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
