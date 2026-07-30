// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_progress_embedded.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const CaseProgressEmbeddedSchema = Schema(
  name: r'CaseProgressEmbedded',
  id: -2378579626277484630,
  properties: {
    r'caseId': PropertySchema(
      id: 0,
      name: r'caseId',
      type: IsarType.string,
    ),
    r'completed': PropertySchema(
      id: 1,
      name: r'completed',
      type: IsarType.bool,
    ),
    r'starsEarned': PropertySchema(
      id: 2,
      name: r'starsEarned',
      type: IsarType.long,
    )
  },
  estimateSize: _caseProgressEmbeddedEstimateSize,
  serialize: _caseProgressEmbeddedSerialize,
  deserialize: _caseProgressEmbeddedDeserialize,
  deserializeProp: _caseProgressEmbeddedDeserializeProp,
);

int _caseProgressEmbeddedEstimateSize(
  CaseProgressEmbedded object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.caseId.length * 3;
  return bytesCount;
}

void _caseProgressEmbeddedSerialize(
  CaseProgressEmbedded object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.caseId);
  writer.writeBool(offsets[1], object.completed);
  writer.writeLong(offsets[2], object.starsEarned);
}

CaseProgressEmbedded _caseProgressEmbeddedDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CaseProgressEmbedded();
  object.caseId = reader.readString(offsets[0]);
  object.completed = reader.readBool(offsets[1]);
  object.starsEarned = reader.readLong(offsets[2]);
  return object;
}

P _caseProgressEmbeddedDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension CaseProgressEmbeddedQueryFilter on QueryBuilder<CaseProgressEmbedded,
    CaseProgressEmbedded, QFilterCondition> {
  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
      QAfterFilterCondition> caseIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
      QAfterFilterCondition> caseIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'caseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
      QAfterFilterCondition> caseIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'caseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
      QAfterFilterCondition> caseIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'caseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
      QAfterFilterCondition> caseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'caseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
      QAfterFilterCondition> caseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'caseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
          QAfterFilterCondition>
      caseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'caseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
          QAfterFilterCondition>
      caseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'caseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
      QAfterFilterCondition> caseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
      QAfterFilterCondition> caseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'caseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
      QAfterFilterCondition> completedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completed',
        value: value,
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
      QAfterFilterCondition> starsEarnedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'starsEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
      QAfterFilterCondition> starsEarnedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'starsEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
      QAfterFilterCondition> starsEarnedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'starsEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<CaseProgressEmbedded, CaseProgressEmbedded,
      QAfterFilterCondition> starsEarnedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'starsEarned',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CaseProgressEmbeddedQueryObject on QueryBuilder<CaseProgressEmbedded,
    CaseProgressEmbedded, QFilterCondition> {}
