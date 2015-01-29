
gulp = require('gulp')
minimist = require('minimist')
mocha = require('gulp-mocha')
run = require('run-sequence')


gulp.task('mocha:app', () ->
  args = minimist(process.argv.slice(3))
  gulp.src('test/**/*')
  .pipe(mocha({
    grep: new RegExp(args['g'])
  }))
)

gulp.task('test', (cb) ->
  run('mocha:app', cb)
)
