
utils = require('./utils')


testValidator = utils.testValidator('boolean')


describe('Boolean validator', () ->

  describe('passes over', () ->

    it('empty string', () ->
      testValidator({}, '', true)
    )

    it('blank string', () ->
      testValidator({}, '   ', true, '')
    )

    it('zero', () ->
      testValidator({}, 0, true, false)
    )

    it('number', () ->
      testValidator({}, 5, true, true)
    )

    it('null', () ->
      testValidator({}, null, true)
    )

    it('undefined', () ->
      testValidator({}, undefined, true)
    )

    it('true value', () ->
      testValidator({}, true, true)
    )

    it('false value', () ->
      testValidator({}, false, true)
    )

    it('true string value', () ->
      testValidator({}, 'true', true, true)
    )

    it('false string value', () ->
      testValidator({}, 'false', true, false)
    )

    it('true string value with spaces', () ->
      testValidator({}, 'tr u e ', true, true)
    )

    it('false string value with spaces', () ->
      testValidator({}, ' f a lse', true, false)
    )

  )

  describe('returns error on', () ->

    it('empty array', () ->
      testValidator({}, [], false)
    )

    it('invalid string value', () ->
      testValidator({}, 'abcd', false)
    )

  )

)
