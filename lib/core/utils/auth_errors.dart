/// Converts raw Supabase / Postgres error messages into
/// short, human-readable strings for display in the UI.
String humaniseAuthError(Object error) {
  final msg = error.toString().toLowerCase();

  // Username already taken (unique constraint on profiles.username)
  if (msg.contains('username') && msg.contains('unique') ||
      msg.contains('duplicate') && msg.contains('username') ||
      msg.contains('profiles_username_key')) {
    return 'That username is already taken. Please choose another.';
  }

  // Email already registered
  if (msg.contains('user already registered') ||
      msg.contains('email already') ||
      msg.contains('already been registered')) {
    return 'An account with that email already exists.';
  }

  // Wrong password / invalid credentials
  if (msg.contains('invalid login credentials') ||
      msg.contains('invalid credentials') ||
      msg.contains('wrong password')) {
    return 'Incorrect email or password.';
  }

  // Email not confirmed
  if (msg.contains('email not confirmed')) {
    return 'Please verify your email before signing in.';
  }

  // Too many requests
  if (msg.contains('too many requests') ||
      msg.contains('rate limit')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }

  if (msg.contains('could not open google') ||
      msg.contains('unable to process request') ||
      msg.contains('error 403') ||
      msg.contains('disallowed_useragent')) {
    return 'Google sign-in could not complete. Please try again.';
  }

  // Weak password
  if (msg.contains('password') && msg.contains('weak') ||
      msg.contains('password should be at least')) {
    return 'Password must be at least 6 characters.';
  }

  // DNS / wrong API host (often mislabeled as "no internet")
  if (msg.contains('failed host lookup') ||
      msg.contains('name or service not known') ||
      msg.contains('nodename nor servname') ||
      msg.contains('xmlhttprequest error')) {
    return 'Cannot reach the server. Check the app configuration or try again.';
  }

  // Network error
  if (msg.contains('socketexception') ||
      msg.contains('clientexception') ||
      msg.contains('connection refused') ||
      msg.contains('connection reset') ||
      msg.contains('network is unreachable') ||
      msg.contains('timed out') ||
      msg.contains('timeout')) {
    return 'No internet connection. Please check your network.';
  }

  // Fallback — strip the raw Postgres prefix if present
  if (msg.contains('postgrest') || msg.contains('pgrst')) {
    return 'Something went wrong. Please try again.';
  }

  // Return a tidied version of the original if nothing matched
  return error
      .toString()
      .replaceAll('Exception: ', '')
      .replaceAll('AuthException: ', '')
      .replaceAll('PostgrestException: ', '');
}
