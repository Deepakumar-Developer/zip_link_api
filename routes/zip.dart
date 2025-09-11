import 'dart:io';
import 'dart:math';
import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;

// Your Supabase credentials from the Project Settings -> API page.
// const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
// const String supabaseKey = String.fromEnvironment('SUPABASE_KEY');

Future<Response> onRequest(RequestContext context) async {

  var env = DotEnv(includePlatformEnvironment: true)..load();
  final String sbUrl = env['SUPABASE_URL'] ?? '';
  final String sbKey = env['SUPABASE_KEY'] ?? '';
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  if (sbUrl.isEmpty || sbKey.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'Supabase keys not configured.'},
    );
  }

  // Parse the request body to get the long URL.
  // final body = await context.request.json() as Map<String, dynamic>;
  final body = await context.request.uri.queryParameters;
  final longUrl = body['long_url'];

  // Validate the input URL.
  if (longUrl == null || longUrl.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'Missing long_url in request body.'},
    );
  }

  // Initialize the Supabase client.
  final sbClient = SupabaseClient(sbUrl, sbKey);

  // Generate a unique short code.

  try {
    // Insert the long URL and short code into the 'urls' table.
    final r = await sbClient.from('urls').select('id, short_code').eq('long_url', longUrl);
    print('Response from Supabase: $r');
    if (r.isNotEmpty) {
      final existingShortCode = r[0]['short_code'];
      return Response.json(body: {'short_url': 'https://ziplink.com/$existingShortCode'});
    }

    final shortCode = _generateShortCode();
    
    final response = await sbClient.from('urls').insert({
      'long_url': longUrl,
      'short_code': shortCode,
    }).select('id, short_code');




    // Check if the insertion was successful.
    if (response.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'Failed to shorten URL.'},
      );
    }

    // Return the shortened URL to the client.
    return Response.json(body: {'short_url': 'https://ziplink.com/$shortCode'});

  } catch (e) {
    // Handle any errors during the database operation.
    print('Error: $e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'An unexpected error occurred.'},
    );
  }
}

// A simple function to generate a 6-character random string.
String _generateShortCode() {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return String.fromCharCodes(Iterable.generate(6, (_) {
    return chars.codeUnitAt(random.nextInt(chars.length));
  }));
}