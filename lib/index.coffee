
_ = require('lodash')

async = require('async')

strings = require('./strings')
validators = require('./validators')


Validator = (validation={}) ->
  return {
    validateRule: (state, field, data) -> (o, cb) ->
      [rule, config] = o
      value = data[field]
      validator = validators[rule]
      validator.test(config, value, data, (err, result, val, fault) ->
        if err? then return cb(err)
        data[field] = val
        state.result = result
        state.message = _.template(validator.msg)({config, fault, val})
        cb()
      )
    validateField: (data) -> (o, cb) ->
      [field, rules] = o
      state = {result:true, message:null}
      validateRule = _.bind(@.validateRule(state, field, data), @)
      async.until((() -> not state.result), validateRule, (err) ->
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
