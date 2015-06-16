
gulp = require('gulp')
coffee = require('gulp-coffee')

plumber = require('./plumber')


gulp.task('build', (done) ->
  gulp.src('src/**/*')
  .pipe(plumber())
  .pipe(coffee())
  .pipe(gulp.dest('dist/'))
)
