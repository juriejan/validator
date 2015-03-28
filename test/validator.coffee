
chai = require('chai')
validator = require('../src')

expect = chai.expect
Validator = validator.Validator
validators = validator.validators
strings = validator.strings


describe('Validator', () ->

  it('surfaces errors', (done) ->
    validator = new Validator({data:{sample:true}})
    validators.sample = {
      msg: 'Sample Message'
      test: (config, val, cb) -> cb('sample error')
    }
    validator.validate({data:0}, (err) ->
      expect(err).to.eql('sample error')
      done()
    )
  )

  it('uses indicated validator appropriately', (done) ->
    validator = new Validator({
      data: {sample:'sample config'}
    })
    sampleData = {
      data: 'sample data'
    }
    validators.sample = {
      msg: 'Error'
      test: (config, val, cb) ->
        expect(@).to.eql(validator)
        expect(val).to.eql('sample data')
        expect(config).to.eql('sample config')
        cb(null, true, val)
    }
    validator.validate(sampleData, (err, result) ->
      if err? then return cb(err)
      expect(result).to.eql({})
      done()
    )
  )

  it('uses indicated validator appropriately on multiple fields', (done) ->
    [configs, vals] = [[], []]
    validator = new Validator({
      one: {sample:'config one'}
      two: {sample:'config two'}
    })
    sampleData = {
      one: 'data one'
      two: 'data two'
    }
    validators.sample = {
      msg: 'Error'
      test: (config, val, cb) ->
        configs.push(config)
        vals.push(val)
        cb(null, true, val)
    }
    validator.validate(sampleData, (err, result) ->
      if err? then return cb(err)
      expect(configs).to.eql(['config one', 'config two'])
      expect(vals).to.eql(['data one', 'data two'])
      expect(result).to.eql({})
      done()
    )
  )

  it('uses multiple validators appropriately', (done) ->
    [configs, vals] = [[], []]
    validator = new Validator({
      data: {
        sampleOne: 'config one'
        sampleTwo: 'config two'
      }
    })
    sampleData = {data:'sample data'}
    validators.sampleOne = {
      msg: 'Error One'
      test: (config, val, cb) ->
        configs.push(config)
        vals.push(val)
        cb(null, true, val)
    }
    validators.sampleTwo = {
      msg: 'Error Two'
      test: (config, val, cb) ->
        configs.push(config)
        vals.push(val)
        cb(null, true, val)
    }
    validator.validate(sampleData, (err, result) ->
      if err? then return cb(err)
      expect(configs).to.eql(['config one', 'config two'])
      expect(vals).to.eql(['sample data', 'sample data'])
      expect(result).to.eql({})
      done()
    )
  )

  it('returns validator errors appropriately', (done) ->
    validator = new Validator({
      one: {sample:true}
      two: {sample:true}
    })
    sampleData = {
      one: 'data one'
      two: 'data two'
    }
    validators.sample = {
      msg: 'Sample Error'
      test: (config, val, cb) ->
        cb(null, false, val)
    }
    validator.validate(sampleData, (err, result) ->
      if err? then return cb(err)
      expect(result).to.eql({
        one: 'Sample Error'
        two: 'Sample Error'
      })
      done()
    )
  )

  it('modifies values on data according to validators', (done) ->
    validator = new Validator({
      one: {sample:true}
      two: {sample:true}
    })
    sampleData = {
      one: 'data one'
      two: 'data two'
    }
    validators.sample = {
      msg: 'Sample Error'
      test: (config, val, cb) ->
        cb(null, true, "altered #{val}")
    }
    validator.validate(sampleData, (err, result) ->
      if err? then return cb(err)
      expect(sampleData).to.eql({
        one: 'altered data one'
        two: 'altered data two'
      })
      done()
    )
  )

  it('runs validators for missing data', (done) ->
    validated = false
    validator = new Validator({data:{sample:true}})
    validators.sample = {
      msg: 'Sample Error'
      test: (config, val, cb) ->
        validated = true
        cb(null, true, val)
    }
    validator.validate({}, (err, result) ->
      if err? then return cb(err)
      expect(validated).to.eql(true)
      done()
    )
  )

  it('raises an error for unexpected fields', (done) ->
    validator = new Validator({})
    data = {data:'sample data'}
    validator.validate(data, (err, result) ->
      if err? then return cb(err)
      expect(result).to.eql({
        data: strings.UNEXPECTED
      })
      done()
    )
  )

)
