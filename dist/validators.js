(function() {
  var RE_EMAIL, RE_ENCODING_URL, RE_MONGOID, RE_MSISDN, _, array, async, boolean, date, email, emailmsisdn, encoding, enumerate, geocoordinates, integer, latitude, longitude, match, maxlength, minlength, moment, mongoid, mongojs, msisdn, reference, required, string, strings, url, validurl, weekday;

  _ = require('lodash');

  async = require('async');

  mongojs = require('mongojs');

  moment = require('moment');

  validurl = require('valid-url');

  strings = require('./strings');

  RE_EMAIL = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/;

  RE_MSISDN = /^(\+?27|0)(\d{9})$/;

  RE_MONGOID = /^[a-z0-9]{24}$/;

  RE_ENCODING_URL = /[^\w\d%+.\-\*]/g;

  array = {
    msg: strings.ARRAY,
    test: function(config, val, cb) {
      var items, validateField;
      if (val == null) {
        return cb(null, true, val);
      }
      if (_.isString(val) && _.size(val) === 0) {
        return cb(null, true, val);
      }
      if (!_.isArray(val)) {
        return cb(null, false, val);
      }
      items = _.map(val, function(o) {
        return [null, o, config];
      });
      validateField = _.bind(this.validateField, this);
      return async.map(items, validateField, function(err, result) {
        var fault;
        if (err != null) {
          return cb(err);
        }
        _.each(val, (function(_this) {
          return function(o, n) {
            return val[n] = result[n][1];
          };
        })(this));
        fault = _.find(result, function(o) {
          return o[2] != null;
        });
        if (fault != null) {
          return cb(null, false, val, fault[2]);
        } else {
          return cb(null, true, val);
        }
      });
    }
  };

  boolean = {
    msg: strings.INVALID.BOOLEAN,
    test: function(config, val, cb) {
      if (val == null) {
        return cb(null, true, val);
      }
      if (_.isString(val)) {
        val = val.replace(/\s/g, '');
        if (_.size(val) === 0) {
          return cb(null, true, val);
        }
      }
      if (val === true || val === 'true' || val < 0 || val > 0) {
        return cb(null, true, true);
      }
      if (val === false || val === 'false' || val === 0) {
        return cb(null, true, false);
      }
      return cb(null, false, val);
    }
  };

  date = {
    msg: strings.DATE,
    test: function(config, val, cb) {
      if (_.isNumber(val) || _.isBoolean(val) || _.isArray(val)) {
        return cb(null, false, val);
      }
      if (val == null) {
        return cb(null, true, val);
      }
      val = val.trim();
      if (_.size(val) === 0) {
        return cb(null, true, val);
      }
      date = moment(val, config, true);
      if (date.isValid()) {
        return cb(null, true, date.toDate());
      } else {
        return cb(null, false, val);
      }
    }
  };

  email = {
    msg: strings.INVALID.EMAIL,
    test: function(config, val, cb) {
      var match;
      if (val == null) {
        return cb(null, true, val);
      }
      if (_.size(val) === 0) {
        return cb(null, true, val);
      }
      if (_.isString(val)) {
        val = val.replace(/\s/g, '');
        match = RE_EMAIL.test(val);
        return cb(null, RE_EMAIL.test(val), val);
      } else {
        return cb(null, false, val);
      }
    }
  };

  emailmsisdn = {
    msg: strings.INVALID.EMAIL_MSISDN,
    test: function(config, val, done) {
      var result;
      result = false;
      return async.waterfall([
        (function(_this) {
          return function(cb) {
            var emailTest;
            emailTest = _.bind(email.test, _this);
            return emailTest(config, val, function(err, success, val) {
              if (err != null) {
                return cb(err);
              }
              result = result || success;
              return cb(null, val);
            });
          };
        })(this), (function(_this) {
          return function(val, cb) {
            var msisdnTest;
            msisdnTest = _.bind(msisdn.test, _this);
            return msisdnTest(config, val, function(err, success, val) {
              if (err != null) {
                return cb(err);
              }
              result = result || success;
              return cb(null, val);
            });
          };
        })(this)
      ], function(err, val) {
        if (err != null) {
          return done(err);
        }
        return done(null, result, val);
      });
    }
  };

  encoding = {
    msg: strings.ENCODING,
    test: function(config, val, cb) {
      var err, fault;
      if (val == null) {
        return cb(null, true, val);
      }
      if (!_.isString(val)) {
        return cb(null, false, val);
      }
      if (config === 'url') {
        fault = val.search(RE_ENCODING_URL);
        if (fault > -1) {
          return cb(null, false, val, val[fault]);
        }
        try {
          val = decodeURIComponent(val);
          val = val.replace(/\+/g, ' ');
          return cb(null, true, val);
        } catch (_error) {
          err = _error;
          return cb(null, false, val);
        }
      } else {
        return cb(null, false, val);
      }
    }
  };

  enumerate = {
    msg: strings.INVALID.VALUE,
    test: function(config, val, cb) {
      return cb(null, config.indexOf(val) > -1, val);
    }
  };

  geocoordinates = {
    msg: strings.INVALID.GEO_COORDINATES,
    test: function(config, val, done) {
      var result;
      result = false;
      return async.parallel({
        lat: function(cb) {
          return latitude.test(config, val.lat, function(err, success, val) {
            if (err != null) {
              return cb(err);
            }
            result = result || success;
            return cb(null, val);
          });
        },
        lng: function(cb) {
          return longitude.test(config, val.lng, function(err, success, val) {
            if (err != null) {
              return cb(err);
            }
            result = result || success;
            return cb(null, val);
          });
        }
      }, function(err, result) {
        if (err != null) {
          return done(false, val);
        }
        return done(null, true, result);
      });
    }
  };

  latitude = {
    msg: strings.INVALID.LATITUDE,
    test: function(config, val, cb) {
      val = parseFloat(val);
      if (_.isNaN(val)) {
        return cb(null, false, val);
      }
      if (!((-90 < val && val < 90))) {
        return cb(null, false, val);
      }
      return cb(null, true, val);
    }
  };

  longitude = {
    msg: strings.INVALID.LONGITUDE,
    test: function(config, val, cb) {
      val = parseFloat(val);
      if (_.isNaN(val)) {
        return cb(null, false, val);
      }
      if (!((-180 < val && val < 180))) {
        return cb(null, false, val);
      }
      return cb(null, true, val);
    }
  };

  integer = {
    msg: strings.INVALID.INTEGER,
    test: function(config, val, cb) {
      var result;
      result = parseInt(val);
      if (_.isNaN(result)) {
        return cb(null, false, val);
      } else {
        return cb(null, true, result);
      }
    }
  };

  match = {
    msg: strings.MATCH_REQUIRED,
    test: function(config, val, cb) {
      return cb(null, data[config.field] === val, val);
    }
  };

  maxlength = {
    msg: strings.TOO_LONG,
    test: function(config, val, cb) {
      return cb(null, _.size(val) <= config, val);
    }
  };

  minlength = {
    msg: strings.TOO_SHORT,
    test: function(config, val, cb) {
      return cb(null, _.size(val) >= config, val);
    }
  };

  mongoid = {
    msg: strings.INVALID.MONGOID,
    test: function(config, val, cb) {
      if (val == null) {
        return cb(null, true, val);
      }
      if (!_.isString(val)) {
        return cb(null, false, val);
      }
      if (_.size(val) === 0) {
        return cb(null, true, val);
      }
      val = val.replace(/\s/g, '');
      if (RE_MONGOID.test(val) === true) {
        return cb(null, true, new mongojs.ObjectId(val));
      } else {
        return cb(null, false, val);
      }
    }
  };

  msisdn = {
    msg: strings.INVALID.MSISDN,
    test: function(config, val, cb) {
      if (val == null) {
        return cb(null, true, val);
      }
      if (_.size(val) === 0) {
        return cb(null, true, val);
      }
      if (_.isString(val)) {
        val = val.replace(/\s/g, '');
        match = RE_MSISDN.exec(val);
        if (match === null) {
          return cb(null, false, val);
        } else {
          return cb(null, true, "27" + match[2]);
        }
      } else {
        return cb(null, false, val);
      }
    }
  };

  reference = {
    msg: strings.REFERENCE_NOT_FOUND,
    test: function(config, val, cb) {
      var query;
      if (val == null) {
        return cb(null, true, val);
      }
      if (!_.isString(val)) {
        return cb(null, false, val);
      }
      if (_.size(val) === 0) {
        return cb(null, true, val);
      }
      query = {};
      query[config.field] = val;
      return config.db.collection(config.type).findOne(query, {
        _id: 1
      }, function(err, doc) {
        if (err != null) {
          return cb(err);
        }
        if (doc != null) {
          return cb(null, true, doc._id);
        } else {
          return cb(null, false, val);
        }
      });
    }
  };

  required = {
    msg: strings.REQUIRED,
    test: function(config, val, cb) {
      var valid;
      valid = false;
      valid || (valid = _.isBoolean(val));
      valid || (valid = _.isNumber(val));
      valid || (valid = _.size(val) > 0);
      return cb(null, valid, val);
    }
  };

  string = {
    msg: strings.INVALID.STRING,
    test: function(config, val, cb) {
      if (val == null) {
        return cb(null, true, val);
      } else {
        return cb(null, _.isString(val), val);
      }
    }
  };

  url = {
    msg: strings.INVALID.URI,
    test: function(config, val, cb) {
      if (val == null) {
        return cb(null, true, val);
      } else {
        if (_.isString(val)) {
          val = val.replace(/\s/g, '');
          if (_.size(val) === 0) {
            return cb(null, true, val);
          } else {
            return cb(null, !!validurl.isWebUri(val), val);
          }
        } else {
          return cb(null, false, val);
        }
      }
    }
  };

  weekday = {
    msg: strings.INVALID.WEEKDAY,
    test: function(config, val, cb) {
      var parsed;
      if (val == null) {
        return cb(null, true, val);
      }
      if (_.isString(val)) {
        val = val.replace(/\s/g, '');
        if (_.size(val) === 0) {
          return cb(null, true, val);
        }
        parsed = moment._locale.weekdaysParse(val);
        if (parsed === 0) {
          parsed = 7;
        }
        return cb(null, !!parsed, parsed || val);
      }
      if (_.isNumber(val)) {
        return cb(null, val > 0 && val < 8, val);
      }
      return cb(null, false, val);
    }
  };

  module.exports = {
    array: array,
    boolean: boolean,
    date: date,
    email: email,
    emailmsisdn: emailmsisdn,
    encoding: encoding,
    "enum": enumerate,
    geocoordinates: geocoordinates,
    msisdn: msisdn,
    integer: integer,
    latitude: latitude,
    longitude: longitude,
    match: match,
    maxlength: maxlength,
    minlength: minlength,
    mongoid: mongoid,
    reference: reference,
    required: required,
    string: string,
    url: url,
    weekday: weekday
  };

}).call(this);
