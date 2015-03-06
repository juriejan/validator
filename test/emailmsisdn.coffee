
utils = require('./utils')

testMsisdn = require('./msisdn')
testEmail = require('./email')


testValidator = utils.testValidator('emailmsisdn')


describe('Email Address or Mobile Number validator', () ->

  testMsisdn(testValidator)

  testEmail(testValidator)

)
