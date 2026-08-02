// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_job_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiJobModel<T> {

 String get jobId; String get status; int get progress; int? get estimatedSeconds; T? get result; String? get error;
/// Create a copy of AiJobModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiJobModelCopyWith<T, AiJobModel<T>> get copyWith => _$AiJobModelCopyWithImpl<T, AiJobModel<T>>(this as AiJobModel<T>, _$identity);

  /// Serializes this AiJobModel to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiJobModel<T>&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.estimatedSeconds, estimatedSeconds) || other.estimatedSeconds == estimatedSeconds)&&const DeepCollectionEquality().equals(other.result, result)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status,progress,estimatedSeconds,const DeepCollectionEquality().hash(result),error);

@override
String toString() {
  return 'AiJobModel<$T>(jobId: $jobId, status: $status, progress: $progress, estimatedSeconds: $estimatedSeconds, result: $result, error: $error)';
}


}

/// @nodoc
abstract mixin class $AiJobModelCopyWith<T,$Res>  {
  factory $AiJobModelCopyWith(AiJobModel<T> value, $Res Function(AiJobModel<T>) _then) = _$AiJobModelCopyWithImpl;
@useResult
$Res call({
 String jobId, String status, int progress, int? estimatedSeconds, T? result, String? error
});




}
/// @nodoc
class _$AiJobModelCopyWithImpl<T,$Res>
    implements $AiJobModelCopyWith<T, $Res> {
  _$AiJobModelCopyWithImpl(this._self, this._then);

  final AiJobModel<T> _self;
  final $Res Function(AiJobModel<T>) _then;

/// Create a copy of AiJobModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobId = null,Object? status = null,Object? progress = null,Object? estimatedSeconds = freezed,Object? result = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,estimatedSeconds: freezed == estimatedSeconds ? _self.estimatedSeconds : estimatedSeconds // ignore: cast_nullable_to_non_nullable
as int?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as T?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiJobModel].
extension AiJobModelPatterns<T> on AiJobModel<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiJobModel<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiJobModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiJobModel<T> value)  $default,){
final _that = this;
switch (_that) {
case _AiJobModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiJobModel<T> value)?  $default,){
final _that = this;
switch (_that) {
case _AiJobModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String jobId,  String status,  int progress,  int? estimatedSeconds,  T? result,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiJobModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String jobId,  String status,  int progress,  int? estimatedSeconds,  T? result,  String? error)  $default,) {final _that = this;
switch (_that) {
case _AiJobModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String jobId,  String status,  int progress,  int? estimatedSeconds,  T? result,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _AiJobModel() when $default != null:
return $default(_that.jobId,_that.status,_that.progress,_that.estimatedSeconds,_that.result,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _AiJobModel<T> extends AiJobModel<T> {
  const _AiJobModel({required this.jobId, required this.status, this.progress = 0, this.estimatedSeconds, this.result, this.error}): super._();
  factory _AiJobModel.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$AiJobModelFromJson(json,fromJsonT);

@override final  String jobId;
@override final  String status;
@override@JsonKey() final  int progress;
@override final  int? estimatedSeconds;
@override final  T? result;
@override final  String? error;

/// Create a copy of AiJobModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiJobModelCopyWith<T, _AiJobModel<T>> get copyWith => __$AiJobModelCopyWithImpl<T, _AiJobModel<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$AiJobModelToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiJobModel<T>&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.estimatedSeconds, estimatedSeconds) || other.estimatedSeconds == estimatedSeconds)&&const DeepCollectionEquality().equals(other.result, result)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status,progress,estimatedSeconds,const DeepCollectionEquality().hash(result),error);

@override
String toString() {
  return 'AiJobModel<$T>(jobId: $jobId, status: $status, progress: $progress, estimatedSeconds: $estimatedSeconds, result: $result, error: $error)';
}


}

/// @nodoc
abstract mixin class _$AiJobModelCopyWith<T,$Res> implements $AiJobModelCopyWith<T, $Res> {
  factory _$AiJobModelCopyWith(_AiJobModel<T> value, $Res Function(_AiJobModel<T>) _then) = __$AiJobModelCopyWithImpl;
@override @useResult
$Res call({
 String jobId, String status, int progress, int? estimatedSeconds, T? result, String? error
});




}
/// @nodoc
class __$AiJobModelCopyWithImpl<T,$Res>
    implements _$AiJobModelCopyWith<T, $Res> {
  __$AiJobModelCopyWithImpl(this._self, this._then);

  final _AiJobModel<T> _self;
  final $Res Function(_AiJobModel<T>) _then;

/// Create a copy of AiJobModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobId = null,Object? status = null,Object? progress = null,Object? estimatedSeconds = freezed,Object? result = freezed,Object? error = freezed,}) {
  return _then(_AiJobModel<T>(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,estimatedSeconds: freezed == estimatedSeconds ? _self.estimatedSeconds : estimatedSeconds // ignore: cast_nullable_to_non_nullable
as int?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as T?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
