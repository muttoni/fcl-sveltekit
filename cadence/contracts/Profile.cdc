/** Generic Profile Contract

License: MIT

I am trying to figure out a generic re-usable Profile Micro-Contract
that any application can consume and use. It should be easy to integrate
this contract with any application, and as a user moves from application
to application this profile can come with them. A core concept here is
given a Flow Address, a profiles details can be publically known. This
should mean that if an application were to use/store the Flow address of
a user, than this profile could be visible, and maintained with out storing
a copy in an applications own databases. I believe that anytime we can move
a common database table into a publically accessible contract/resource is a
win.

could be a little more than that too. As Flow Accounts can now have
multiple contracts, it could be fun to allow for these accounts to have
some basic information too. https://flow-view-source.com is a side project
of mine (qvvg) and if you are looking at an account on there, or a contract
deployed to an account I will make it so it pulls info from a properly
configured Profile Resource.

====================
## Table of Contents
====================
                                                               Line
Intro .........................................................   1
Table of Contents .............................................  27
General Profile Contract Info .................................  41
Examples ......................................................  50
  Initializing a Profile Resource .............................  59
  Interacting with Profile Resource (as Owner) ................ 112
  Reading a Profile Given a Flow Address ...................... 160
  Reading a Multiple Profiles Given Multiple Flow Addresses ... 192
  Checking if Flow Account is Initialized ..................... 225


================================
## General Profile Contract Info
================================

Currently a profile consists of a couple main pieces:
  - name – An alias the profile owner would like to be refered as.
  - avatar - An href the profile owner would like applications to use to represent them graphically.
  - color - A valid html color (not verified in any way) applications can use to accent and personalize the experience.
  - info - A short description about the account.

===========
## Examples
===========

The following examples will include both raw cadence transactions and scripts
as well as how you can call them from FCL. The FCL examples are currently assuming
the following configuration is called somewhere in your application before the
the actual calls to the chain are invoked.

==================================
## Initializing a Profile Resource
==================================

Initializing should be done using the paths that the contract exposes.
This will lead to predictability in how applications can look up the data.

-----------
### Cadence
-----------

    import Profile from 0xba1132bc08f82fe2

    transaction {
      let address: address
      prepare(currentUser: auth(SaveValue, PublishCapability, IssueStorageCapabilityController) &Account) {
        self.address = currentUser.address
        if !Profile.check(self.address) {
          let profileCapability = currentUser.capabilities.storage.issue<&{Profile.Public}>(Profile.privatePath)
          currentUser.capabilities.publish(profileCapability, at: Profile.publicPath)
        }
      }
      post {
        Profile.check(self.address): "Account was not initialized"
      }
    }

-------
### FCL
-------

    import {query} from "@onflow/fcl"

    await mutate({
      cadence: `
        import Profile from 0xba1132bc08f82fe2

        transaction {
          prepare(currentUser: auth(SaveValue, PublishCapability, IssueStorageCapabilityController) &Account) {
            self.address = currentUser.address
            if !Profile.check(self.address) {
              currentUser.save(<- Profile.new(), to: Profile.privatePath)
              let profileCapability = currentUser.capabilities.storage.issue<&{Profile.Public}>(Profile.privatePath)
              currentUser.capabilities.publish(profileCapability, at: Profile.publicPath)
            }
          }
          post {
            Profile.check(self.address): "Account was not initialized"
          }
        }
      `,
      limit: 55,
    })

===============================================
## Interacting with Profile Resource (as Owner)
===============================================

As the owner of a resource you can update the following:
  - name using `.setName("MyNewName")` (as long as you arent verified)
  - avatar using `.setAvatar("https://url.to.my.avatar")`
  - color using `.setColor("tomato")`
  - info using `.setInfo("I like to make things with Flow :wave:")`

-----------
### Cadence
-----------

    import Profile from 0xba1132bc08f82fe2

    transaction(name: String) {
      prepare(currentUser: auth(BorrowValue) &Account) {
        currentUser
          .storage
          .borrow<&{Profile.Owner}>(from: Profile.privatePath)!
          .setName(name)
      }
    }

-------
### FCL
-------

    import {mutate} from "@onflow/fcl"

    await mutate({
      cadence: `
        import Profile from 0xba1132bc08f82fe2

        transaction(name: String) {
          prepare(currentUser: auth(BorrowValue) &Account) {
            currentUser
              .storage
              .borrow<&{Profile.Owner}>(from: Profile.privatePath)!
              .setName(name)
          }
        }
      `,
      args: (arg, t) => [
        arg("qvvg", t.String),
      ],
      limit: 55,
    })

=========================================
## Reading a Profile Given a Flow Address
=========================================

-----------
### Cadence
-----------

    import Profile from 0xba1132bc08f82fe2

    access(all) fun main(address: Address): Profile.ReadOnly? {
      return Profile.read(address)
    }

-------
### FCL
-------

    import {query} from "@onflow/fcl"

    await query({
      cadence: `
        import Profile from 0xba1132bc08f82fe2

        access(all) fun main(address: Address): Profile.ReadOnly? {
          return Profile.read(address)
        }
      `,
      args: (arg, t) => [
        arg("0xba1132bc08f82fe2", t.Address)
      ]
    })

============================================================
## Reading a Multiple Profiles Given Multiple Flow Addresses
============================================================

-----------
### Cadence
-----------

    import Profile from 0xba1132bc08f82fe2

    access(all) fun main(addresses: [Address]): {Address: Profile.ReadOnly} {
      return Profile.readMultiple(addresses)
    }

-------
### FCL
-------

    import {query} from "@onflow/fcl"

    await query({
      cadence: `
        import Profile from 0xba1132bc08f82fe2

        access(all) fun main(addresses: [Address]): {Address: Profile.ReadOnly} {
          return Profile.readMultiple(addresses)
        }
      `,
      args: (arg, t) => [
        arg(["0xba1132bc08f82fe2", "0xf76a4c54f0f75ce4", "0xf117a8efa34ffd58"], t.Array(t.Address)),
      ]
    })

==========================================
## Checking if Flow Account is Initialized
==========================================

-----------
### Cadence
-----------

    import Profile from 0xba1132bc08f82fe2

    access(all) fun main(address: Address): Bool {
      return Profile.check(address)
    }

-------
### FCL
-------

    import {query} from "@onflow/fcl"

    await query({
      cadence: `
        import Profile from 0xba1132bc08f82fe2

        access(all) fun main(address: Address): Bool {
          return Profile.check(address)
        }
      `,
      args: (arg, t) => [
        arg("0xba1132bc08f82fe2", t.Address)
      ]
    })

*/
access(all) contract Profile {
  access(all) let publicPath: PublicPath
  access(all) let privatePath: StoragePath

  access(all) resource interface Public {
    access(all) fun getName(): String
    access(all) fun getAvatar(): String
    access(all) fun getColor(): String
    access(all) fun getInfo(): String
    access(all) fun asReadOnly(): Profile.ReadOnly
  }

  access(all) resource interface Owner {
    access(all) fun getName(): String
    access(all) fun getAvatar(): String
    access(all) fun getColor(): String
    access(all) fun getInfo(): String

    access(all) fun setName(_ name: String) {
      pre {
        name.length <= 15: "Names must be under 15 characters long."
      }
    }
    access(all) fun setAvatar(_ src: String)
    access(all) fun setColor(_ color: String)
    access(all) fun setInfo(_ info: String) {
      pre {
        info.length <= 280: "Profile Info can at max be 280 characters long."
      }
    }
  }

  access(all) resource Base: Owner, Public {
    access(self) var name: String
    access(self) var avatar: String
    access(self) var color: String
    access(self) var info: String

    init() {
      self.name = "Anon"
      self.avatar = ""
      self.color = "#232323"
      self.info = ""
    }

    access(all) fun getName(): String { return self.name }
    access(all) fun getAvatar(): String { return self.avatar }
    access(all) fun getColor(): String {return self.color }
    access(all) fun getInfo(): String { return self.info }

    access(all) fun setName(_ name: String) { self.name = name }
    access(all) fun setAvatar(_ src: String) { self.avatar = src }
    access(all) fun setColor(_ color: String) { self.color = color }
    access(all) fun setInfo(_ info: String) { self.info = info }

    access(all) fun asReadOnly(): Profile.ReadOnly {
      return Profile.ReadOnly(
        address: self.owner?.address,
        name: self.getName(),
        avatar: self.getAvatar(),
        color: self.getColor(),
        info: self.getInfo()
      )
    }
  }

  access(all) struct ReadOnly {
    access(all) let address: Address?
    access(all) let name: String
    access(all) let avatar: String
    access(all) let color: String
    access(all) let info: String

    init(address: Address?, name: String, avatar: String, color: String, info: String) {
      self.address = address
      self.name = name
      self.avatar = avatar
      self.color = color
      self.info = info
    }
  }

  access(all) fun new(): @Profile.Base {
    return <- create Base()
  }

  access(all) fun check(_ address: Address): Bool {
    return getAccount(address)
      .capabilities
      .get<&{Profile.Public}>(Profile.publicPath)
      .check()
  }

  access(all) fun fetch(_ address: Address): &{Profile.Public} {
    return getAccount(address)
      .capabilities
      .get<&{Profile.Public}>(Profile.publicPath)
      .borrow()!
  }

  access(all) fun read(_ address: Address): Profile.ReadOnly? {
    if let profile = getAccount(address).capabilities.get<&{Profile.Public}>(Profile.publicPath).borrow() {
      return profile.asReadOnly()
    } else {
      return nil
    }
  }

  access(all) fun readMultiple(_ addresses: [Address]): {Address: Profile.ReadOnly} {
    let profiles: {Address: Profile.ReadOnly} = {}
    for address in addresses {
      let profile = Profile.read(address)
      if profile != nil {
        profiles[address] = profile!
      }
    }
    return profiles
  }


  init() {
    self.publicPath = /public/profile
    self.privatePath = /storage/profile

    self.account.storage.save(<- self.new(), to: self.privatePath)
    let profileCapability = self.account.capabilities.storage.issue<&{Public}>(self.privatePath)
    self.account.capabilities.publish(profileCapability, at: self.publicPath)

    self.account
      .storage
      .borrow<&{Owner}>(from: self.privatePath)!
      .setName("qvvg")
  }
}
