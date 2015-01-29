
expect = require('chai').expect

validators = require('../lib/validators')


testValidator = (val, result, modified) ->
  validators.mongoid.test({}, val, {}, (err, val) ->
    expect(err).to.eql(result)
    if modified? then expect(val).to.eql(modified)
  )


describe('MongoDB ID validator', () ->

  describe('passes over', () ->

    it('valid ID', () ->
      testValidator('507f1f77bcf86cd799439011', true)
    )

    it('valid ID with spaces', () ->
      testValidator(
        '  50 7f 1f77b cf86cd79  9439011  ', true, '507f1f77bcf86cd799439011'
      )
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

    it('short ID', () ->
      testValidator('507f1f77bcf86cd7994390', false)
    )

    it('long ID', () ->
      testValidator('507f1f77bcf86cd79943901100', false)
    )

    it('short ID with spaces', () ->
      testValidator(
        '  507f1f77 bcf86cd7994390 ', false, '507f1f77bcf86cd7994390'
      )
    )

    it('long ID with spaces', () ->
      testValidator(
        ' 507f1f77b  cf86cd7994390 1100  ', false, '507f1f77bcf86cd79943901100'
      )
    )

  )




)
