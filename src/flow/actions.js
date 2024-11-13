import { browser } from '$app/environment';
import { get } from 'svelte/store';
import ReadProfileScript from '../../cadence/scripts/read-profile.cdc?raw'
import CreateProfileTransaction from '../../cadence/transactions/create-profile.cdc?raw'
import UpdateProfileTransaction from '../../cadence/transactions/update-profile.cdc?raw'

import * as fcl from "@onflow/fcl";
import "./config";
import { user, profile, transactionStatus, transactionInProgress, txId } from './stores';

if(browser) {
  // set Svelte $user store to currentUser, 
  // so other components can access it
  fcl.currentUser.subscribe(user.set, [])
}

// Lifecycle FCL Auth functions
export const unauthenticate = () => fcl.unauthenticate()
export const logIn = () => fcl.logIn()
export const signUp = () => fcl.signUp()

// init account
export const initAccount = async () => {
  let transactionId = false;
  initTransactionState()

  try {
    transactionId = await fcl.mutate({
      cadence: CreateProfileTransaction,
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 50
    })

    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if(res.status === 4) {
        setTimeout(() => transactionInProgress.set(false),2000)
      }
    })

  } catch (e) {
    transactionStatus.set(99)
    console.log(e)
  }
}

// send a transaction to get a user's profile
export const sendQuery = async (addr) => {
  let profileQueryResult = false;

  try {
    profileQueryResult = await fcl.query({
      cadence: ReadProfileScript,
      args: (arg, t) => [arg(addr, t.Address)]
    })
    console.log(profileQueryResult)
    profile.set(profileQueryResult);

  } catch(e) {
    console.log(e);
  }
}

export const executeTransaction = async () => {
  initTransactionState()
  try {
    const transactionId = await fcl.mutate({
      cadence: UpdateProfileTransaction,
      args: (arg, t) => [
        arg(get(profile).name, t.String),
        arg(get(profile).color, t.String),
        arg(get(profile).info, t.String),
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 50
    })

    
    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if(res.status === 4) {
        setTimeout(() => transactionInProgress.set(false),2000)
      }
    })
  } catch(e) {
    console.log(e);
    transactionStatus.set(99)
  }
}

function initTransactionState() {
  txId.set(false);
  transactionInProgress.set(true);
  transactionStatus.set(-1);
}