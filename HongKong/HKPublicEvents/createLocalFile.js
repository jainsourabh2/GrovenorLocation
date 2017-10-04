'use strict';
var fs = require("fs");
const Q = require("q");

module.exports.removeExistingLocalfile = function(filename) {
    let defer = Q.defer();

    if (fs.existsSync(filename)) {
        console.log('Deleting existing local file', filename);
        fs.unlink(filename, function(err) {
            if (err) {
                console.log('Error in deleting existing file', filename, 'Error', err);
                defer.reject(new Error(err));
            }
            else {
                defer.resolve(0);
            }

        });
        defer.resolve(0);
    }
    else {
        defer.resolve(0);
        console.log("File does not exists. Hence creating new file");
    }

    return defer.promise;
}