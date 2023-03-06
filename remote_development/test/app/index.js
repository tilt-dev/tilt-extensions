const app = require('./app.js');

const port = 8080;

process.on('SIGHUP', () => {
  process.exit()
})
process.on('SIGINT', () => {
  process.exit()
})
app.listen(port, () => {
  console.info('listening on port', 8080);
})