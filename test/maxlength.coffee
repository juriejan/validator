
utils = require('./utils')


testValidator = utils.testValidator('maxlength')


describe('Maximum length validator', () ->

  describe('passes over', () ->

    it('string equal to required length', () ->
      testValidator(4, 'abcd', true)
    )

    it('string shorter than required length', () ->
      testValidator(4, '123', true)
    )

    it('empty string', () ->
      testValidator(4, '', true)
    )

    it('null', () ->
      testValidator(4, null, true)
    )

    it('undefined', () ->
      testValidator(4, undefined, true)
    )

    it('empty array', () ->
      testValidator(4, [], true)
    )

  )

  describe('returns error on', () ->

    it('string longer than required length', () ->
      testValidator(4, '12345', false)
    )

  )




)
