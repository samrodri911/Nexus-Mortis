// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_game_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetActiveGameEntityCollection on Isar {
  IsarCollection<ActiveGameEntity> get activeGameEntitys => this.collection();
}

const ActiveGameEntitySchema = CollectionSchema(
  name: r'ActiveGameEntity',
  id: 7589338797119482180,
  properties: {
    r'caseId': PropertySchema(
      id: 0,
      name: r'caseId',
      type: IsarType.string,
    ),
    r'savedAt': PropertySchema(
      id: 1,
      name: r'savedAt',
      type: IsarType.dateTime,
    ),
    r'stateJson': PropertySchema(
      id: 2,
      name: r'stateJson',
      type: IsarType.string,
    )
  },
  estimateSize: _activeGameEntityEstimateSize,
  serialize: _activeGameEntitySerialize,
  deserialize: _activeGameEntityDeserialize,
  deserializeProp: _activeGameEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _activeGameEntityGetId,
  getLinks: _activeGameEntityGetLinks,
  attach: _activeGameEntityAttach,
  version: '3.1.0+1',
);

int _activeGameEntityEstimateSize(
  ActiveGameEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.caseId.length * 3;
  bytesCount += 3 + object.stateJson.length * 3;
  return bytesCount;
}

void _activeGameEntitySerialize(
  ActiveGameEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.caseId);
  writer.writeDateTime(offsets[1], object.savedAt);
  writer.writeString(offsets[2], object.stateJson);
}

ActiveGameEntity _activeGameEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ActiveGameEntity();
  object.caseId = reader.readString(offsets[0]);
  object.id = id;
  object.savedAt = reader.readDateTime(offsets[1]);
  object.stateJson = reader.readString(offsets[2]);
  return object;
}

P _activeGameEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _activeGameEntityGetId(ActiveGameEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _activeGameEntityGetLinks(ActiveGameEntity object) {
  return [];
}

void _activeGameEntityAttach(
    IsarCollection<dynamic> col, Id id, ActiveGameEntity object) {
  object.id = id;
}

extension ActiveGameEntityQueryWhereSort
    on QueryBuilder<ActiveGameEntity, ActiveGameEntity, QWhere> {
  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ActiveGameEntityQueryWhere
    on QueryBuilder<ActiveGameEntity, ActiveGameEntity, QWhereClause> {
  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ActiveGameEntityQueryFilter
    on QueryBuilder<ActiveGameEntity, ActiveGameEntity, QFilterCondition> {
  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      caseIdEqualTo(
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

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      caseIdGreaterThan(
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

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      caseIdLessThan(
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

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      caseIdBetween(
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

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      caseIdStartsWith(
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

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      caseIdEndsWith(
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

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      caseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'caseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      caseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'caseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      caseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      caseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'caseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      savedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      savedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      savedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      savedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'savedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      stateJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      stateJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      stateJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      stateJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stateJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      stateJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      stateJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      stateJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      stateJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stateJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      stateJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterFilterCondition>
      stateJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stateJson',
        value: '',
      ));
    });
  }
}

extension ActiveGameEntityQueryObject
    on QueryBuilder<ActiveGameEntity, ActiveGameEntity, QFilterCondition> {}

extension ActiveGameEntityQueryLinks
    on QueryBuilder<ActiveGameEntity, ActiveGameEntity, QFilterCondition> {}

extension ActiveGameEntityQuerySortBy
    on QueryBuilder<ActiveGameEntity, ActiveGameEntity, QSortBy> {
  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy>
      sortByCaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseId', Sort.asc);
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy>
      sortByCaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseId', Sort.desc);
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy>
      sortBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy>
      sortBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy>
      sortByStateJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateJson', Sort.asc);
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy>
      sortByStateJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateJson', Sort.desc);
    });
  }
}

extension ActiveGameEntityQuerySortThenBy
    on QueryBuilder<ActiveGameEntity, ActiveGameEntity, QSortThenBy> {
  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy>
      thenByCaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseId', Sort.asc);
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy>
      thenByCaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseId', Sort.desc);
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy>
      thenBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy>
      thenBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy>
      thenByStateJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateJson', Sort.asc);
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QAfterSortBy>
      thenByStateJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateJson', Sort.desc);
    });
  }
}

extension ActiveGameEntityQueryWhereDistinct
    on QueryBuilder<ActiveGameEntity, ActiveGameEntity, QDistinct> {
  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QDistinct> distinctByCaseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QDistinct>
      distinctBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAt');
    });
  }

  QueryBuilder<ActiveGameEntity, ActiveGameEntity, QDistinct>
      distinctByStateJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stateJson', caseSensitive: caseSensitive);
    });
  }
}

extension ActiveGameEntityQueryProperty
    on QueryBuilder<ActiveGameEntity, ActiveGameEntity, QQueryProperty> {
  QueryBuilder<ActiveGameEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ActiveGameEntity, String, QQueryOperations> caseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caseId');
    });
  }

  QueryBuilder<ActiveGameEntity, DateTime, QQueryOperations> savedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAt');
    });
  }

  QueryBuilder<ActiveGameEntity, String, QQueryOperations> stateJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stateJson');
    });
  }
}
