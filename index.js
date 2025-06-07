const express = require('express');
const lodash = require('lodash');
const minimatch = require('minimatch');

const app = express();
const port = 3000;

// Example usage of dependencies
app.get('/', (req, res) => {
  const obj = lodash.cloneDeep({ message: 'Hello, DevSecOps!' });
  const pattern = minimatch('*.js', '*.js');
  res.send(`${obj.message} (Pattern match: ${pattern})`);
});

app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`App running on http://0.0.0.0:${port}`);
});
