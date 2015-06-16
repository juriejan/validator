
run = require('run-sequence')
gulp = require('gulp')


require('./gulp/bump')
require('./gulp/test')
require('./gulp/build')


gulp.task('default', (cb) ->
  run('test', cb)
)
