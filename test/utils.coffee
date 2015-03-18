
chai = require('chai')

validators = require('../lib/validators')

expect = chai.expect


testValidator = (name) -> (config, val, result, modified, fault, cb) ->
  validators[name].test(config, val, {}, (success, resultVal, resultFault) ->
    expect(success).to.eql(result)
    if not modified? then modified = val
    expect(resultVal).to.eql(modified)
    if fault? then expect(resultFault).to.eql(fault)
    if cb? then cb(null, resultVal)
  )


module.exports = {
  testValidator
}
