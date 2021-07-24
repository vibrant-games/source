import express from 'express'
import { config } from '../config/config.js'
import { npcs } from '../config/npcs.js'

const app = express();

//
// Configuration settings:
//
const port = config.web.port;

//
// How we route URLs:
//
app.get('/', (request, response) => {
    response.send('Hello, world!');
});

//
// Start the webserver!
// Listen on all network devices (0.0.0.0) for HTTP connections
// on the configured port.
//
app.listen(port, () => {
    console.log(`node webserver listening on port ${port}`);
});
