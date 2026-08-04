// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capture_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaptureRecord {

/// Unique identifier for this capture.
 String get id;/// Local file path on the device.
 String get localPath;/// Remote URL if synced with the server. Null if not synced.
 String? get remoteUrl;/// The ID of the pose template used, if any.
 String? get poseId;/// The match percentage score achieved (0.0 to 1.0).
 double? get score;/// When the photo was captured.
 DateTime get timestamp;/// Whether this record has been successfully synced to the backend.
 bool get isSynced;
/// Create a copy of CaptureRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaptureRecordCopyWith<CaptureRecord> get copyWith => _$CaptureRecordCopyWithImpl<CaptureRecord>(this as CaptureRecord, _$identity);

  /// Serializes this CaptureRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaptureRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.remoteUrl, remoteUrl) || other.remoteUrl == remoteUrl)&&(identical(other.poseId, poseId) || other.poseId == poseId)&&(identical(other.score, score) || other.score == score)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,localPath,remoteUrl,poseId,score,timestamp,isSynced);

@override
String toString() {
  return 'CaptureRecord(id: $id, localPath: $localPath, remoteUrl: $remoteUrl, poseId: $poseId, score: $score, timestamp: $timestamp, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class $CaptureRecordCopyWith<$Res>  {
  factory $CaptureRecordCopyWith(CaptureRecord value, $Res Function(CaptureRecord) _then) = _$CaptureRecordCopyWithImpl;
@useResult
$Res call({
 String id, String localPath, String? remoteUrl, String? poseId, double? score, DateTime timestamp, bool isSynced
});




}
/// @nodoc
class _$CaptureRecordCopyWithImpl<$Res>
    implements $CaptureRecordCopyWith<$Res> {
  _$CaptureRecordCopyWithImpl(this._self, this._then);

  final CaptureRecord _self;
  final $Res Function(CaptureRecord) _then;

/// Create a copy of CaptureRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? localPath = null,Object? remoteUrl = freezed,Object? poseId = freezed,Object? score = freezed,Object? timestamp = null,Object? isSynced = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,remoteUrl: freezed == remoteUrl ? _self.remoteUrl : remoteUrl // ignore: cast_nullable_to_non_nullable
as String?,poseId: freezed == poseId ? _self.poseId : poseId // ignore: cast_nullable_to_non_nullable
as String?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CaptureRecord].
extension CaptureRecordPatterns on CaptureRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaptureRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaptureRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaptureRecord value)  $default,){
final _that = this;
switch (_that) {
case _CaptureRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaptureRecord value)?  $default,){
final _that = this;
switch (_that) {
case _CaptureRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String localPath,  String? remoteUrl,  String? poseId,  double? score,  DateTime timestamp,  bool isSynced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaptureRecord() when $default != null:
return $default(_that.id,_that.localPath,_that.remoteUrl,_that.poseId,_that.score,_that.timestamp,_that.isSynced);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String localPath,  String? remoteUrl,  String? poseId,  double? score,  DateTime timestamp,  bool isSynced)  $default,) {final _that = this;
switch (_that) {
case _CaptureRecord():
return $default(_that.id,_that.localPath,_that.remoteUrl,_that.poseId,_that.score,_that.timestamp,_that.isSynced);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String localPath,  String? remoteUrl,  String? poseId,  double? score,  DateTime timestamp,  bool isSynced)?  $default,) {final _that = this;
switch (_that) {
case _CaptureRecord() when $default != null:
return $default(_that.id,_that.localPath,_that.remoteUrl,_that.poseId,_that.score,_that.timestamp,_that.isSynced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaptureRecord implements CaptureRecord {
  const _CaptureRecord({required this.id, required this.localPath, this.remoteUrl, this.poseId, this.score, required this.timestamp, this.isSynced = false});
  factory _CaptureRecord.fromJson(Map<String, dynamic> json) => _$CaptureRecordFromJson(json);

/// Unique identifier for this capture.
@override final  String id;
/// Local file path on the device.
@override final  String localPath;
/// Remote URL if synced with the server. Null if not synced.
@override final  String? remoteUrl;
/// The ID of the pose template used, if any.
@override final  String? poseId;
/// The match percentage score achieved (0.0 to 1.0).
@override final  double? score;
/// When the photo was captured.
@override final  DateTime timestamp;
/// Whether this record has been successfully synced to the backend.
@override@JsonKey() final  bool isSynced;

/// Create a copy of CaptureRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaptureRecordCopyWith<_CaptureRecord> get copyWith => __$CaptureRecordCopyWithImpl<_CaptureRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaptureRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaptureRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.remoteUrl, remoteUrl) || other.remoteUrl == remoteUrl)&&(identical(other.poseId, poseId) || other.poseId == poseId)&&(identical(other.score, score) || other.score == score)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,localPath,remoteUrl,poseId,score,timestamp,isSynced);

@override
String toString() {
  return 'CaptureRecord(id: $id, localPath: $localPath, remoteUrl: $remoteUrl, poseId: $poseId, score: $score, timestamp: $timestamp, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class _$CaptureRecordCopyWith<$Res> implements $CaptureRecordCopyWith<$Res> {
  factory _$CaptureRecordCopyWith(_CaptureRecord value, $Res Function(_CaptureRecord) _then) = __$CaptureRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String localPath, String? remoteUrl, String? poseId, double? score, DateTime timestamp, bool isSynced
});




}
/// @nodoc
class __$CaptureRecordCopyWithImpl<$Res>
    implements _$CaptureRecordCopyWith<$Res> {
  __$CaptureRecordCopyWithImpl(this._self, this._then);

  final _CaptureRecord _self;
  final $Res Function(_CaptureRecord) _then;

/// Create a copy of CaptureRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? localPath = null,Object? remoteUrl = freezed,Object? poseId = freezed,Object? score = freezed,Object? timestamp = null,Object? isSynced = null,}) {
  return _then(_CaptureRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,remoteUrl: freezed == remoteUrl ? _self.remoteUrl : remoteUrl // ignore: cast_nullable_to_non_nullable
as String?,poseId: freezed == poseId ? _self.poseId : poseId // ignore: cast_nullable_to_non_nullable
as String?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
