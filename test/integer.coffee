
utils = require('./utils')


testValidator = utils.testValidator('integer')


describe('Integer validator', () ->

  describe('passes over', () ->

    it('integer', () ->
      testValidator({}, 1, true, 1)
    )

    it('floating point', () ->
      testValidator({}, 1.0, true, 1)
    )

    it('integer string', () ->
      testValidator({}, '1', true, 1)
    )

    it('floating point string', () ->
      testValidator({}, '1.0', true, 1)
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
