import express from 'express'
import fs from 'fs'
import http from 'http'
import url from 'url'

import { config } from '../config/config.js'
import { npcs } from '../config/npcs.js'

import { npc_process_html } from './services/npc.js'

const app = express();

//
// Configuration settings:
//
const port = config.web.port;

//
// Serve up static files (like stylesheet.css)
// directly.
//
app.use('/', express.static('/var/npcs/html'));

//
// How we route URLs:
//
app.get('/:npc_id_dot_html', (request, response) => {
    const npc_id_dot_html = request.params.npc_id_dot_html;
    const npc_id = npc_id_dot_html.split('\.html')[0];

    console.log(`Enter GET /${npc_id}`);

    try
    {
        const npc = npcs[npc_id];
        if (typeof npc == 'undefined') {
            console.log(`      404 /${npc_id}`);
            response.sendStatus(404);
            return;
        }

        const npc_html_url = new URL(npc.html_url);
        var npc_original_html;
        if (npc_html_url.protocol == 'file:') {
            const npc_html_file_path = url.fileURLToPath(npc_html_url);
            // The following code will block, bad idea!
            // Throws exceptions:
            npc_original_html = fs.readFileSync(npc_html_file_path, 'utf8');
        }
        else
        {
            // Throws exceptions:
            npc_original_html = http.get(npc.html_url, npc_process_html);
        }

        // Throws exceptions:
        const npc_html = npc_process_html(npcs, npc, npc_original_html);

        response.send(npc_html);
    }
    catch (error) {
        console.log(`ERROR GET /${npc_id}: ${error.message}`);
        throw error;
    }

    console.log(`Exit  GET /${npc_id}`);
});

//
// Start the webserver!
// Listen on all network devices (0.0.0.0) for HTTP connections
// on the configured port.
//
app.listen(port, () => {
    console.log(`node webserver listening on port ${port}`);
    const num_npcs = Object.keys(npcs).length;
    console.log(`    ${num_npcs} NPCs`);
});
