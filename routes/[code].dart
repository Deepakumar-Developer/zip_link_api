import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;

Future<Response> onRequest(RequestContext context, String code) async {

  var env = DotEnv(includePlatformEnvironment: true)..load();
  final String sbUrl = env['SUPABASE_URL'] ?? '';
  final String sbKey = env['SUPABASE_KEY'] ?? '';
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  if (sbUrl.isEmpty || sbKey.isEmpty) {
    return Response.json(
      statusCode: 500,
      body: {'Supabase keys not configured.'},
    );
  }

  final sbClient = SupabaseClient(sbUrl, sbKey);
  try {
    final response = await sbClient
        .from('urls')
        .select('long_url')
        .eq('short_code', code);
    final longUrl = '${response[0]['long_url']}';

    if (longUrl != 'null' && longUrl.isNotEmpty) {
      if (!(longUrl.startsWith('http://') || longUrl.startsWith('https://'))) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'Invalid URL, must start with http:// or https://'},
        );
      }
      return Response(
        statusCode: HttpStatus.found, // 302 Found
        headers: {
          'Location': longUrl,
        },
      );
    } else {
      return Response(
        statusCode: HttpStatus.notFound, // 404 Not Found
        body: 'URL not found.',
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'An unexpected error occurred.'},
    );
  }

  return Response(body: 'Code: $code');
}
