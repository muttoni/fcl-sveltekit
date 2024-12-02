<script>
  import { profile, user } from "../flow/stores";
  import {
    sendQuery,
    unauthenticate,
    logIn,
    signUp,
    initAccount,
  } from "../flow/actions";

  import UserAddress from "./UserAddress.svelte";
  import Profile from "./Profile.svelte";
</script>

<div class="grid">
  <div class="mb-2">
    {#if $user?.loggedIn && $profile}
      <Profile />
    {:else}
      <h1>Welcome</h1>
      <p>
        This is a starter app built on Flow. It demonstrates how to use the Flow
        Client Library (FCL) with SvelteKit.
      </p>
      {#if !$user?.loggedIn}
        <p>Login to get started.</p>
      {:else}
        <p>Create a profile and then click on Load Profile to see it here.</p>
      {/if}
    {/if}
  </div>
  <div>
    {#if $user?.loggedIn}
      <div>
        <div>
          You are now logged in as: <UserAddress /><button
            on:click={unauthenticate}>Log Out</button
          >
        </div>
        <h2>Controls</h2>
        <button on:click={initAccount}>Create Profile</button>
        <button on:click={() => sendQuery($user.addr)}>Load Profile</button>
      </div>
    {:else}
      <div>
        <button on:click={logIn}>Log In</button>
        <button on:click={signUp}>Sign Up</button>
      </div>
    {/if}
  </div>
</div>
