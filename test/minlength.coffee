
utils = require('./utils')


testValidator = utils.testValidator('minlength')


describe('Minimum length validator', () ->

  describe('passes over', () ->

    it('string equal to required length', () ->
      testValidator(4, 'abcd', true)
    )

    it('string longer than required length', () ->
      testValidator(4, '12345', true)
    )

  )

  describe('returns error on', () ->

    it('empty string', () ->
      testValidator(4, '', false)
    )

    it('null', () ->
      testValidator(4, null, false)
    )

    it('undefined', () ->
      testValidator(4, undefined, false)
    )

    it('empty array', () ->
      testValidator(4, [], false)
    )

    it('string shorter than required length', () ->
      testValidator(4, '123', false)
    )

  )




)
