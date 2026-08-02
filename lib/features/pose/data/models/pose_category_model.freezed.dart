// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pose_category_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PoseCategoryModel {

/// Opaque server-issued category identifier.
 String get id;/// Display name of the category.
 String get name;/// Single emoji used as the category glyph.
 String get emoji;
/// Create a copy of PoseCategoryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PoseCategoryModelCopyWith<PoseCategoryModel> get copyWith => _$PoseCategoryModelCopyWithImpl<PoseCategoryModel>(this as PoseCategoryModel, _$identity);

  /// Serializes this PoseCategoryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PoseCategoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,emoji);

@override
String toString() {
  return 'PoseCategoryModel(id: $id, name: $name, emoji: $emoji)';
}


}

/// @nodoc
abstract mixin class $PoseCategoryModelCopyWith<$Res>  {
  factory $PoseCategoryModelCopyWith(PoseCategoryModel value, $Res Function(PoseCategoryModel) _then) = _$PoseCategoryModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String emoji
});




}
/// @nodoc
class _$PoseCategoryModelCopyWithImpl<$Res>
    implements $PoseCategoryModelCopyWith<$Res> {
  _$PoseCategoryModelCopyWithImpl(this._self, this._then);

  final PoseCategoryModel _self;
  final $Res Function(PoseCategoryModel) _then;

/// Create a copy of PoseCategoryModel
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


/// Adds pattern-matching-related methods to [PoseCategoryModel].
extension PoseCategoryModelPatterns on PoseCategoryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PoseCategoryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PoseCategoryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PoseCategoryModel value)  $default,){
final _that = this;
switch (_that) {
case _PoseCategoryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PoseCategoryModel value)?  $default,){
final _that = this;
switch (_that) {
case _PoseCategoryModel() when $default != null:
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
case _PoseCategoryModel() when $default != null:
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
case _PoseCategoryModel():
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
case _PoseCategoryModel() when $default != null:
return $default(_that.id,_that.name,_that.emoji);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PoseCategoryModel extends PoseCategoryModel {
  const _PoseCategoryModel({required this.id, required this.name, required this.emoji}): super._();
  factory _PoseCategoryModel.fromJson(Map<String, dynamic> json) => _$PoseCategoryModelFromJson(json);

/// Opaque server-issued category identifier.
@override final  String id;
/// Display name of the category.
@override final  String name;
/// Single emoji used as the category glyph.
@override final  String emoji;

/// Create a copy of PoseCategoryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PoseCategoryModelCopyWith<_PoseCategoryModel> get copyWith => __$PoseCategoryModelCopyWithImpl<_PoseCategoryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PoseCategoryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PoseCategoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,emoji);

@override
String toString() {
  return 'PoseCategoryModel(id: $id, name: $name, emoji: $emoji)';
}


}

/// @nodoc
abstract mixin class _$PoseCategoryModelCopyWith<$Res> implements $PoseCategoryModelCopyWith<$Res> {
  factory _$PoseCategoryModelCopyWith(_PoseCategoryModel value, $Res Function(_PoseCategoryModel) _then) = __$PoseCategoryModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String emoji
});




}
/// @nodoc
class __$PoseCategoryModelCopyWithImpl<$Res>
    implements _$PoseCategoryModelCopyWith<$Res> {
  __$PoseCategoryModelCopyWithImpl(this._self, this._then);

  final _PoseCategoryModel _self;
  final $Res Function(_PoseCategoryModel) _then;

/// Create a copy of PoseCategoryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? emoji = null,}) {
  return _then(_PoseCategoryModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
