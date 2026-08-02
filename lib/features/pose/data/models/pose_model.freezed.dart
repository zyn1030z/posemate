// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pose_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PoseModel {

/// Opaque server-issued pose identifier.
 String get id;/// Display name of the pose.
 String get name;/// URL of the full-color preview photograph.
 String get previewUrl;/// URL of the transparent overlay used as the camera guide.
 String get overlayUrl;/// Free-form descriptive tags.
 List<String> get tags;/// Difficulty as sent on the wire: easy, medium, or hard.
 String get difficulty;/// Target audience as sent on the wire: female, male, couple, or any.
 String get gender;/// Direction the subject's body faces.
 String get bodyDirection;/// Suggested camera height.
 String get cameraAngle;/// Community quality score on a five-point scale.
 double get aiScore;/// How many times the pose has been downloaded.
 int get downloads;/// Whether the pose requires an active premium subscription.
 bool get isPremium;/// Identifier of the category this pose belongs to.
 String get categoryId;
/// Create a copy of PoseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PoseModelCopyWith<PoseModel> get copyWith => _$PoseModelCopyWithImpl<PoseModel>(this as PoseModel, _$identity);

  /// Serializes this PoseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PoseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.previewUrl, previewUrl) || other.previewUrl == previewUrl)&&(identical(other.overlayUrl, overlayUrl) || other.overlayUrl == overlayUrl)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.bodyDirection, bodyDirection) || other.bodyDirection == bodyDirection)&&(identical(other.cameraAngle, cameraAngle) || other.cameraAngle == cameraAngle)&&(identical(other.aiScore, aiScore) || other.aiScore == aiScore)&&(identical(other.downloads, downloads) || other.downloads == downloads)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,previewUrl,overlayUrl,const DeepCollectionEquality().hash(tags),difficulty,gender,bodyDirection,cameraAngle,aiScore,downloads,isPremium,categoryId);

@override
String toString() {
  return 'PoseModel(id: $id, name: $name, previewUrl: $previewUrl, overlayUrl: $overlayUrl, tags: $tags, difficulty: $difficulty, gender: $gender, bodyDirection: $bodyDirection, cameraAngle: $cameraAngle, aiScore: $aiScore, downloads: $downloads, isPremium: $isPremium, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class $PoseModelCopyWith<$Res>  {
  factory $PoseModelCopyWith(PoseModel value, $Res Function(PoseModel) _then) = _$PoseModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String previewUrl, String overlayUrl, List<String> tags, String difficulty, String gender, String bodyDirection, String cameraAngle, double aiScore, int downloads, bool isPremium, String categoryId
});




}
/// @nodoc
class _$PoseModelCopyWithImpl<$Res>
    implements $PoseModelCopyWith<$Res> {
  _$PoseModelCopyWithImpl(this._self, this._then);

  final PoseModel _self;
  final $Res Function(PoseModel) _then;

/// Create a copy of PoseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? previewUrl = null,Object? overlayUrl = null,Object? tags = null,Object? difficulty = null,Object? gender = null,Object? bodyDirection = null,Object? cameraAngle = null,Object? aiScore = null,Object? downloads = null,Object? isPremium = null,Object? categoryId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,previewUrl: null == previewUrl ? _self.previewUrl : previewUrl // ignore: cast_nullable_to_non_nullable
as String,overlayUrl: null == overlayUrl ? _self.overlayUrl : overlayUrl // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,bodyDirection: null == bodyDirection ? _self.bodyDirection : bodyDirection // ignore: cast_nullable_to_non_nullable
as String,cameraAngle: null == cameraAngle ? _self.cameraAngle : cameraAngle // ignore: cast_nullable_to_non_nullable
as String,aiScore: null == aiScore ? _self.aiScore : aiScore // ignore: cast_nullable_to_non_nullable
as double,downloads: null == downloads ? _self.downloads : downloads // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PoseModel].
extension PoseModelPatterns on PoseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PoseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PoseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PoseModel value)  $default,){
final _that = this;
switch (_that) {
case _PoseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PoseModel value)?  $default,){
final _that = this;
switch (_that) {
case _PoseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String previewUrl,  String overlayUrl,  List<String> tags,  String difficulty,  String gender,  String bodyDirection,  String cameraAngle,  double aiScore,  int downloads,  bool isPremium,  String categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PoseModel() when $default != null:
return $default(_that.id,_that.name,_that.previewUrl,_that.overlayUrl,_that.tags,_that.difficulty,_that.gender,_that.bodyDirection,_that.cameraAngle,_that.aiScore,_that.downloads,_that.isPremium,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String previewUrl,  String overlayUrl,  List<String> tags,  String difficulty,  String gender,  String bodyDirection,  String cameraAngle,  double aiScore,  int downloads,  bool isPremium,  String categoryId)  $default,) {final _that = this;
switch (_that) {
case _PoseModel():
return $default(_that.id,_that.name,_that.previewUrl,_that.overlayUrl,_that.tags,_that.difficulty,_that.gender,_that.bodyDirection,_that.cameraAngle,_that.aiScore,_that.downloads,_that.isPremium,_that.categoryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String previewUrl,  String overlayUrl,  List<String> tags,  String difficulty,  String gender,  String bodyDirection,  String cameraAngle,  double aiScore,  int downloads,  bool isPremium,  String categoryId)?  $default,) {final _that = this;
switch (_that) {
case _PoseModel() when $default != null:
return $default(_that.id,_that.name,_that.previewUrl,_that.overlayUrl,_that.tags,_that.difficulty,_that.gender,_that.bodyDirection,_that.cameraAngle,_that.aiScore,_that.downloads,_that.isPremium,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PoseModel extends PoseModel {
  const _PoseModel({required this.id, required this.name, required this.previewUrl, required this.overlayUrl, final  List<String> tags = const <String>[], this.difficulty = 'easy', this.gender = 'any', this.bodyDirection = 'front', this.cameraAngle = 'eye-level', this.aiScore = 0, this.downloads = 0, this.isPremium = false, required this.categoryId}): _tags = tags,super._();
  factory _PoseModel.fromJson(Map<String, dynamic> json) => _$PoseModelFromJson(json);

/// Opaque server-issued pose identifier.
@override final  String id;
/// Display name of the pose.
@override final  String name;
/// URL of the full-color preview photograph.
@override final  String previewUrl;
/// URL of the transparent overlay used as the camera guide.
@override final  String overlayUrl;
/// Free-form descriptive tags.
 final  List<String> _tags;
/// Free-form descriptive tags.
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// Difficulty as sent on the wire: easy, medium, or hard.
@override@JsonKey() final  String difficulty;
/// Target audience as sent on the wire: female, male, couple, or any.
@override@JsonKey() final  String gender;
/// Direction the subject's body faces.
@override@JsonKey() final  String bodyDirection;
/// Suggested camera height.
@override@JsonKey() final  String cameraAngle;
/// Community quality score on a five-point scale.
@override@JsonKey() final  double aiScore;
/// How many times the pose has been downloaded.
@override@JsonKey() final  int downloads;
/// Whether the pose requires an active premium subscription.
@override@JsonKey() final  bool isPremium;
/// Identifier of the category this pose belongs to.
@override final  String categoryId;

/// Create a copy of PoseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PoseModelCopyWith<_PoseModel> get copyWith => __$PoseModelCopyWithImpl<_PoseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PoseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PoseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.previewUrl, previewUrl) || other.previewUrl == previewUrl)&&(identical(other.overlayUrl, overlayUrl) || other.overlayUrl == overlayUrl)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.bodyDirection, bodyDirection) || other.bodyDirection == bodyDirection)&&(identical(other.cameraAngle, cameraAngle) || other.cameraAngle == cameraAngle)&&(identical(other.aiScore, aiScore) || other.aiScore == aiScore)&&(identical(other.downloads, downloads) || other.downloads == downloads)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,previewUrl,overlayUrl,const DeepCollectionEquality().hash(_tags),difficulty,gender,bodyDirection,cameraAngle,aiScore,downloads,isPremium,categoryId);

@override
String toString() {
  return 'PoseModel(id: $id, name: $name, previewUrl: $previewUrl, overlayUrl: $overlayUrl, tags: $tags, difficulty: $difficulty, gender: $gender, bodyDirection: $bodyDirection, cameraAngle: $cameraAngle, aiScore: $aiScore, downloads: $downloads, isPremium: $isPremium, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$PoseModelCopyWith<$Res> implements $PoseModelCopyWith<$Res> {
  factory _$PoseModelCopyWith(_PoseModel value, $Res Function(_PoseModel) _then) = __$PoseModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String previewUrl, String overlayUrl, List<String> tags, String difficulty, String gender, String bodyDirection, String cameraAngle, double aiScore, int downloads, bool isPremium, String categoryId
});




}
/// @nodoc
class __$PoseModelCopyWithImpl<$Res>
    implements _$PoseModelCopyWith<$Res> {
  __$PoseModelCopyWithImpl(this._self, this._then);

  final _PoseModel _self;
  final $Res Function(_PoseModel) _then;

/// Create a copy of PoseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? previewUrl = null,Object? overlayUrl = null,Object? tags = null,Object? difficulty = null,Object? gender = null,Object? bodyDirection = null,Object? cameraAngle = null,Object? aiScore = null,Object? downloads = null,Object? isPremium = null,Object? categoryId = null,}) {
  return _then(_PoseModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,previewUrl: null == previewUrl ? _self.previewUrl : previewUrl // ignore: cast_nullable_to_non_nullable
as String,overlayUrl: null == overlayUrl ? _self.overlayUrl : overlayUrl // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,bodyDirection: null == bodyDirection ? _self.bodyDirection : bodyDirection // ignore: cast_nullable_to_non_nullable
as String,cameraAngle: null == cameraAngle ? _self.cameraAngle : cameraAngle // ignore: cast_nullable_to_non_nullable
as String,aiScore: null == aiScore ? _self.aiScore : aiScore // ignore: cast_nullable_to_non_nullable
as double,downloads: null == downloads ? _self.downloads : downloads // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
