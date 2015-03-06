
utils = require('./utils')


testValidator = utils.testValidator('date')

FORMAT = 'YYYY MM DD'
DATE = new Date(2015, 0, 1)


describe('Date validator', () ->

  describe('passes over', () ->

    it('date with correct format', () ->
      testValidator(FORMAT, '2015 01 01', true, DATE)
    )

    it('date with correct format and extra spaces', () ->
      testValidator(FORMAT, '  2015 01 01  ', true, DATE)
    )

    it('empty string', () ->
      testValidator(FORMAT, '', true)
    )

    it('blank string', () ->
      testValidator(FORMAT, '   ', true)
    )

    it('null', () ->
      testValidator(FORMAT, null, true)
    )

    it('undefined', () ->
      testValidator(FORMAT, undefined, true)
    )

  )

  describe('returns error on', () ->

    it('zero', () ->
      testValidator(FORMAT, 0, false)
    )

    it('number', () ->
      testValidator(FORMAT, 5, false)
    )

    it('false boolean', () ->
      testValidator(FORMAT, false, false)
    )

    it('true boolean', () ->
      testValidator(FORMAT, true, false)
    )

    it('empty array', () ->
      testValidator(FORMAT, [], false)
    )

  )




)
