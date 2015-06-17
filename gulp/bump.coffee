
_ = require('lodash')

async = require('async')
end = require('stream-end')
fs = require('fs-extra')
gulp = require('gulp')
jsonedit = require('gulp-json-editor')
minimist = require('minimist')
semver = require('semver')


bumpVersion = (filename, done) ->
  version = null
  async.series([
    (cb) ->
      fs.readJson(filename, (err, data) ->
        if err? then return cb(err)
        args = minimist(process.argv.slice(3))
        type = _.keys(args)[1] or 'patch'
        version = data.version
        version = semver.inc(version, type)
        cb()
      )
    (cb) ->
      gulp.src([filename])
      .pipe(jsonedit({version}))
      .pipe(gulp.dest('./'))
      .pipe(end(cb))
  ], done)


gulp.task('bump', (done) ->
  async.series([
    (cb) -> bumpVersion('package.json', cb)
    (cb) -> bumpVersion('bower.json', cb)
  ], done)
)
