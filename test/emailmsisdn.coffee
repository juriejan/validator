
expect = require('chai').expect

validators = require('../lib/validators')

testMsisdn = require('./msisdn')
testEmail = require('./email')


testValidator = (val, result, modified) ->
  validators.emailmsisdn.test({}, val, {}, (err, val) ->
    expect(err).to.eql(result)
    if modified? then expect(val).to.eql(modified)
  )


describe('Email Address or Mobile Number validator', () ->

  testMsisdn(testValidator)

  testEmail(testValidator)

)
