enum UserRole {
  farmer('Farmer'),
  agronomist('Agronomist'),
  vendor('Vendor');

  const UserRole(this.displayName);
  final String displayName;
}

// Helper to get role from a string (e.g., from Firestore)
UserRole userRoleFromString(String? roleString) {
  return UserRole.values.firstWhere(
        (role) => role.name == roleString,
    orElse: () => UserRole.farmer, // Default role
  );
}