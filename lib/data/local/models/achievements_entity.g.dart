// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievements_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAchievementsEntityCollection on Isar {
  IsarCollection<AchievementsEntity> get achievementsEntitys =>
      this.collection();
}

const AchievementsEntitySchema = CollectionSchema(
  name: r'AchievementsEntity',
  id: -8658039728610628569,
  properties: {
    r'items': PropertySchema(
      id: 0,
      name: r'items',
      type: IsarType.objectList,
      target: r'AchievementProgressEmbedded',
    )
  },
  estimateSize: _achievementsEntityEstimateSize,
  serialize: _achievementsEntitySerialize,
  deserialize: _achievementsEntityDeserialize,
  deserializeProp: _achievementsEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {
    r'AchievementProgressEmbedded': AchievementProgressEmbeddedSchema
  },
  getId: _achievementsEntityGetId,
  getLinks: _achievementsEntityGetLinks,
  attach: _achievementsEntityAttach,
  version: '3.1.0+1',
);

int _achievementsEntityEstimateSize(
  AchievementsEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.items.length * 3;
  {
    final offsets = allOffsets[AchievementProgressEmbedded]!;
    for (var i = 0; i < object.items.length; i++) {
      final value = object.items[i];
      bytesCount += AchievementProgressEmbeddedSchema.estimateSize(
          value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _achievementsEntitySerialize(
  AchievementsEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<AchievementProgressEmbedded>(
    offsets[0],
    allOffsets,
    AchievementProgressEmbeddedSchema.serialize,
    object.items,
  );
}

AchievementsEntity _achievementsEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AchievementsEntity();
  object.id = id;
  object.items = reader.readObjectList<AchievementProgressEmbedded>(
        offsets[0],
        AchievementProgressEmbeddedSchema.deserialize,
        allOffsets,
        AchievementProgressEmbedded(),
      ) ??
      [];
  return object;
}

P _achievementsEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<AchievementProgressEmbedded>(
            offset,
            AchievementProgressEmbeddedSchema.deserialize,
            allOffsets,
            AchievementProgressEmbedded(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _achievementsEntityGetId(AchievementsEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _achievementsEntityGetLinks(
    AchievementsEntity object) {
  return [];
}

void _achievementsEntityAttach(
    IsarCollection<dynamic> col, Id id, AchievementsEntity object) {
  object.id = id;
}

extension AchievementsEntityQueryWhereSort
    on QueryBuilder<AchievementsEntity, AchievementsEntity, QWhere> {
  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AchievementsEntityQueryWhere
    on QueryBuilder<AchievementsEntity, AchievementsEntity, QWhereClause> {
  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterWhereClause>
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

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterWhereClause>
      idBetween(
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

extension AchievementsEntityQueryFilter
    on QueryBuilder<AchievementsEntity, AchievementsEntity, QFilterCondition> {
  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterFilterCondition>
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

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterFilterCondition>
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

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterFilterCondition>
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

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterFilterCondition>
      itemsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterFilterCondition>
      itemsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterFilterCondition>
      itemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterFilterCondition>
      itemsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterFilterCondition>
      itemsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterFilterCondition>
      itemsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension AchievementsEntityQueryObject
    on QueryBuilder<AchievementsEntity, AchievementsEntity, QFilterCondition> {
  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterFilterCondition>
      itemsElement(FilterQuery<AchievementProgressEmbedded> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'items');
    });
  }
}

extension AchievementsEntityQueryLinks
    on QueryBuilder<AchievementsEntity, AchievementsEntity, QFilterCondition> {}

extension AchievementsEntityQuerySortBy
    on QueryBuilder<AchievementsEntity, AchievementsEntity, QSortBy> {}

extension AchievementsEntityQuerySortThenBy
    on QueryBuilder<AchievementsEntity, AchievementsEntity, QSortThenBy> {
  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AchievementsEntity, AchievementsEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension AchievementsEntityQueryWhereDistinct
    on QueryBuilder<AchievementsEntity, AchievementsEntity, QDistinct> {}

extension AchievementsEntityQueryProperty
    on QueryBuilder<AchievementsEntity, AchievementsEntity, QQueryProperty> {
  QueryBuilder<AchievementsEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AchievementsEntity, List<AchievementProgressEmbedded>,
      QQueryOperations> itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'items');
    });
  }
}
