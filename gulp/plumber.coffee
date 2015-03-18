
notifier = require('node-notifier')
plumber = require('gulp-plumber')
util = require('gulp-util')


module.exports = () ->
  plumber({
    errorHandler: (err) ->
      util.log(err.stack)
      notifier.notify({
        title: 'Error'
        message: err.message
      })
      @.emit('end')
  })
