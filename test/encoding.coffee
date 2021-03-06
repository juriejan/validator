
utils = require('./utils')


testValidator = utils.testValidator('encoding')


describe('Encoding validator', () ->

  describe('succeeds on', () ->

    it('url encoded string', () ->
      testValidator('url', 'a%20b%22c+d.f-g*h', true, 'a b"c d.f-g*h')
    )

    it('empty string', () ->
      testValidator('url', '', true)
    )

    it('null', () ->
      testValidator('url', null, true)
    )

    it('undefined', () ->
      testValidator('url', undefined, true)
    )

  )

  describe('fails on', () ->

    it('url encoded string with bad encoding', () ->
      testValidator('url', 'a%%20b%22c', false)
    )

    it("url encoded string that isn't fully encoded", () ->
      testValidator('url', 'a%20b"c', false, 'a%20b"c', '"')
    )

    it('blank string', () ->
      testValidator('url', '   ', false)
    )

    it('zero', () ->
      testValidator('url', 0, false)
    )

    it('number', () ->
      testValidator('url', 5, false)
    )

    it('false boolean', () ->
      testValidator('url', false, false)
    )

    it('true boolean', () ->
      testValidator('url', true, false)
    )

    it('empty array', () ->
      testValidator('url', [], false)
    )

  )

)
