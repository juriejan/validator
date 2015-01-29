
expect = require('chai').expect

validators = require('../lib/validators')


module.exports = testMsisdn = (testValidator) ->

  describe('passes over', () ->

    it('number starting with no country code', () ->
      testValidator('0821231234', true, '27821231234')
    )

    it('number starting with country code', () ->
      testValidator('27721231234', true, '27721231234')
    )

    it('number starting with country code and a plus', () ->
      testValidator('+27711231234', true, '27711231234')
    )

    it('number with extra spaces and no country code', () ->
      testValidator('  061 123 4321  ', true, '27611234321')
    )

    it('number with extra spaces and country code', () ->
      testValidator(' 27 6 1 123 4321  ', true, '27611234321')
    )

    it('number with extra spaces, country code and a plus', () ->
      testValidator(' + 276 1 1 2 3 4321  ', true, '27611234321')
    )

    it('empty string', () ->
      testValidator('', true)
    )

    it('null', () ->
      testValidator(null, true)
    )

    it('undefined', () ->
      testValidator(undefined, true)
    )

    it('array', () ->
      testValidator([], true)
    )

  )

  describe('returns error on', () ->

    it('missing digits with no country code', () ->
      testValidator('082123', false, '082123')
    )

    it('missing digits with country code', () ->
      testValidator('2782123', false, '2782123')
    )

    it('missing digits with country code and plus', () ->
      testValidator('+2782123', false, '+2782123')
    )

    it('missing digits with spaces and no country code', () ->
      testValidator('0 82 12 3 ', false, '082123')
    )

    it('missing digits with spaces and country code', () ->
      testValidator('  2782  123  ', false, '2782123')
    )

    it('missing digits with spaces, country code and plus', () ->
      testValidator(' +2 7 8 2 1 2 3 ', false, '+2782123')
    )

  )

testValidator = (val, result, modified) ->
  validators.msisdn.test({}, val, {}, (err, val) ->
    expect(err).to.eql(result)
    if modified? then expect(val).to.eql(modified)
  )


describe('Mobile Number validator', () ->

  testMsisdn(testValidator)

)
