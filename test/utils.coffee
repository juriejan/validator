
_ = require('lodash')

chai = require('chai')

validators = require('../lib/validators')

expect = chai.expect


testValidator = (name) -> (config, val, result, modified, fault, cb) ->
  test = _.bind(validators[name].test, {data:{}})
  test(config, val, (err, success, resultVal, resultFault) ->
    if err? then return cb(err)
    expect(success).to.eql(
      result
      "Expected validation success result of '#{success}' to be '#{result}'."
    )
    if not modified? then modified = val
    expect(resultVal).to.eql(modified)
    if fault? then expect(resultFault).to.eql(fault)
    if cb? then cb(null, resultVal)
  )


module.exports = {
  testValidator
}
