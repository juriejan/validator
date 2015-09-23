#
# utils = require('./utils')
#
#
# testValidator = utils.testValidator('url')
#
#
# describe('URL validator', () ->
#
#   describe('passes over', () ->
#
#     it('HTTP URL without path', () ->
#       testValidator({}, 'http://google.com', true)
#     )
#
#     it('HTTP URL with path', () ->
#       testValidator({}, 'http://google.com/path/to/file', true)
#     )
#
#     it('HTTP URL containing spaces', () ->
#       testValidator(
#         {}
#         '  http:// google.com/ pa th/to/file  '
#         true
#         'http://google.com/path/to/file'
#       )
#     )
#
#     it('HTTPS URL without path', () ->
#       testValidator({}, 'https://google.com', true)
#     )
#
#     it('HTTPS URL with path', () ->
#       testValidator({}, 'https://google.com/path/to/file', true)
#     )
#
#     it('HTTPS URL containing spaces', () ->
#       testValidator(
#         {}
#         '  https:// google.com/ pa th/to/file  '
#         true
#         'https://google.com/path/to/file'
#       )
#     )
#
#     it('empty string', () ->
#       testValidator({}, '', true)
#     )
#
#     it('null', () ->
#       testValidator({}, null, true)
#     )
#
#     it('undefined', () ->
#       testValidator({}, undefined, true)
#     )
#
#   )
#
#   describe('returns error on', () ->
#
#     it('zero', () ->
#       testValidator({}, 0, false)
#     )
#
#     it('number', () ->
#       testValidator({}, 5, false)
#     )
#
#     it('true boolean', () ->
#       testValidator({}, true, false)
#     )
#
#     it('false boolean', () ->
#       testValidator({}, false, false)
#     )
#
#     it('empty array', () ->
#       testValidator({}, [], false)
#     )
#
#     it('URL with no protocol', () ->
#       testValidator({}, 'google.com/path/to/file', false)
#     )
#
#     it('URL with FTP protocol', () ->
#       testValidator({}, 'ftp://google.com/path/to/file', false)
#     )
#
#     it('URL with File protocol', () ->
#       testValidator({}, 'file://google.com/path/to/file', false)
#     )
#
#     it('URL with incorrectly placed characters', () ->
#       testValidator({}, 'google.com/path/to:file', false)
#     )
#
#   )
#
#
#
#
# )
