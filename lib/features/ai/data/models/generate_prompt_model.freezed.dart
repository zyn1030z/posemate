// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generate_prompt_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GeneratePromptModel {

 String get prompt; int get count; String get style; String get peopleCount;
/// Create a copy of GeneratePromptModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratePromptModelCopyWith<GeneratePromptModel> get copyWith => _$GeneratePromptModelCopyWithImpl<GeneratePromptModel>(this as GeneratePromptModel, _$identity);

  /// Serializes this GeneratePromptModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratePromptModel&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.count, count) || other.count == count)&&(identical(other.style, style) || other.style == style)&&(identical(other.peopleCount, peopleCount) || other.peopleCount == peopleCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prompt,count,style,peopleCount);

@override
String toString() {
  return 'GeneratePromptModel(prompt: $prompt, count: $count, style: $style, peopleCount: $peopleCount)';
}


}

/// @nodoc
abstract mixin class $GeneratePromptModelCopyWith<$Res>  {
  factory $GeneratePromptModelCopyWith(GeneratePromptModel value, $Res Function(GeneratePromptModel) _then) = _$GeneratePromptModelCopyWithImpl;
@useResult
$Res call({
 String prompt, int count, String style, String peopleCount
});




}
/// @nodoc
class _$GeneratePromptModelCopyWithImpl<$Res>
    implements $GeneratePromptModelCopyWith<$Res> {
  _$GeneratePromptModelCopyWithImpl(this._self, this._then);

  final GeneratePromptModel _self;
  final $Res Function(GeneratePromptModel) _then;

/// Create a copy of GeneratePromptModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prompt = null,Object? count = null,Object? style = null,Object? peopleCount = null,}) {
  return _then(_self.copyWith(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String,peopleCount: null == peopleCount ? _self.peopleCount : peopleCount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneratePromptModel].
extension GeneratePromptModelPatterns on GeneratePromptModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneratePromptModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneratePromptModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneratePromptModel value)  $default,){
final _that = this;
switch (_that) {
case _GeneratePromptModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneratePromptModel value)?  $default,){
final _that = this;
switch (_that) {
case _GeneratePromptModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String prompt,  int count,  String style,  String peopleCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneratePromptModel() when $default != null:
return $default(_that.prompt,_that.count,_that.style,_that.peopleCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String prompt,  int count,  String style,  String peopleCount)  $default,) {final _that = this;
switch (_that) {
case _GeneratePromptModel():
return $default(_that.prompt,_that.count,_that.style,_that.peopleCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String prompt,  int count,  String style,  String peopleCount)?  $default,) {final _that = this;
switch (_that) {
case _GeneratePromptModel() when $default != null:
return $default(_that.prompt,_that.count,_that.style,_that.peopleCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GeneratePromptModel extends GeneratePromptModel {
  const _GeneratePromptModel({required this.prompt, required this.count, required this.style, required this.peopleCount}): super._();
  factory _GeneratePromptModel.fromJson(Map<String, dynamic> json) => _$GeneratePromptModelFromJson(json);

@override final  String prompt;
@override final  int count;
@override final  String style;
@override final  String peopleCount;

/// Create a copy of GeneratePromptModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratePromptModelCopyWith<_GeneratePromptModel> get copyWith => __$GeneratePromptModelCopyWithImpl<_GeneratePromptModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeneratePromptModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratePromptModel&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.count, count) || other.count == count)&&(identical(other.style, style) || other.style == style)&&(identical(other.peopleCount, peopleCount) || other.peopleCount == peopleCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prompt,count,style,peopleCount);

@override
String toString() {
  return 'GeneratePromptModel(prompt: $prompt, count: $count, style: $style, peopleCount: $peopleCount)';
}


}

/// @nodoc
abstract mixin class _$GeneratePromptModelCopyWith<$Res> implements $GeneratePromptModelCopyWith<$Res> {
  factory _$GeneratePromptModelCopyWith(_GeneratePromptModel value, $Res Function(_GeneratePromptModel) _then) = __$GeneratePromptModelCopyWithImpl;
@override @useResult
$Res call({
 String prompt, int count, String style, String peopleCount
});




}
/// @nodoc
class __$GeneratePromptModelCopyWithImpl<$Res>
    implements _$GeneratePromptModelCopyWith<$Res> {
  __$GeneratePromptModelCopyWithImpl(this._self, this._then);

  final _GeneratePromptModel _self;
  final $Res Function(_GeneratePromptModel) _then;

/// Create a copy of GeneratePromptModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prompt = null,Object? count = null,Object? style = null,Object? peopleCount = null,}) {
  return _then(_GeneratePromptModel(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String,peopleCount: null == peopleCount ? _self.peopleCount : peopleCount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
