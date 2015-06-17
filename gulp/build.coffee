
browserify = require('browserify')
gulp = require('gulp')
source = require('vinyl-source-stream')

plumber = require('./plumber')


gulp.task('build', (done) ->
  browserify('./src/index.coffee', {
    standalone: 'validator'
    extensions: ['.coffee']
    bundleExternal: false
  })
  .bundle()
  .on('error', plumber().errorHandler)
  .pipe(source('validator.js'))
  .pipe(gulp.dest('dist'))
)
