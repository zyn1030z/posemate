// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pose_score.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PoseScore {

/// Overall match percentage (0.0 to 1.0).
 double get matchPercentage;/// Body balance score (0.0 to 1.0).
 double get bodyBalance;/// True if lighting is considered good.
 bool get goodLighting;/// True if the body is fully visible.
 bool get bodyVisible;/// Optional specific feedback messages.
 List<String> get feedback;
/// Create a copy of PoseScore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PoseScoreCopyWith<PoseScore> get copyWith => _$PoseScoreCopyWithImpl<PoseScore>(this as PoseScore, _$identity);

  /// Serializes this PoseScore to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PoseScore&&(identical(other.matchPercentage, matchPercentage) || other.matchPercentage == matchPercentage)&&(identical(other.bodyBalance, bodyBalance) || other.bodyBalance == bodyBalance)&&(identical(other.goodLighting, goodLighting) || other.goodLighting == goodLighting)&&(identical(other.bodyVisible, bodyVisible) || other.bodyVisible == bodyVisible)&&const DeepCollectionEquality().equals(other.feedback, feedback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,matchPercentage,bodyBalance,goodLighting,bodyVisible,const DeepCollectionEquality().hash(feedback));

@override
String toString() {
  return 'PoseScore(matchPercentage: $matchPercentage, bodyBalance: $bodyBalance, goodLighting: $goodLighting, bodyVisible: $bodyVisible, feedback: $feedback)';
}


}

/// @nodoc
abstract mixin class $PoseScoreCopyWith<$Res>  {
  factory $PoseScoreCopyWith(PoseScore value, $Res Function(PoseScore) _then) = _$PoseScoreCopyWithImpl;
@useResult
$Res call({
 double matchPercentage, double bodyBalance, bool goodLighting, bool bodyVisible, List<String> feedback
});




}
/// @nodoc
class _$PoseScoreCopyWithImpl<$Res>
    implements $PoseScoreCopyWith<$Res> {
  _$PoseScoreCopyWithImpl(this._self, this._then);

  final PoseScore _self;
  final $Res Function(PoseScore) _then;

/// Create a copy of PoseScore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? matchPercentage = null,Object? bodyBalance = null,Object? goodLighting = null,Object? bodyVisible = null,Object? feedback = null,}) {
  return _then(_self.copyWith(
matchPercentage: null == matchPercentage ? _self.matchPercentage : matchPercentage // ignore: cast_nullable_to_non_nullable
as double,bodyBalance: null == bodyBalance ? _self.bodyBalance : bodyBalance // ignore: cast_nullable_to_non_nullable
as double,goodLighting: null == goodLighting ? _self.goodLighting : goodLighting // ignore: cast_nullable_to_non_nullable
as bool,bodyVisible: null == bodyVisible ? _self.bodyVisible : bodyVisible // ignore: cast_nullable_to_non_nullable
as bool,feedback: null == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PoseScore].
extension PoseScorePatterns on PoseScore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PoseScore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PoseScore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PoseScore value)  $default,){
final _that = this;
switch (_that) {
case _PoseScore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PoseScore value)?  $default,){
final _that = this;
switch (_that) {
case _PoseScore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double matchPercentage,  double bodyBalance,  bool goodLighting,  bool bodyVisible,  List<String> feedback)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PoseScore() when $default != null:
return $default(_that.matchPercentage,_that.bodyBalance,_that.goodLighting,_that.bodyVisible,_that.feedback);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double matchPercentage,  double bodyBalance,  bool goodLighting,  bool bodyVisible,  List<String> feedback)  $default,) {final _that = this;
switch (_that) {
case _PoseScore():
return $default(_that.matchPercentage,_that.bodyBalance,_that.goodLighting,_that.bodyVisible,_that.feedback);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double matchPercentage,  double bodyBalance,  bool goodLighting,  bool bodyVisible,  List<String> feedback)?  $default,) {final _that = this;
switch (_that) {
case _PoseScore() when $default != null:
return $default(_that.matchPercentage,_that.bodyBalance,_that.goodLighting,_that.bodyVisible,_that.feedback);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PoseScore implements PoseScore {
  const _PoseScore({required this.matchPercentage, required this.bodyBalance, this.goodLighting = true, this.bodyVisible = true, final  List<String> feedback = const []}): _feedback = feedback;
  factory _PoseScore.fromJson(Map<String, dynamic> json) => _$PoseScoreFromJson(json);

/// Overall match percentage (0.0 to 1.0).
@override final  double matchPercentage;
/// Body balance score (0.0 to 1.0).
@override final  double bodyBalance;
/// True if lighting is considered good.
@override@JsonKey() final  bool goodLighting;
/// True if the body is fully visible.
@override@JsonKey() final  bool bodyVisible;
/// Optional specific feedback messages.
 final  List<String> _feedback;
/// Optional specific feedback messages.
@override@JsonKey() List<String> get feedback {
  if (_feedback is EqualUnmodifiableListView) return _feedback;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_feedback);
}


/// Create a copy of PoseScore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PoseScoreCopyWith<_PoseScore> get copyWith => __$PoseScoreCopyWithImpl<_PoseScore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PoseScoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PoseScore&&(identical(other.matchPercentage, matchPercentage) || other.matchPercentage == matchPercentage)&&(identical(other.bodyBalance, bodyBalance) || other.bodyBalance == bodyBalance)&&(identical(other.goodLighting, goodLighting) || other.goodLighting == goodLighting)&&(identical(other.bodyVisible, bodyVisible) || other.bodyVisible == bodyVisible)&&const DeepCollectionEquality().equals(other._feedback, _feedback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,matchPercentage,bodyBalance,goodLighting,bodyVisible,const DeepCollectionEquality().hash(_feedback));

@override
String toString() {
  return 'PoseScore(matchPercentage: $matchPercentage, bodyBalance: $bodyBalance, goodLighting: $goodLighting, bodyVisible: $bodyVisible, feedback: $feedback)';
}


}

/// @nodoc
abstract mixin class _$PoseScoreCopyWith<$Res> implements $PoseScoreCopyWith<$Res> {
  factory _$PoseScoreCopyWith(_PoseScore value, $Res Function(_PoseScore) _then) = __$PoseScoreCopyWithImpl;
@override @useResult
$Res call({
 double matchPercentage, double bodyBalance, bool goodLighting, bool bodyVisible, List<String> feedback
});




}
/// @nodoc
class __$PoseScoreCopyWithImpl<$Res>
    implements _$PoseScoreCopyWith<$Res> {
  __$PoseScoreCopyWithImpl(this._self, this._then);

  final _PoseScore _self;
  final $Res Function(_PoseScore) _then;

/// Create a copy of PoseScore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? matchPercentage = null,Object? bodyBalance = null,Object? goodLighting = null,Object? bodyVisible = null,Object? feedback = null,}) {
  return _then(_PoseScore(
matchPercentage: null == matchPercentage ? _self.matchPercentage : matchPercentage // ignore: cast_nullable_to_non_nullable
as double,bodyBalance: null == bodyBalance ? _self.bodyBalance : bodyBalance // ignore: cast_nullable_to_non_nullable
as double,goodLighting: null == goodLighting ? _self.goodLighting : goodLighting // ignore: cast_nullable_to_non_nullable
as bool,bodyVisible: null == bodyVisible ? _self.bodyVisible : bodyVisible // ignore: cast_nullable_to_non_nullable
as bool,feedback: null == feedback ? _self._feedback : feedback // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
