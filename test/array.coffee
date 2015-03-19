
chai = require('chai')

utils = require('./utils')
validators = require('../lib/validators')

expect = chai.expect


testValidator = utils.testValidator('array')


describe('Array validator', () ->

  it('surfaces errors from referenced validators', (done) ->
    validators.sample = {
      test: (config, val, data, cb) -> cb('sample error')
    }
    testValidator({sample:true}, [0], true, [0], null, (err) ->
      expect(err).to.eql('sample error')
      done()
    )
  )

  describe('succeeds on', () ->

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

    it('array with valid values', () ->
      testValidator({boolean:true}, [true, true, false], true)
    )

    it('array with valid values processed', () ->
      testValidator(
        {boolean:true}
        ['true', 'true', 'false']
        true
        [true, true, false]
      )
    )

  )

  describe('fails on', () ->

    it('zero', () ->
      testValidator({}, 0, false)
    )

    it('number', () ->
      testValidator({}, 5, false)
    )

    it('blank string', () ->
      testValidator({}, '   ', false)
    )

    it('array with invalid values', () ->
      testValidator({boolean:true}, ['a', 'b', 'c'], false)
    )

  )

)
