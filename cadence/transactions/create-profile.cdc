import "Profile"

transaction {
  prepare(account: auth(SaveValue, PublishCapability, IssueStorageCapabilityController) &Account) {
    // Only initialize the account if it hasn't already been initialized
    if (!Profile.check(account.address)) {
      // This creates and stores the profile in the user's account
      account.storage.save(<- Profile.new(), to: Profile.privatePath)

      // This creates the public capability that lets applications read the profile's info
      let profileCapability = account.capabilities.storage.issue<&{Profile.Public}>(Profile.privatePath)
      account.capabilities.publish(profileCapability, at: Profile.publicPath)
    }
  }
}
