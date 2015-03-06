
expect = require('chai').expect

validators = require('../lib/validators')


testValidator = (val, result, modified) ->
  validators.integer.test({}, val, {}, (err, val) ->
    expect(err).to.eql(result)
    if modified? then expect(val).to.eql(modified)
  )


describe('Integer validator', () ->

  describe('passes over', () ->

    it('integer', () ->
      testValidator(1, true)
    )

    it('floating point', () ->
      testValidator(1.0, true)
    )

    it('integer string', () ->
      testValidator('1', true)
    )

    it('floating point string', () ->
      testValidator('1.0', true)
    )

    it('zero', () ->
      testValidator(0, true)
    )

  )

  describe('returns error on', () ->

    it('empty string', () ->
      testValidator('', false)
    )

    it('true boolean', () ->
      testValidator(true, false)
    )

    it('false boolean', () ->
      testValidator(false, false)
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
