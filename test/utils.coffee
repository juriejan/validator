
chai = require('chai')

validators = require('../lib/validators')

expect = chai.expect


testValidator = (name) -> (config, val, result, modified) ->
  validators[name].test(config, val, {}, (err, val) ->
    expect(err).to.eql(result)
    if modified? then expect(val).to.eql(modified)
  )


module.exports = {
  testValidator
}
