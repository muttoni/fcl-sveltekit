import "Profile"

transaction(name: String, color: String, info: String) {
  prepare(account: auth(BorrowValue) &Account) {
    account
      .storage
      .borrow<&{Profile.Owner}>(from: Profile.privatePath)!
      .setName(name)

    account
      .storage
      .borrow<&{Profile.Owner}>(from: Profile.privatePath)!
      .setInfo(info)

    account
      .storage
      .borrow<&{Profile.Owner}>(from: Profile.privatePath)!
      .setColor(color)
  }
}
