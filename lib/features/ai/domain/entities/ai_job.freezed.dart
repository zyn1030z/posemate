// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AiJob<T> {

/// The unique identifier used for polling.
 String get jobId;/// The current state of the job.
 AiJobStatus get status;/// Progress percentage (0-100).
 int get progress;/// Estimated time remaining in seconds.
 int? get estimatedSeconds;/// The final result payload, present only when status is succeeded.
 T? get result;/// Error details, present only when status is failed.
 String? get error;
/// Create a copy of AiJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiJobCopyWith<T, AiJob<T>> get copyWith => _$AiJobCopyWithImpl<T, AiJob<T>>(this as AiJob<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiJob<T>&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.estimatedSeconds, estimatedSeconds) || other.estimatedSeconds == estimatedSeconds)&&const DeepCollectionEquality().equals(other.result, result)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,jobId,status,progress,estimatedSeconds,const DeepCollectionEquality().hash(result),error);

@override
String toString() {
  return 'AiJob<$T>(jobId: $jobId, status: $status, progress: $progress, estimatedSeconds: $estimatedSeconds, result: $result, error: $error)';
}


}

/// @nodoc
abstract mixin class $AiJobCopyWith<T,$Res>  {
  factory $AiJobCopyWith(AiJob<T> value, $Res Function(AiJob<T>) _then) = _$AiJobCopyWithImpl;
@useResult
$Res call({
 String jobId, AiJobStatus status, int progress, int? estimatedSeconds, T? result, String? error
});




}
/// @nodoc
class _$AiJobCopyWithImpl<T,$Res>
    implements $AiJobCopyWith<T, $Res> {
  _$AiJobCopyWithImpl(this._self, this._then);

  final AiJob<T> _self;
  final $Res Function(AiJob<T>) _then;

/// Create a copy of AiJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobId = null,Object? status = null,Object? progress = null,Object? estimatedSeconds = freezed,Object? result = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AiJobStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,estimatedSeconds: freezed == estimatedSeconds ? _self.estimatedSeconds : estimatedSeconds // ignore: cast_nullable_to_non_nullable
as int?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as T?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiJob].
extension AiJobPatterns<T> on AiJob<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiJob<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiJob<T> value)  $default,){
final _that = this;
switch (_that) {
case _AiJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiJob<T> value)?  $default,){
final _that = this;
switch (_that) {
case _AiJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String jobId,  AiJobStatus status,  int progress,  int? estimatedSeconds,  T? result,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiJob() when $default != null:
return $default(_that.jobId,_that.status,_that.progress,_that.estimatedSeconds,_that.result,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String jobId,  AiJobStatus status,  int progress,  int? estimatedSeconds,  T? result,  String? error)  $default,) {final _that = this;
switch (_that) {
case _AiJob():
return $default(_that.jobId,_that.status,_that.progress,_that.estimatedSeconds,_that.result,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String jobId,  AiJobStatus status,  int progress,  int? estimatedSeconds,  T? result,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _AiJob() when $default != null:
return $default(_that.jobId,_that.status,_that.progress,_that.estimatedSeconds,_that.result,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _AiJob<T> implements AiJob<T> {
  const _AiJob({required this.jobId, required this.status, this.progress = 0, this.estimatedSeconds, this.result, this.error});
  

/// The unique identifier used for polling.
@override final  String jobId;
/// The current state of the job.
@override final  AiJobStatus status;
/// Progress percentage (0-100).
@override@JsonKey() final  int progress;
/// Estimated time remaining in seconds.
@override final  int? estimatedSeconds;
/// The final result payload, present only when status is succeeded.
@override final  T? result;
/// Error details, present only when status is failed.
@override final  String? error;

/// Create a copy of AiJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiJobCopyWith<T, _AiJob<T>> get copyWith => __$AiJobCopyWithImpl<T, _AiJob<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiJob<T>&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.estimatedSeconds, estimatedSeconds) || other.estimatedSeconds == estimatedSeconds)&&const DeepCollectionEquality().equals(other.result, result)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,jobId,status,progress,estimatedSeconds,const DeepCollectionEquality().hash(result),error);

@override
String toString() {
  return 'AiJob<$T>(jobId: $jobId, status: $status, progress: $progress, estimatedSeconds: $estimatedSeconds, result: $result, error: $error)';
}


}

/// @nodoc
abstract mixin class _$AiJobCopyWith<T,$Res> implements $AiJobCopyWith<T, $Res> {
  factory _$AiJobCopyWith(_AiJob<T> value, $Res Function(_AiJob<T>) _then) = __$AiJobCopyWithImpl;
@override @useResult
$Res call({
 String jobId, AiJobStatus status, int progress, int? estimatedSeconds, T? result, String? error
});




}
/// @nodoc
class __$AiJobCopyWithImpl<T,$Res>
    implements _$AiJobCopyWith<T, $Res> {
  __$AiJobCopyWithImpl(this._self, this._then);

  final _AiJob<T> _self;
  final $Res Function(_AiJob<T>) _then;

/// Create a copy of AiJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobId = null,Object? status = null,Object? progress = null,Object? estimatedSeconds = freezed,Object? result = freezed,Object? error = freezed,}) {
  return _then(_AiJob<T>(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AiJobStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,estimatedSeconds: freezed == estimatedSeconds ? _self.estimatedSeconds : estimatedSeconds // ignore: cast_nullable_to_non_nullable
as int?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as T?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
