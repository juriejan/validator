
gulp = require('gulp')
minimist = require('minimist')
mocha = require('gulp-mocha')
run = require('run-sequence')

plumber = require('./plumber')


gulp.task('mocha:app', () ->
  args = minimist(process.argv.slice(3))
  gulp.src('test/**/*')
  .pipe(plumber())
  .pipe(mocha({
    grep: new RegExp(args['g'])
  }))
  .once('error', () -> process.exit(1))
  .once('end', () -> process.exit())
)

gulp.task('test', (cb) ->
  run('mocha:app', cb)
)
