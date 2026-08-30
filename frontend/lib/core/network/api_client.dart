/// BINISHOP — API Client
/// Centralise tous les appels HTTP vers Medusa.js.
library core.network.api_client;

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import '../config/environment.dart';
import '../storage/token_manager.dart';
import 'api_interceptor.dart';

/// Fichier à uploader (bytes — compatible toutes plateformes).
class UploadFile {
  final String name;
  final Uint8List bytes;
  final String mimeType;
  const UploadFile({
    required this.name,
    required this.bytes,
    this.mimeType = 'application/octet-stream',
  });
}

/// Result type for API calls
typedef ApiResult<T> = ({T? data, String? error, int? statusCode});

/// Unified API client for Medusa.js
class ApiClient {
  late final Dio _dio;
  late final Dio _dioNoAuth;
  final TokenManager _tokenManager;
  final Logger _logger = Logger();

  ApiClient(this._tokenManager) {
    _dio = _createDio();
    _dioNoAuth = _createDio();
  }

  Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: Environment.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Requis par toutes les requetes Store API Medusa v2
        'x-publishable-api-key': Environment.publishableApiKey,
      },
    ));

    dio.interceptors.add(ApiInterceptor(_tokenManager, _logger));
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => _logger.d('[API] $obj'),
    ));

    return dio;
  }

  // --- HTTP Methods ---

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool authenticate = true,
  }) async {
    try {
      final client = authenticate ? _dio : _dioNoAuth;
      final response = await client.get<T>(
        path,
        queryParameters: queryParameters,
      );
      return (data: response.data, error: null, statusCode: response.statusCode);
    } on DioException catch (e) {
      return (data: null, error: _mapError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    bool authenticate = true,
  }) async {
    try {
      final client = authenticate ? _dio : _dioNoAuth;
      final response = await client.post<T>(path, data: data);
      return (data: response.data, error: null, statusCode: response.statusCode);
    } on DioException catch (e) {
      return (data: null, error: _mapError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    bool authenticate = true,
  }) async {
    try {
      final client = authenticate ? _dio : _dioNoAuth;
      final response = await client.put<T>(path, data: data);
      return (data: response.data, error: null, statusCode: response.statusCode);
    } on DioException catch (e) {
      return (data: null, error: _mapError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<ApiResult<T>> delete<T>(
    String path, {
    bool authenticate = true,
  }) async {
    try {
      final client = authenticate ? _dio : _dioNoAuth;
      final response = await client.delete<T>(path);
      return (data: response.data, error: null, statusCode: response.statusCode);
    } on DioException catch (e) {
      return (data: null, error: _mapError(e), statusCode: e.response?.statusCode);
    }
  }

  /// Upload file via presigned URL (direct to MinIO)
  Future<ApiResult<String>> uploadFile(
    String url,
    String filePath,
    String mimeType,
  ) async {
    try {
      final response = await Dio().put(
        url,
        data: filePath,
        options: Options(
          headers: {'Content-Type': mimeType},
        ),
      );
      return (data: 'Upload successful', error: null, statusCode: response.statusCode);
    } on DioException catch (e) {
      return (data: null, error: _mapError(e), statusCode: e.response?.statusCode);
    }
  }

  /// Upload multipart de fichiers vers Medusa (POST /admin/uploads).
  /// Medusa stream vers MinIO via le provider file-s3 — les credentials
  /// MinIO ne quittent JAMAIS le backend (règle sécurité #15).
  /// Utilise des bytes : compatible Web + Mobile + Desktop.
  Future<ApiResult<T>> uploadFiles<T>(
    String path, {
    required List<UploadFile> files,
    bool authenticate = true,
  }) async {
    try {
      final client = authenticate ? _dio : _dioNoAuth;
      final formData = FormData();
      for (final file in files) {
        formData.files.add(MapEntry(
          'files',
          MultipartFile.fromBytes(
            file.bytes,
            filename: file.name,
            contentType: MediaType.parse(file.mimeType),
          ),
        ));
      }
      final response = await client.post<T>(path, data: formData);
      return (data: response.data, error: null, statusCode: response.statusCode);
    } on DioException catch (e) {
      return (data: null, error: _mapError(e), statusCode: e.response?.statusCode);
    }
  }

  /// Map Dio errors to user-friendly messages
  String _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'La connexion a expiré. Vérifiez votre réseau.';
      case DioExceptionType.sendTimeout:
        return 'L\'envoi de la requête a expiré.';
      case DioExceptionType.receiveTimeout:
        return 'La réception de la réponse a expiré.';
      case DioExceptionType.connectionError:
        return 'Impossible de se connecter au serveur.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final message = e.response?.data?['message'] ?? '';
        return _mapStatusCode(statusCode, message as String?);
      case DioExceptionType.cancel:
        return 'Requête annulée.';
      default:
        return 'Erreur réseau inattendue. Réessayez.';
    }
  }

  String _mapStatusCode(int code, String? message) {
    switch (code) {
      case 400:
        return message ?? 'Données invalides.';
      case 401:
        return 'Session expirée. Veuillez vous reconnecter.';
      case 403:
        return 'Accès non autorisé.';
      case 404:
        return 'Ressource introuvable.';
      case 409:
        return message ?? 'Conflit avec les données existantes.';
      case 422:
        return message ?? 'Données non valides.';
      case 429:
        return 'Trop de requêtes. Réessayez plus tard.';
      case 500:
        return 'Erreur serveur. Contactez l\'administration.';
      default:
        return message ?? 'Erreur (code $code).';
    }
  }
}