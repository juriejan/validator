
utils = require('./utils')


testValidator = utils.testValidator('weekday')


testWeekdayString = (string, value) ->
  it("'#{string}' string value", () ->
    testValidator({}, string, true, value)
  )


describe('Weekday validator', () ->

  describe('succeeds on', () ->

    it('empty string', () ->
      testValidator({}, '', true)
    )

    it('blank string', () ->
      testValidator({}, '   ', true, '')
    )

    it('valid weekday number', () ->
      testValidator({}, 5, true)
    )

    it('null', () ->
      testValidator({}, null, true)
    )

    it('undefined', () ->
      testValidator({}, undefined, true)
    )

    testWeekdayString('mon', 1)
    testWeekdayString('tue', 2)
    testWeekdayString('wed', 3)
    testWeekdayString('thu', 4)
    testWeekdayString('fri', 5)
    testWeekdayString('sat', 6)
    testWeekdayString('sun', 7)

    testWeekdayString('monday', 1)
    testWeekdayString('tuesday', 2)
    testWeekdayString('wednesday', 3)
    testWeekdayString('thursday', 4)
    testWeekdayString('friday', 5)
    testWeekdayString('saturday', 6)
    testWeekdayString('sunday', 7)

  )

  describe('fails on', () ->

    it('zero', () ->
      testValidator({}, 0, false)
    )

    it('invalid weekday number', () ->
      testValidator({}, 10, false)
    )

    it('empty array', () ->
      testValidator({}, [], false)
    )

    it('true value', () ->
      testValidator({}, true, false)
    )

    it('false value', () ->
      testValidator({}, false, false)
    )

  )

)
