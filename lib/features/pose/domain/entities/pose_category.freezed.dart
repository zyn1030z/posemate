// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pose_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PoseCategory {

/// Opaque server-issued category identifier.
 String get id;/// Display name shown on chips and section headers.
 String get name;/// Single emoji used as the category glyph.
 String get emoji;
/// Create a copy of PoseCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PoseCategoryCopyWith<PoseCategory> get copyWith => _$PoseCategoryCopyWithImpl<PoseCategory>(this as PoseCategory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PoseCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,emoji);

@override
String toString() {
  return 'PoseCategory(id: $id, name: $name, emoji: $emoji)';
}


}

/// @nodoc
abstract mixin class $PoseCategoryCopyWith<$Res>  {
  factory $PoseCategoryCopyWith(PoseCategory value, $Res Function(PoseCategory) _then) = _$PoseCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String emoji
});




}
/// @nodoc
class _$PoseCategoryCopyWithImpl<$Res>
    implements $PoseCategoryCopyWith<$Res> {
  _$PoseCategoryCopyWithImpl(this._self, this._then);

  final PoseCategory _self;
  final $Res Function(PoseCategory) _then;

/// Create a copy of PoseCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? emoji = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PoseCategory].
extension PoseCategoryPatterns on PoseCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PoseCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PoseCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PoseCategory value)  $default,){
final _that = this;
switch (_that) {
case _PoseCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PoseCategory value)?  $default,){
final _that = this;
switch (_that) {
case _PoseCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String emoji)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PoseCategory() when $default != null:
return $default(_that.id,_that.name,_that.emoji);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String emoji)  $default,) {final _that = this;
switch (_that) {
case _PoseCategory():
return $default(_that.id,_that.name,_that.emoji);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String emoji)?  $default,) {final _that = this;
switch (_that) {
case _PoseCategory() when $default != null:
return $default(_that.id,_that.name,_that.emoji);case _:
  return null;

}
}

}

/// @nodoc


class _PoseCategory implements PoseCategory {
  const _PoseCategory({required this.id, required this.name, required this.emoji});
  

/// Opaque server-issued category identifier.
@override final  String id;
/// Display name shown on chips and section headers.
@override final  String name;
/// Single emoji used as the category glyph.
@override final  String emoji;

/// Create a copy of PoseCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PoseCategoryCopyWith<_PoseCategory> get copyWith => __$PoseCategoryCopyWithImpl<_PoseCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PoseCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,emoji);

@override
String toString() {
  return 'PoseCategory(id: $id, name: $name, emoji: $emoji)';
}


}

/// @nodoc
abstract mixin class _$PoseCategoryCopyWith<$Res> implements $PoseCategoryCopyWith<$Res> {
  factory _$PoseCategoryCopyWith(_PoseCategory value, $Res Function(_PoseCategory) _then) = __$PoseCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String emoji
});




}
/// @nodoc
class __$PoseCategoryCopyWithImpl<$Res>
    implements _$PoseCategoryCopyWith<$Res> {
  __$PoseCategoryCopyWithImpl(this._self, this._then);

  final _PoseCategory _self;
  final $Res Function(_PoseCategory) _then;

/// Create a copy of PoseCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? emoji = null,}) {
  return _then(_PoseCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
