import 'dart:io';

import 'package:dio/dio.dart';
import 'package:posely_ai/features/gallery/domain/entities/capture_record.dart';
import 'package:retrofit/retrofit.dart';

part 'gallery_api_client.g.dart';

/// Retrofit client for the remote gallery endpoints.
@RestApi()
abstract class GalleryApiClient {
  factory GalleryApiClient(Dio dio, {String baseUrl}) = _GalleryApiClient;

  /// Fetches a paginated list of remote captures.
  @GET('/gallery/photos')
  Future<List<CaptureRecord>> getRemoteCaptures({
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  /// Uploads a new capture to the remote gallery.
  @POST('/gallery/photos')
  @MultiPart()
  Future<CaptureRecord> uploadCapture({
    @Part() required File file,
    @Part() String? poseId,
    @Part() double? score,
    @Part() required String capturedAt, // ISO-8601 string
  });

  /// Deletes a capture from the remote gallery.
  @DELETE('/gallery/photos/{id}')
  Future<void> deleteCapture(@Path('id') String id);
}
