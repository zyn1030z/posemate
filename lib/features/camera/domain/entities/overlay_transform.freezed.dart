// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'overlay_transform.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OverlayTransform {

/// The translation offset relative to the center of the gesture area.
 Offset get offset;/// The zoom scale of the overlay.
 double get scale;/// The rotation in radians.
 double get rotation;/// The opacity of the ghost silhouette (0.0 to 1.0).
 double get opacity;/// Whether the overlay is flipped horizontally (mirror effect).
 bool get isFlipped;/// Whether gestures are locked to prevent accidental movement.
 bool get isLocked;/// Whether the overlay is temporarily hidden.
 bool get isHidden;
/// Create a copy of OverlayTransform
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OverlayTransformCopyWith<OverlayTransform> get copyWith => _$OverlayTransformCopyWithImpl<OverlayTransform>(this as OverlayTransform, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OverlayTransform&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.isFlipped, isFlipped) || other.isFlipped == isFlipped)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden));
}


@override
int get hashCode => Object.hash(runtimeType,offset,scale,rotation,opacity,isFlipped,isLocked,isHidden);

@override
String toString() {
  return 'OverlayTransform(offset: $offset, scale: $scale, rotation: $rotation, opacity: $opacity, isFlipped: $isFlipped, isLocked: $isLocked, isHidden: $isHidden)';
}


}

/// @nodoc
abstract mixin class $OverlayTransformCopyWith<$Res>  {
  factory $OverlayTransformCopyWith(OverlayTransform value, $Res Function(OverlayTransform) _then) = _$OverlayTransformCopyWithImpl;
@useResult
$Res call({
 Offset offset, double scale, double rotation, double opacity, bool isFlipped, bool isLocked, bool isHidden
});




}
/// @nodoc
class _$OverlayTransformCopyWithImpl<$Res>
    implements $OverlayTransformCopyWith<$Res> {
  _$OverlayTransformCopyWithImpl(this._self, this._then);

  final OverlayTransform _self;
  final $Res Function(OverlayTransform) _then;

/// Create a copy of OverlayTransform
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offset = null,Object? scale = null,Object? rotation = null,Object? opacity = null,Object? isFlipped = null,Object? isLocked = null,Object? isHidden = null,}) {
  return _then(_self.copyWith(
offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Offset,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,isFlipped: null == isFlipped ? _self.isFlipped : isFlipped // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OverlayTransform].
extension OverlayTransformPatterns on OverlayTransform {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OverlayTransform value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OverlayTransform() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OverlayTransform value)  $default,){
final _that = this;
switch (_that) {
case _OverlayTransform():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OverlayTransform value)?  $default,){
final _that = this;
switch (_that) {
case _OverlayTransform() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Offset offset,  double scale,  double rotation,  double opacity,  bool isFlipped,  bool isLocked,  bool isHidden)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OverlayTransform() when $default != null:
return $default(_that.offset,_that.scale,_that.rotation,_that.opacity,_that.isFlipped,_that.isLocked,_that.isHidden);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Offset offset,  double scale,  double rotation,  double opacity,  bool isFlipped,  bool isLocked,  bool isHidden)  $default,) {final _that = this;
switch (_that) {
case _OverlayTransform():
return $default(_that.offset,_that.scale,_that.rotation,_that.opacity,_that.isFlipped,_that.isLocked,_that.isHidden);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Offset offset,  double scale,  double rotation,  double opacity,  bool isFlipped,  bool isLocked,  bool isHidden)?  $default,) {final _that = this;
switch (_that) {
case _OverlayTransform() when $default != null:
return $default(_that.offset,_that.scale,_that.rotation,_that.opacity,_that.isFlipped,_that.isLocked,_that.isHidden);case _:
  return null;

}
}

}

/// @nodoc


class _OverlayTransform implements OverlayTransform {
  const _OverlayTransform({this.offset = Offset.zero, this.scale = 1.0, this.rotation = 0.0, this.opacity = 0.3, this.isFlipped = false, this.isLocked = false, this.isHidden = false});
  

/// The translation offset relative to the center of the gesture area.
@override@JsonKey() final  Offset offset;
/// The zoom scale of the overlay.
@override@JsonKey() final  double scale;
/// The rotation in radians.
@override@JsonKey() final  double rotation;
/// The opacity of the ghost silhouette (0.0 to 1.0).
@override@JsonKey() final  double opacity;
/// Whether the overlay is flipped horizontally (mirror effect).
@override@JsonKey() final  bool isFlipped;
/// Whether gestures are locked to prevent accidental movement.
@override@JsonKey() final  bool isLocked;
/// Whether the overlay is temporarily hidden.
@override@JsonKey() final  bool isHidden;

/// Create a copy of OverlayTransform
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OverlayTransformCopyWith<_OverlayTransform> get copyWith => __$OverlayTransformCopyWithImpl<_OverlayTransform>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OverlayTransform&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.isFlipped, isFlipped) || other.isFlipped == isFlipped)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden));
}


@override
int get hashCode => Object.hash(runtimeType,offset,scale,rotation,opacity,isFlipped,isLocked,isHidden);

@override
String toString() {
  return 'OverlayTransform(offset: $offset, scale: $scale, rotation: $rotation, opacity: $opacity, isFlipped: $isFlipped, isLocked: $isLocked, isHidden: $isHidden)';
}


}

/// @nodoc
abstract mixin class _$OverlayTransformCopyWith<$Res> implements $OverlayTransformCopyWith<$Res> {
  factory _$OverlayTransformCopyWith(_OverlayTransform value, $Res Function(_OverlayTransform) _then) = __$OverlayTransformCopyWithImpl;
@override @useResult
$Res call({
 Offset offset, double scale, double rotation, double opacity, bool isFlipped, bool isLocked, bool isHidden
});




}
/// @nodoc
class __$OverlayTransformCopyWithImpl<$Res>
    implements _$OverlayTransformCopyWith<$Res> {
  __$OverlayTransformCopyWithImpl(this._self, this._then);

  final _OverlayTransform _self;
  final $Res Function(_OverlayTransform) _then;

/// Create a copy of OverlayTransform
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offset = null,Object? scale = null,Object? rotation = null,Object? opacity = null,Object? isFlipped = null,Object? isLocked = null,Object? isHidden = null,}) {
  return _then(_OverlayTransform(
offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Offset,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,isFlipped: null == isFlipped ? _self.isFlipped : isFlipped // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
