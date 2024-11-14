import "Profile"

access(all) fun main(address: Address): Profile.ReadOnly? {
  return Profile.read(address)
}
