
run = require('run-sequence')
gulp = require('gulp')


require('./gulp/bump')
require('./gulp/test')


gulp.task('default', (cb) ->
  run('test', cb)
)
