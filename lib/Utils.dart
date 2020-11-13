// Utility Functions

bool validUsername(String username) {
  return username.isNotEmpty;
}

bool validPassword(String password) {
  return password.length > 8;
}