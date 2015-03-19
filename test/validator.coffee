
chai = require('chai')
validator = require('../lib')

expect = chai.expect
Validator = validator.Validator
validators = validator.validators


describe('Validator', () ->

  it('surfaces errors', (done) ->
    validator = new Validator({data:{sample:true}})
    validators.sample = {
      msg: 'Sample Error'
      test: (config, val, data, cb) -> cb('sample error')
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
      test: (config, val, data, cb) ->
        expect(val).to.eql('sample data')
        expect(config).to.eql('sample config')
        expect(data).to.eql(sampleData)
        cb(null, true, val)
    }
    validator.validate(sampleData, (err, result) ->
      if err? then return cb(err)
      expect(result).to.eql({})
      done()
    )
  )

  it('uses indicated validator appropriately on multiple fields', (done) ->
    [configs, vals, datas] = [[], [], []]
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
      test: (config, val, data, cb) ->
        configs.push(config)
        vals.push(val)
        datas.push(data)
        cb(null, true, val)
    }
    validator.validate(sampleData, (err, result) ->
      if err? then return cb(err)
      expect(configs).to.eql(['config one', 'config two'])
      expect(vals).to.eql(['data one', 'data two'])
      expect(datas).to.eql([sampleData, sampleData])
      expect(result).to.eql({})
      done()
    )
  )

  it('uses multiple validators appropriately', (done) ->
    [configs, vals, datas] = [[], [], []]
    validator = new Validator({
      data: {
        sampleOne: 'config one'
        sampleTwo: 'config two'
      }
    })
    sampleData = {data:'sample data'}
    validators.sampleOne = {
      msg: 'Error One'
      test: (config, val, data, cb) ->
        configs.push(config)
        vals.push(val)
        datas.push(data)
        cb(null, true, val)
    }
    validators.sampleTwo = {
      msg: 'Error Two'
      test: (config, val, data, cb) ->
        configs.push(config)
        vals.push(val)
        datas.push(data)
        cb(null, true, val)
    }
    validator.validate(sampleData, (err, result) ->
      if err? then return cb(err)
      expect(configs).to.eql(['config one', 'config two'])
      expect(vals).to.eql(['sample data', 'sample data'])
      expect(datas).to.eql([sampleData, sampleData])
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
      test: (config, val, data, cb) ->
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
      test: (config, val, data, cb) ->
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

)
