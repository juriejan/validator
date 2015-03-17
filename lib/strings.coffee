
module.exports = {
  BLOCKED: 'Field is blocked'
  DATE: "Date did not match '<%= config %>'"
  ENCODING: "Not fully encoded using the '<%= config %>' standard due to '<%= fault %>'"
  IN_USE: 'In use'
  MATCH_REQUIRED: 'Needs to match <%= config.name %>'
  NOT_AVAILABLE: 'Not available'
  REQUIRED: 'Required'
  TOO_SHORT: 'Too short'
  TOO_LONG: 'Too long'
  INVALID: {
    EMAIL: 'Invalid email address'
    EMAIL_MSISDN: 'Invalid email address and mobile number'
    GEO_COORDINATES: 'Invalid geographic coordinates'
    INTEGER: 'Invalid integer'
    LATITUDE: 'Invalid latitude'
    LONGITUDE: 'Invalid longitude'
    MONGOID: 'Invalid ID'
    MSISDN: 'Invalid mobile number'
    STRING: 'Invalid string'
    VALUE: 'Invalid value'
  }
}
