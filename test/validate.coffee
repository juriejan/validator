
chai = require('chai')

utils = require('./utils')
validators = require('../src/validators')

expect = chai.expect


testValidator = utils.testValidator('validate')


describe('Validate validator', () ->

  describe('succeeds on', () ->

    it('null', () ->
      testValidator({}, null, true)
    )

    it('undefined', () ->
      testValidator({}, undefined, true)
    )

    it('valid validation', () ->
      validators.succeed = {
        msg: 'Sample Message'
        test: (config, val, cb) ->
          expect(val).to.eql('data')
          cb(null, true, val)
      }
      testValidator({sample:{succeed:true}}, {sample:'data'}, true)
    )

  )

  describe('fails on', () ->

    it('invalid validation', () ->
      validators.fail = {
        msg: 'Sample Message'
        test: (config, val, cb) ->
          expect(val).to.eql('data')
          cb(null, false, val)
      }
      testValidator({sample:{fail:true}}, {sample:'data'}, false)
    )

  )

)
