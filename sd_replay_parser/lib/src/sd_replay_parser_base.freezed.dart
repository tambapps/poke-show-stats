// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sd_replay_parser_base.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Terastallization {
  String get pokemon => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Create a copy of Terastallization
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TerastallizationCopyWith<Terastallization> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TerastallizationCopyWith<$Res> {
  factory $TerastallizationCopyWith(
          Terastallization value, $Res Function(Terastallization) then) =
      _$TerastallizationCopyWithImpl<$Res, Terastallization>;
  @useResult
  $Res call({String pokemon, String type});
}

/// @nodoc
class _$TerastallizationCopyWithImpl<$Res, $Val extends Terastallization>
    implements $TerastallizationCopyWith<$Res> {
  _$TerastallizationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Terastallization
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pokemon = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      pokemon: null == pokemon
          ? _value.pokemon
          : pokemon // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TerastallizationImplCopyWith<$Res>
    implements $TerastallizationCopyWith<$Res> {
  factory _$$TerastallizationImplCopyWith(_$TerastallizationImpl value,
          $Res Function(_$TerastallizationImpl) then) =
      __$$TerastallizationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String pokemon, String type});
}

/// @nodoc
class __$$TerastallizationImplCopyWithImpl<$Res>
    extends _$TerastallizationCopyWithImpl<$Res, _$TerastallizationImpl>
    implements _$$TerastallizationImplCopyWith<$Res> {
  __$$TerastallizationImplCopyWithImpl(_$TerastallizationImpl _value,
      $Res Function(_$TerastallizationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Terastallization
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pokemon = null,
    Object? type = null,
  }) {
    return _then(_$TerastallizationImpl(
      pokemon: null == pokemon
          ? _value.pokemon
          : pokemon // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TerastallizationImpl implements _Terastallization {
  const _$TerastallizationImpl({required this.pokemon, required this.type});

  @override
  final String pokemon;
  @override
  final String type;

  @override
  String toString() {
    return 'Terastallization(pokemon: $pokemon, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TerastallizationImpl &&
            (identical(other.pokemon, pokemon) || other.pokemon == pokemon) &&
            (identical(other.type, type) || other.type == type));
  }

  @override
  int get hashCode => Object.hash(runtimeType, pokemon, type);

  /// Create a copy of Terastallization
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TerastallizationImplCopyWith<_$TerastallizationImpl> get copyWith =>
      __$$TerastallizationImplCopyWithImpl<_$TerastallizationImpl>(
          this, _$identity);
}

abstract class _Terastallization implements Terastallization {
  const factory _Terastallization(
      {required final String pokemon,
      required final String type}) = _$TerastallizationImpl;

  @override
  String get pokemon;
  @override
  String get type;

  /// Create a copy of Terastallization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TerastallizationImplCopyWith<_$TerastallizationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
