// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'extraction_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExtractionJob {

 String get id; ExtractionStatus get status; Pose? get result; String? get errorMessage; double get progress; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of ExtractionJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractionJobCopyWith<ExtractionJob> get copyWith => _$ExtractionJobCopyWithImpl<ExtractionJob>(this as ExtractionJob, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractionJob&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.result, result) || other.result == result)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,status,result,errorMessage,progress,createdAt,updatedAt);

@override
String toString() {
  return 'ExtractionJob(id: $id, status: $status, result: $result, errorMessage: $errorMessage, progress: $progress, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ExtractionJobCopyWith<$Res>  {
  factory $ExtractionJobCopyWith(ExtractionJob value, $Res Function(ExtractionJob) _then) = _$ExtractionJobCopyWithImpl;
@useResult
$Res call({
 String id, ExtractionStatus status, Pose? result, String? errorMessage, double progress, DateTime? createdAt, DateTime? updatedAt
});


$PoseCopyWith<$Res>? get result;

}
/// @nodoc
class _$ExtractionJobCopyWithImpl<$Res>
    implements $ExtractionJobCopyWith<$Res> {
  _$ExtractionJobCopyWithImpl(this._self, this._then);

  final ExtractionJob _self;
  final $Res Function(ExtractionJob) _then;

/// Create a copy of ExtractionJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? result = freezed,Object? errorMessage = freezed,Object? progress = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ExtractionStatus,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as Pose?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ExtractionJob
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PoseCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $PoseCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExtractionJob].
extension ExtractionJobPatterns on ExtractionJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExtractionJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExtractionJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExtractionJob value)  $default,){
final _that = this;
switch (_that) {
case _ExtractionJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExtractionJob value)?  $default,){
final _that = this;
switch (_that) {
case _ExtractionJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ExtractionStatus status,  Pose? result,  String? errorMessage,  double progress,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExtractionJob() when $default != null:
return $default(_that.id,_that.status,_that.result,_that.errorMessage,_that.progress,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ExtractionStatus status,  Pose? result,  String? errorMessage,  double progress,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ExtractionJob():
return $default(_that.id,_that.status,_that.result,_that.errorMessage,_that.progress,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ExtractionStatus status,  Pose? result,  String? errorMessage,  double progress,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ExtractionJob() when $default != null:
return $default(_that.id,_that.status,_that.result,_that.errorMessage,_that.progress,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ExtractionJob implements ExtractionJob {
  const _ExtractionJob({required this.id, required this.status, this.result, this.errorMessage, this.progress = 0.0, this.createdAt, this.updatedAt});
  

@override final  String id;
@override final  ExtractionStatus status;
@override final  Pose? result;
@override final  String? errorMessage;
@override@JsonKey() final  double progress;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of ExtractionJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExtractionJobCopyWith<_ExtractionJob> get copyWith => __$ExtractionJobCopyWithImpl<_ExtractionJob>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExtractionJob&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.result, result) || other.result == result)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,status,result,errorMessage,progress,createdAt,updatedAt);

@override
String toString() {
  return 'ExtractionJob(id: $id, status: $status, result: $result, errorMessage: $errorMessage, progress: $progress, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ExtractionJobCopyWith<$Res> implements $ExtractionJobCopyWith<$Res> {
  factory _$ExtractionJobCopyWith(_ExtractionJob value, $Res Function(_ExtractionJob) _then) = __$ExtractionJobCopyWithImpl;
@override @useResult
$Res call({
 String id, ExtractionStatus status, Pose? result, String? errorMessage, double progress, DateTime? createdAt, DateTime? updatedAt
});


@override $PoseCopyWith<$Res>? get result;

}
/// @nodoc
class __$ExtractionJobCopyWithImpl<$Res>
    implements _$ExtractionJobCopyWith<$Res> {
  __$ExtractionJobCopyWithImpl(this._self, this._then);

  final _ExtractionJob _self;
  final $Res Function(_ExtractionJob) _then;

/// Create a copy of ExtractionJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? result = freezed,Object? errorMessage = freezed,Object? progress = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ExtractionJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ExtractionStatus,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as Pose?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ExtractionJob
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PoseCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $PoseCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

// dart format on
