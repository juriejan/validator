
expect = require('chai').expect

validators = require('../lib/validators')


testValidator = (val, result, modified) ->
  validators.required.test({}, val, {}, (err, val) ->
    expect(err).to.eql(result)
    if modified? then expect(val).to.eql(modified)
  )


describe('Required validator', () ->

  describe('passes over', () ->

    it('string', () ->
      testValidator('abc', true)
    )

    it('number', () ->
      testValidator(5, true)
    )

    it('zero', () ->
      testValidator(0, true)
    )

    it('true boolean', () ->
      testValidator(true, true)
    )

    it('false boolean', () ->
      testValidator(false, true)
    )

  )

  describe('returns error on', () ->

    it('empty string', () ->
      testValidator('', false)
    )

    it('null', () ->
      testValidator(null, false)
    )

    it('undefined', () ->
      testValidator(undefined, false)
    )

    it('empty array', () ->
      testValidator([], false)
    )

  )




)
