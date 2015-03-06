
utils = require('./utils')


testValidator = utils.testValidator('string')


describe('String validator', () ->

  describe('passes over', () ->

    it('string', () ->
      testValidator({}, 'abc', true)
    )

    it('empty string', () ->
      testValidator({}, '', true)
    )

  )

  describe('returns error on', () ->

    it('zero', () ->
      testValidator({}, 0, false)
    )

    it('number', () ->
      testValidator({}, 5, false)
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
