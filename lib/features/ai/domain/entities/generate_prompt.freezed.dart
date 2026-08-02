// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generate_prompt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GeneratePrompt {

/// The free-text scene description.
 String get prompt;/// How many pose variations to generate.
 int get count;/// The artistic style (e.g. 'photo', 'illustration', 'sketch').
 String get style;/// How many people are in the scene (solo, duo).
 PeopleCount get peopleCount;
/// Create a copy of GeneratePrompt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratePromptCopyWith<GeneratePrompt> get copyWith => _$GeneratePromptCopyWithImpl<GeneratePrompt>(this as GeneratePrompt, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratePrompt&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.count, count) || other.count == count)&&(identical(other.style, style) || other.style == style)&&(identical(other.peopleCount, peopleCount) || other.peopleCount == peopleCount));
}


@override
int get hashCode => Object.hash(runtimeType,prompt,count,style,peopleCount);

@override
String toString() {
  return 'GeneratePrompt(prompt: $prompt, count: $count, style: $style, peopleCount: $peopleCount)';
}


}

/// @nodoc
abstract mixin class $GeneratePromptCopyWith<$Res>  {
  factory $GeneratePromptCopyWith(GeneratePrompt value, $Res Function(GeneratePrompt) _then) = _$GeneratePromptCopyWithImpl;
@useResult
$Res call({
 String prompt, int count, String style, PeopleCount peopleCount
});




}
/// @nodoc
class _$GeneratePromptCopyWithImpl<$Res>
    implements $GeneratePromptCopyWith<$Res> {
  _$GeneratePromptCopyWithImpl(this._self, this._then);

  final GeneratePrompt _self;
  final $Res Function(GeneratePrompt) _then;

/// Create a copy of GeneratePrompt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prompt = null,Object? count = null,Object? style = null,Object? peopleCount = null,}) {
  return _then(_self.copyWith(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String,peopleCount: null == peopleCount ? _self.peopleCount : peopleCount // ignore: cast_nullable_to_non_nullable
as PeopleCount,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneratePrompt].
extension GeneratePromptPatterns on GeneratePrompt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneratePrompt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneratePrompt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneratePrompt value)  $default,){
final _that = this;
switch (_that) {
case _GeneratePrompt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneratePrompt value)?  $default,){
final _that = this;
switch (_that) {
case _GeneratePrompt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String prompt,  int count,  String style,  PeopleCount peopleCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneratePrompt() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String prompt,  int count,  String style,  PeopleCount peopleCount)  $default,) {final _that = this;
switch (_that) {
case _GeneratePrompt():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String prompt,  int count,  String style,  PeopleCount peopleCount)?  $default,) {final _that = this;
switch (_that) {
case _GeneratePrompt() when $default != null:
return $default(_that.prompt,_that.count,_that.style,_that.peopleCount);case _:
  return null;

}
}

}

/// @nodoc


class _GeneratePrompt implements GeneratePrompt {
  const _GeneratePrompt({required this.prompt, required this.count, required this.style, required this.peopleCount});
  

/// The free-text scene description.
@override final  String prompt;
/// How many pose variations to generate.
@override final  int count;
/// The artistic style (e.g. 'photo', 'illustration', 'sketch').
@override final  String style;
/// How many people are in the scene (solo, duo).
@override final  PeopleCount peopleCount;

/// Create a copy of GeneratePrompt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratePromptCopyWith<_GeneratePrompt> get copyWith => __$GeneratePromptCopyWithImpl<_GeneratePrompt>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratePrompt&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.count, count) || other.count == count)&&(identical(other.style, style) || other.style == style)&&(identical(other.peopleCount, peopleCount) || other.peopleCount == peopleCount));
}


@override
int get hashCode => Object.hash(runtimeType,prompt,count,style,peopleCount);

@override
String toString() {
  return 'GeneratePrompt(prompt: $prompt, count: $count, style: $style, peopleCount: $peopleCount)';
}


}

/// @nodoc
abstract mixin class _$GeneratePromptCopyWith<$Res> implements $GeneratePromptCopyWith<$Res> {
  factory _$GeneratePromptCopyWith(_GeneratePrompt value, $Res Function(_GeneratePrompt) _then) = __$GeneratePromptCopyWithImpl;
@override @useResult
$Res call({
 String prompt, int count, String style, PeopleCount peopleCount
});




}
/// @nodoc
class __$GeneratePromptCopyWithImpl<$Res>
    implements _$GeneratePromptCopyWith<$Res> {
  __$GeneratePromptCopyWithImpl(this._self, this._then);

  final _GeneratePrompt _self;
  final $Res Function(_GeneratePrompt) _then;

/// Create a copy of GeneratePrompt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prompt = null,Object? count = null,Object? style = null,Object? peopleCount = null,}) {
  return _then(_GeneratePrompt(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String,peopleCount: null == peopleCount ? _self.peopleCount : peopleCount // ignore: cast_nullable_to_non_nullable
as PeopleCount,
  ));
}


}

// dart format on
