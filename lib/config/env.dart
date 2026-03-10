class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ylnusvrdxnljuryxhzgp.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlsbnVzdnJkeG5sanVyeXhoemdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwNzEyMDYsImV4cCI6MjA4ODY0NzIwNn0.5Pbiz31f633wpTEUG7un2Gdm__VNwI9AZYQNwzu1JXM',
  );
  static const bool isDevelopment = true;
}
