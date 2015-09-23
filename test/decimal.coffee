
utils = require('./utils')


testValidator = utils.testValidator('decimal')


describe('Decimal validator', () ->

  describe('passes over', () ->

    it('decimal', () ->
      testValidator({}, 1.0, true, 1)
    )

    it('decimal string', () ->
      testValidator({}, '1.0', true, 1)
    )

    it('integer', () ->
      testValidator({}, 1, true, 1)
    )

    it('integer string', () ->
      testValidator({}, '1', true, 1)
    )

    it('zero', () ->
      testValidator({}, 0, true, 0)
    )

  )

  describe('returns error on', () ->

    it('string', () ->
      testValidator({}, 'sample', false)
    )

    it('empty string', () ->
      testValidator({}, '', false)
    )

    it('true boolean', () ->
      testValidator({}, true, false)
    )

    it('false boolean', () ->
      testValidator({}, false, false)
    )

    it('null', () ->
      testValidator({}, null, false)
    )

    it('undefined', () ->
      testValidator({}, undefined, false)
    )

    it('empty array', () ->
      testValidator({}, [], false)
    )

  )




)
