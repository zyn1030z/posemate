// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CameraState {

/// Whether the camera is initialized and ready to stream.
 bool get isInitialized;/// The current flash mode.
 FlashMode get flashMode;/// The active lens direction (front/back).
 CameraLensDirection get lensDirection;/// The current zoom level.
 double get zoomLevel;/// The minimum allowed zoom level for the current lens.
 double get minZoomLevel;/// The maximum allowed zoom level for the current lens.
 double get maxZoomLevel;/// The active visual grid overlaid on the preview.
 CameraGrid get grid;/// True while a photo is being captured.
 bool get isCapturing;/// If an error occurred (e.g., permissions denied).
 String? get error;
/// Create a copy of CameraState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraStateCopyWith<CameraState> get copyWith => _$CameraStateCopyWithImpl<CameraState>(this as CameraState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraState&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized)&&(identical(other.flashMode, flashMode) || other.flashMode == flashMode)&&(identical(other.lensDirection, lensDirection) || other.lensDirection == lensDirection)&&(identical(other.zoomLevel, zoomLevel) || other.zoomLevel == zoomLevel)&&(identical(other.minZoomLevel, minZoomLevel) || other.minZoomLevel == minZoomLevel)&&(identical(other.maxZoomLevel, maxZoomLevel) || other.maxZoomLevel == maxZoomLevel)&&(identical(other.grid, grid) || other.grid == grid)&&(identical(other.isCapturing, isCapturing) || other.isCapturing == isCapturing)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isInitialized,flashMode,lensDirection,zoomLevel,minZoomLevel,maxZoomLevel,grid,isCapturing,error);

@override
String toString() {
  return 'CameraState(isInitialized: $isInitialized, flashMode: $flashMode, lensDirection: $lensDirection, zoomLevel: $zoomLevel, minZoomLevel: $minZoomLevel, maxZoomLevel: $maxZoomLevel, grid: $grid, isCapturing: $isCapturing, error: $error)';
}


}

/// @nodoc
abstract mixin class $CameraStateCopyWith<$Res>  {
  factory $CameraStateCopyWith(CameraState value, $Res Function(CameraState) _then) = _$CameraStateCopyWithImpl;
@useResult
$Res call({
 bool isInitialized, FlashMode flashMode, CameraLensDirection lensDirection, double zoomLevel, double minZoomLevel, double maxZoomLevel, CameraGrid grid, bool isCapturing, String? error
});




}
/// @nodoc
class _$CameraStateCopyWithImpl<$Res>
    implements $CameraStateCopyWith<$Res> {
  _$CameraStateCopyWithImpl(this._self, this._then);

  final CameraState _self;
  final $Res Function(CameraState) _then;

/// Create a copy of CameraState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isInitialized = null,Object? flashMode = null,Object? lensDirection = null,Object? zoomLevel = null,Object? minZoomLevel = null,Object? maxZoomLevel = null,Object? grid = null,Object? isCapturing = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,flashMode: null == flashMode ? _self.flashMode : flashMode // ignore: cast_nullable_to_non_nullable
as FlashMode,lensDirection: null == lensDirection ? _self.lensDirection : lensDirection // ignore: cast_nullable_to_non_nullable
as CameraLensDirection,zoomLevel: null == zoomLevel ? _self.zoomLevel : zoomLevel // ignore: cast_nullable_to_non_nullable
as double,minZoomLevel: null == minZoomLevel ? _self.minZoomLevel : minZoomLevel // ignore: cast_nullable_to_non_nullable
as double,maxZoomLevel: null == maxZoomLevel ? _self.maxZoomLevel : maxZoomLevel // ignore: cast_nullable_to_non_nullable
as double,grid: null == grid ? _self.grid : grid // ignore: cast_nullable_to_non_nullable
as CameraGrid,isCapturing: null == isCapturing ? _self.isCapturing : isCapturing // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CameraState].
extension CameraStatePatterns on CameraState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CameraState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CameraState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CameraState value)  $default,){
final _that = this;
switch (_that) {
case _CameraState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CameraState value)?  $default,){
final _that = this;
switch (_that) {
case _CameraState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isInitialized,  FlashMode flashMode,  CameraLensDirection lensDirection,  double zoomLevel,  double minZoomLevel,  double maxZoomLevel,  CameraGrid grid,  bool isCapturing,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CameraState() when $default != null:
return $default(_that.isInitialized,_that.flashMode,_that.lensDirection,_that.zoomLevel,_that.minZoomLevel,_that.maxZoomLevel,_that.grid,_that.isCapturing,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isInitialized,  FlashMode flashMode,  CameraLensDirection lensDirection,  double zoomLevel,  double minZoomLevel,  double maxZoomLevel,  CameraGrid grid,  bool isCapturing,  String? error)  $default,) {final _that = this;
switch (_that) {
case _CameraState():
return $default(_that.isInitialized,_that.flashMode,_that.lensDirection,_that.zoomLevel,_that.minZoomLevel,_that.maxZoomLevel,_that.grid,_that.isCapturing,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isInitialized,  FlashMode flashMode,  CameraLensDirection lensDirection,  double zoomLevel,  double minZoomLevel,  double maxZoomLevel,  CameraGrid grid,  bool isCapturing,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _CameraState() when $default != null:
return $default(_that.isInitialized,_that.flashMode,_that.lensDirection,_that.zoomLevel,_that.minZoomLevel,_that.maxZoomLevel,_that.grid,_that.isCapturing,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CameraState implements CameraState {
  const _CameraState({this.isInitialized = false, this.flashMode = FlashMode.off, this.lensDirection = CameraLensDirection.back, this.zoomLevel = 1.0, this.minZoomLevel = 1.0, this.maxZoomLevel = 1.0, this.grid = CameraGrid.none, this.isCapturing = false, this.error});
  

/// Whether the camera is initialized and ready to stream.
@override@JsonKey() final  bool isInitialized;
/// The current flash mode.
@override@JsonKey() final  FlashMode flashMode;
/// The active lens direction (front/back).
@override@JsonKey() final  CameraLensDirection lensDirection;
/// The current zoom level.
@override@JsonKey() final  double zoomLevel;
/// The minimum allowed zoom level for the current lens.
@override@JsonKey() final  double minZoomLevel;
/// The maximum allowed zoom level for the current lens.
@override@JsonKey() final  double maxZoomLevel;
/// The active visual grid overlaid on the preview.
@override@JsonKey() final  CameraGrid grid;
/// True while a photo is being captured.
@override@JsonKey() final  bool isCapturing;
/// If an error occurred (e.g., permissions denied).
@override final  String? error;

/// Create a copy of CameraState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraStateCopyWith<_CameraState> get copyWith => __$CameraStateCopyWithImpl<_CameraState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraState&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized)&&(identical(other.flashMode, flashMode) || other.flashMode == flashMode)&&(identical(other.lensDirection, lensDirection) || other.lensDirection == lensDirection)&&(identical(other.zoomLevel, zoomLevel) || other.zoomLevel == zoomLevel)&&(identical(other.minZoomLevel, minZoomLevel) || other.minZoomLevel == minZoomLevel)&&(identical(other.maxZoomLevel, maxZoomLevel) || other.maxZoomLevel == maxZoomLevel)&&(identical(other.grid, grid) || other.grid == grid)&&(identical(other.isCapturing, isCapturing) || other.isCapturing == isCapturing)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isInitialized,flashMode,lensDirection,zoomLevel,minZoomLevel,maxZoomLevel,grid,isCapturing,error);

@override
String toString() {
  return 'CameraState(isInitialized: $isInitialized, flashMode: $flashMode, lensDirection: $lensDirection, zoomLevel: $zoomLevel, minZoomLevel: $minZoomLevel, maxZoomLevel: $maxZoomLevel, grid: $grid, isCapturing: $isCapturing, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CameraStateCopyWith<$Res> implements $CameraStateCopyWith<$Res> {
  factory _$CameraStateCopyWith(_CameraState value, $Res Function(_CameraState) _then) = __$CameraStateCopyWithImpl;
@override @useResult
$Res call({
 bool isInitialized, FlashMode flashMode, CameraLensDirection lensDirection, double zoomLevel, double minZoomLevel, double maxZoomLevel, CameraGrid grid, bool isCapturing, String? error
});




}
/// @nodoc
class __$CameraStateCopyWithImpl<$Res>
    implements _$CameraStateCopyWith<$Res> {
  __$CameraStateCopyWithImpl(this._self, this._then);

  final _CameraState _self;
  final $Res Function(_CameraState) _then;

/// Create a copy of CameraState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isInitialized = null,Object? flashMode = null,Object? lensDirection = null,Object? zoomLevel = null,Object? minZoomLevel = null,Object? maxZoomLevel = null,Object? grid = null,Object? isCapturing = null,Object? error = freezed,}) {
  return _then(_CameraState(
isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,flashMode: null == flashMode ? _self.flashMode : flashMode // ignore: cast_nullable_to_non_nullable
as FlashMode,lensDirection: null == lensDirection ? _self.lensDirection : lensDirection // ignore: cast_nullable_to_non_nullable
as CameraLensDirection,zoomLevel: null == zoomLevel ? _self.zoomLevel : zoomLevel // ignore: cast_nullable_to_non_nullable
as double,minZoomLevel: null == minZoomLevel ? _self.minZoomLevel : minZoomLevel // ignore: cast_nullable_to_non_nullable
as double,maxZoomLevel: null == maxZoomLevel ? _self.maxZoomLevel : maxZoomLevel // ignore: cast_nullable_to_non_nullable
as double,grid: null == grid ? _self.grid : grid // ignore: cast_nullable_to_non_nullable
as CameraGrid,isCapturing: null == isCapturing ? _self.isCapturing : isCapturing // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
