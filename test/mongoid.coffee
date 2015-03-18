
mongo = require('mongojs')
utils = require('./utils')

ObjectId = mongo.ObjectId


testValidator = utils.testValidator('mongoid')


describe('MongoDB ID validator', () ->

  describe('passes over', () ->

    it('valid ID', () ->
      testValidator(
        {},
        '507f1f77bcf86cd799439011',
        true,
        new ObjectId('507f1f77bcf86cd799439011')
      )
    )

    it('valid ID with spaces', () ->
      testValidator(
        {}
        '  50 7f 1f77b cf86cd79  9439011  '
        true
        new ObjectId('507f1f77bcf86cd799439011')
      )
    )

  )

  describe('returns error on', () ->

    it('empty string', () ->
      testValidator({}, '', false)
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

    it('short ID', () ->
      testValidator({}, '507f1f77bcf86cd7994390', false)
    )

    it('long ID', () ->
      testValidator({}, '507f1f77bcf86cd79943901100', false)
    )

    it('short ID with spaces', () ->
      testValidator(
        {}, '  507f1f77 bcf86cd7994390 ', false, '507f1f77bcf86cd7994390'
      )
    )

    it('long ID with spaces', () ->
      testValidator(
        {}
        ' 507f1f77b  cf86cd7994390 1100  '
        false
        '507f1f77bcf86cd79943901100'
      )
    )

  )




)
