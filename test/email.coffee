
utils = require('./utils')


module.exports = emailTests = (testValidator) ->

  describe('passes over', () ->

    it('valid address', () ->
      testValidator({}, 'abc@example.com', true, 'abc@example.com')
    )

    it('valid address with space', () ->
      testValidator({}, ' a b c @ example. com', true, 'abc@example.com')
    )

    it('empty string', () ->
      testValidator({}, '', true)
    )

    it('null', () ->
      testValidator({}, null, true)
    )

    it('undefined', () ->
      testValidator({}, undefined, true)
    )

    it('empty array', () ->
      testValidator({}, [], true)
    )

  )

  describe('returns error on', () ->

    it('missing top level domain', () ->
      testValidator({}, 'abc@example', false)
    )

    it('missing domain name', () ->
      testValidator({}, 'abc@.com', false)
    )

    it('missing account name', () ->
      testValidator({}, '@example.com', false)
    )

    it('missing @ sign', () ->
      testValidator({}, 'abcexample.com', false)
    )

    it('missing top level domain with spaces', () ->
      testValidator({}, '  abc@exam ple ', false, 'abc@example')
    )

    it('missing domain name with spaces', () ->
      testValidator({}, 'abc @. com', false, 'abc@.com')
    )

    it('missing account name with spaces', () ->
      testValidator({}, ' @ example.com', false, '@example.com')
    )

    it('missing @ sign with spaces', () ->
      testValidator({}, ' abce  xam ple.com', false, 'abcexample.com')
    )

  )


testValidator = utils.testValidator('email')


describe('Email Address validator', () ->

  emailTests(testValidator)

)
