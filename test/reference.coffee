
async = require('async')
mongojs = require('mongojs')

utils = require('./utils')

ObjectId = mongojs.ObjectId


db = mongojs('mongodb://localhost/validator')

testValidator = utils.testValidator('reference')

config = {
  db: db
  type: 'sample'
  field: 'ref'
}

targetId = new ObjectId()

samples = [{
  _id: targetId
  ref: 'SMP_1'
}, {
  _id: new ObjectId()
  ref: 'SMP_2'
}]


describe('Reference validator', () ->

  beforeEach((done) ->
    db.collection('sample').remove({}, done)
  )

  describe('passes over', () ->

    it('existing object', (done) ->
      async.series([
        (cb) -> db.collection('sample').insert(samples, cb)
        (cb) -> testValidator(config, 'SMP_1', true, targetId, null, cb)
      ], done)
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

  )

  describe('returns error on', () ->

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

    it('non-existing object', (done) ->
      async.series([
        (cb) -> db.collection('sample').insert(samples, cb)
        (cb) -> testValidator(config, 'SMP_3', false, null, null, cb)
      ], done)
    )

  )

)
