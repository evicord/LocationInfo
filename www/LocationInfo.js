var exec = require('cordova/exec');

exports.get = function(arg0, success, error) {
    exec(success, error, "LocationInfo", "get", [arg0]);
};
