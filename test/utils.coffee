
chai = require('chai')

validators = require('../lib/validators')

expect = chai.expect


testValidator = (name) -> (config, val, result, modified) ->
  validators[name].test(config, val, {}, (err, newVal) ->
    expect(err).to.eql(result)
    if not modified? then modified = val
    expect(newVal).to.eql(modified)
  )


module.exports = {
  testValidator
}
