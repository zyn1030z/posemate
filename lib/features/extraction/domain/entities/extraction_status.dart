/// Represents the current status of an async pose extraction job.
enum ExtractionStatus {
  /// The image file is being uploaded to the extraction service.
  uploading,

  /// The server is processing the uploaded image and extracting pose landmarks.
  processing,

  /// Extraction completed successfully and the pose result is ready.
  completed,

  /// Extraction failed due to an error (e.g. no pose detected, processing failure).
  failed,
}
