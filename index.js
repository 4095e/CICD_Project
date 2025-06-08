const express = require('express');
const lodash = require('lodash');
const minimatch = require('minimatch');


const app = express();
const port = 3000;


// Example usage of dependencies are here
app.get('/', (req, res) => {
  const obj = lodash.cloneDeep({ message: 'Hello, DevSecOps!' });
  const pattern = minimatch('*.js', '*.js');
  res.send(`${obj.message} (Pattern match: ${pattern})`);
});


app.listen(port, () => {
  console.log(`App running on http://localhost:${port}`);
});
