(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.validator = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Validator, _, async, strings, validators;

_ = require('lodash');

async = require('async');

strings = require('./strings');

validators = require('./validators');

Validator = function(validation) {
  if (validation == null) {
    validation = {};
  }
  return {
    validateRule: function(state, item, cb) {
      var config, field, message, rule, test, val, validator;
      field = state[0], val = state[1], message = state[2];
      rule = item[0], config = item[1];
      validator = validators[rule];
      test = _.bind(validator.test, this);
      return test(config, val, function(err, success, val, fault) {
        if (err != null) {
          return cb(err);
        }
        if (!success) {
          message = _.template(validator.msg)({
            config: config,
            fault: fault,
            val: val
          });
          return cb(true, [field, val, message]);
        } else {
          return cb(null, [field, val, message]);
        }
      });
    },
    validateField: function(item, cb) {
      var field, rules, val, validateRule;
      field = item[0], val = item[1], rules = item[2];
      validateRule = _.bind(this.validateRule, this);
      if (rules == null) {
        return cb(null, [field, val, strings.UNEXPECTED]);
      }
      rules = _.pairs(rules);
      return async.reduce(rules, [field, val, null], validateRule, function(err, result) {
        if (err === true) {
          return cb(null, result);
        } else if (err != null) {
          return cb(err);
        }
        return cb(null, result);
      });
    },
    validate: function(data, cb) {
      var items, keys, validateField;
      this.data = data;
      validateField = _.bind(this.validateField, this);
      keys = _.union(_.keys(this.data), _.keys(validation));
      items = _.map(keys, function(o) {
        return [o, data[o], validation[o]];
      });
      return async.map(items, validateField, (function(_this) {
        return function(err, result) {
          if (err != null) {
            return cb(err);
          }
          _.each(data, function(v, k) {
            data[k] = _.find(result, function(o) {
              return o[0] === k;
            })[1];
            return true;
          });
          result = _.filter(result, function(o) {
            return o[2] != null;
          });
          result = _.map(result, function(o) {
            return [o[0], o[2]];
          });
          return cb(err, _.object(result));
        };
      })(this));
    }
  };
};

module.exports = {
  Validator: Validator,
  validators: validators,
  strings: strings
};


},{"./strings":2,"./validators":3,"async":undefined,"lodash":undefined}],2:[function(require,module,exports){
module.exports = {
  ARRAY: "Array item encountered error: <%= fault %>",
  BLOCKED: 'Field is blocked',
  DATE: "Date did not match '<%= config %>'",
  ENCODING: "Not fully encoded using the '<%= config %>' standard due to '<%= fault %>'",
  IN_USE: 'In use',
  MATCH_REQUIRED: 'Needs to match <%= config.name %>',
  NOT_AVAILABLE: 'Not available',
  REFERENCE_NOT_FOUND: "Reference not found with value '<%= val %>' on field '<%= config.field %>'",
  REQUIRED: 'Required',
  TOO_SHORT: 'Too short',
  TOO_LONG: 'Too long',
  UNEXPECTED: 'Unexpected',
  INVALID: {
    BOOLEAN: 'Invalid boolean',
    EMAIL: 'Invalid email address',
    EMAIL_MSISDN: 'Invalid email address and mobile number',
    GEO_COORDINATES: 'Invalid geographic coordinates',
    INTEGER: 'Invalid integer',
    LATITUDE: 'Invalid latitude',
    LONGITUDE: 'Invalid longitude',
    MONGOID: 'Invalid ID',
    MSISDN: 'Invalid mobile number',
    STRING: 'Invalid string',
    VALUE: 'Invalid value',
    VALIDATE: 'Failed validation'
  }
};


},{}],3:[function(require,module,exports){
var RE_EMAIL, RE_ENCODING_URL, RE_MSISDN, _, array, async, boolean, date, email, emailmsisdn, encoding, enumerate, geocoordinates, integer, latitude, longitude, match, maxlength, minlength, moment, msisdn, reference, required, string, strings, validate, weekday;

_ = require('lodash');

async = require('async');

moment = require('moment');

strings = require('./strings');

RE_EMAIL = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/;

RE_MSISDN = /^(\+?27|0)(\d{9})$/;

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
      parsed = moment.localeData().weekdaysParse(val);
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

validate = {
  msg: strings.INVALID.VALIDATE,
  test: function(config, val, cb) {
    var validator;
    if (val == null) {
      return cb(null, true, val);
    }
    validator = new require('./').Validator(config);
    return validator.validate(val, function(err, result) {
      if (err != null) {
        return cb(err);
      }
      if (_.size(result) > 0) {
        return cb(null, false, val);
      } else {
        return cb(null, true, val);
      }
    });
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
  reference: reference,
  required: required,
  string: string,
  weekday: weekday,
  validate: validate
};


},{"./strings":2,"async":undefined,"lodash":undefined,"moment":undefined}]},{},[1])(1)
});