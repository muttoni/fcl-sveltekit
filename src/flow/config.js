import { config } from "@onflow/config";
import flowJSON from '../../flow.json';

config({
  "app.detail.title": "FCL Quickstart for SvelteKit", // Shows user what dapp is trying to connect
  "app.detail.icon": "https://unavatar.io/twitter/muttonia", // shows image to the user to display your dapp brand
  "accessNode.api": import.meta.env.VITE_ACCESS_NODE_API,
  "discovery.wallet": import.meta.env.VITE_DISCOVERY_WALLET,
  "flow.network": import.meta.env.VITE_FLOW_NETWORK,
}).load({ flowJSON })