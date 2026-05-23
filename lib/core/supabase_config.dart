import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  const SupabaseConfig({
    required this.url,
    required this.anonKey,
  });

  factory SupabaseConfig.fromDotEnv() {
    return SupabaseConfig(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  }

  final String url;
  final String anonKey;

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
