// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_coach.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiCoach {

 String get id; String get name; String get specialization; double get rating; int get reviewCount; String get imageUrl; String get description; double get voicePitch; double get voiceRate;
/// Create a copy of AiCoach
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiCoachCopyWith<AiCoach> get copyWith => _$AiCoachCopyWithImpl<AiCoach>(this as AiCoach, _$identity);

  /// Serializes this AiCoach to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiCoach&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.specialization, specialization) || other.specialization == specialization)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.voicePitch, voicePitch) || other.voicePitch == voicePitch)&&(identical(other.voiceRate, voiceRate) || other.voiceRate == voiceRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,specialization,rating,reviewCount,imageUrl,description,voicePitch,voiceRate);

@override
String toString() {
  return 'AiCoach(id: $id, name: $name, specialization: $specialization, rating: $rating, reviewCount: $reviewCount, imageUrl: $imageUrl, description: $description, voicePitch: $voicePitch, voiceRate: $voiceRate)';
}


}

/// @nodoc
abstract mixin class $AiCoachCopyWith<$Res>  {
  factory $AiCoachCopyWith(AiCoach value, $Res Function(AiCoach) _then) = _$AiCoachCopyWithImpl;
@useResult
$Res call({
 String id, String name, String specialization, double rating, int reviewCount, String imageUrl, String description, double voicePitch, double voiceRate
});




}
/// @nodoc
class _$AiCoachCopyWithImpl<$Res>
    implements $AiCoachCopyWith<$Res> {
  _$AiCoachCopyWithImpl(this._self, this._then);

  final AiCoach _self;
  final $Res Function(AiCoach) _then;

/// Create a copy of AiCoach
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? specialization = null,Object? rating = null,Object? reviewCount = null,Object? imageUrl = null,Object? description = null,Object? voicePitch = null,Object? voiceRate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,specialization: null == specialization ? _self.specialization : specialization // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,voicePitch: null == voicePitch ? _self.voicePitch : voicePitch // ignore: cast_nullable_to_non_nullable
as double,voiceRate: null == voiceRate ? _self.voiceRate : voiceRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AiCoach].
extension AiCoachPatterns on AiCoach {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiCoach value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiCoach() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiCoach value)  $default,){
final _that = this;
switch (_that) {
case _AiCoach():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiCoach value)?  $default,){
final _that = this;
switch (_that) {
case _AiCoach() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String specialization,  double rating,  int reviewCount,  String imageUrl,  String description,  double voicePitch,  double voiceRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiCoach() when $default != null:
return $default(_that.id,_that.name,_that.specialization,_that.rating,_that.reviewCount,_that.imageUrl,_that.description,_that.voicePitch,_that.voiceRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String specialization,  double rating,  int reviewCount,  String imageUrl,  String description,  double voicePitch,  double voiceRate)  $default,) {final _that = this;
switch (_that) {
case _AiCoach():
return $default(_that.id,_that.name,_that.specialization,_that.rating,_that.reviewCount,_that.imageUrl,_that.description,_that.voicePitch,_that.voiceRate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String specialization,  double rating,  int reviewCount,  String imageUrl,  String description,  double voicePitch,  double voiceRate)?  $default,) {final _that = this;
switch (_that) {
case _AiCoach() when $default != null:
return $default(_that.id,_that.name,_that.specialization,_that.rating,_that.reviewCount,_that.imageUrl,_that.description,_that.voicePitch,_that.voiceRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiCoach implements AiCoach {
  const _AiCoach({required this.id, required this.name, required this.specialization, required this.rating, required this.reviewCount, required this.imageUrl, required this.description, this.voicePitch = 1.0, this.voiceRate = 0.5});
  factory _AiCoach.fromJson(Map<String, dynamic> json) => _$AiCoachFromJson(json);

@override final  String id;
@override final  String name;
@override final  String specialization;
@override final  double rating;
@override final  int reviewCount;
@override final  String imageUrl;
@override final  String description;
@override@JsonKey() final  double voicePitch;
@override@JsonKey() final  double voiceRate;

/// Create a copy of AiCoach
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiCoachCopyWith<_AiCoach> get copyWith => __$AiCoachCopyWithImpl<_AiCoach>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiCoachToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiCoach&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.specialization, specialization) || other.specialization == specialization)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.voicePitch, voicePitch) || other.voicePitch == voicePitch)&&(identical(other.voiceRate, voiceRate) || other.voiceRate == voiceRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,specialization,rating,reviewCount,imageUrl,description,voicePitch,voiceRate);

@override
String toString() {
  return 'AiCoach(id: $id, name: $name, specialization: $specialization, rating: $rating, reviewCount: $reviewCount, imageUrl: $imageUrl, description: $description, voicePitch: $voicePitch, voiceRate: $voiceRate)';
}


}

/// @nodoc
abstract mixin class _$AiCoachCopyWith<$Res> implements $AiCoachCopyWith<$Res> {
  factory _$AiCoachCopyWith(_AiCoach value, $Res Function(_AiCoach) _then) = __$AiCoachCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String specialization, double rating, int reviewCount, String imageUrl, String description, double voicePitch, double voiceRate
});




}
/// @nodoc
class __$AiCoachCopyWithImpl<$Res>
    implements _$AiCoachCopyWith<$Res> {
  __$AiCoachCopyWithImpl(this._self, this._then);

  final _AiCoach _self;
  final $Res Function(_AiCoach) _then;

/// Create a copy of AiCoach
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? specialization = null,Object? rating = null,Object? reviewCount = null,Object? imageUrl = null,Object? description = null,Object? voicePitch = null,Object? voiceRate = null,}) {
  return _then(_AiCoach(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,specialization: null == specialization ? _self.specialization : specialization // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,voicePitch: null == voicePitch ? _self.voicePitch : voicePitch // ignore: cast_nullable_to_non_nullable
as double,voiceRate: null == voiceRate ? _self.voiceRate : voiceRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
