// vite.config.js
import { sveltekit } from '@sveltejs/kit/vite';
import { nodePolyfills } from 'vite-plugin-node-polyfills'
import inject from '@rollup/plugin-inject'

/** @type {import('vite').UserConfig} */
const config = {
    define: {
        global: 'globalThis'
    },
    plugins: [
        nodePolyfills({
            // Whether to polyfill `node:` protocol imports.
            protocolImports: true,
        }),
        sveltekit()
    ],
    resolve:{
        alias:{
            "node-fetch": "./node_modules/node-fetch/browser.js"
        }
    },
    build: {
        rollupOptions: {
            plugins: [inject({ Buffer: ['buffer', 'Buffer'] })]
        },
    },
    server: {
        fs: {
          // Allow serving files from one level up to the project root
          allow: ['./flow.json', './cadence'],
        },
    },
};
export default config;