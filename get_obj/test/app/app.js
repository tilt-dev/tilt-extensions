const express = require('express');

const app = express();

app.get('/', function(req, res, next) {
  res.send("cool!!!")
});

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

module.exports = app;
