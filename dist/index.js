(function() {
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
            _.each(_this.data, function(v, k) {
              return data[k] = _.find(result, function(o) {
                return o[0] === k;
              })[1];
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

}).call(this);
