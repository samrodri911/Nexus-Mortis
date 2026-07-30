// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_progress_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlayerProgressEntityCollection on Isar {
  IsarCollection<PlayerProgressEntity> get playerProgressEntitys =>
      this.collection();
}

const PlayerProgressEntitySchema = CollectionSchema(
  name: r'PlayerProgressEntity',
  id: -8422238016476596582,
  properties: {
    r'coins': PropertySchema(
      id: 0,
      name: r'coins',
      type: IsarType.long,
    ),
    r'completedCases': PropertySchema(
      id: 1,
      name: r'completedCases',
      type: IsarType.objectList,
      target: r'CaseProgressEmbedded',
    ),
    r'totalStars': PropertySchema(
      id: 2,
      name: r'totalStars',
      type: IsarType.long,
    )
  },
  estimateSize: _playerProgressEntityEstimateSize,
  serialize: _playerProgressEntitySerialize,
  deserialize: _playerProgressEntityDeserialize,
  deserializeProp: _playerProgressEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'CaseProgressEmbedded': CaseProgressEmbeddedSchema},
  getId: _playerProgressEntityGetId,
  getLinks: _playerProgressEntityGetLinks,
  attach: _playerProgressEntityAttach,
  version: '3.1.0+1',
);

int _playerProgressEntityEstimateSize(
  PlayerProgressEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.completedCases.length * 3;
  {
    final offsets = allOffsets[CaseProgressEmbedded]!;
    for (var i = 0; i < object.completedCases.length; i++) {
      final value = object.completedCases[i];
      bytesCount +=
          CaseProgressEmbeddedSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _playerProgressEntitySerialize(
  PlayerProgressEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.coins);
  writer.writeObjectList<CaseProgressEmbedded>(
    offsets[1],
    allOffsets,
    CaseProgressEmbeddedSchema.serialize,
    object.completedCases,
  );
  writer.writeLong(offsets[2], object.totalStars);
}

PlayerProgressEntity _playerProgressEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlayerProgressEntity();
  object.coins = reader.readLong(offsets[0]);
  object.completedCases = reader.readObjectList<CaseProgressEmbedded>(
        offsets[1],
        CaseProgressEmbeddedSchema.deserialize,
        allOffsets,
        CaseProgressEmbedded(),
      ) ??
      [];
  object.id = id;
  object.totalStars = reader.readLong(offsets[2]);
  return object;
}

P _playerProgressEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readObjectList<CaseProgressEmbedded>(
            offset,
            CaseProgressEmbeddedSchema.deserialize,
            allOffsets,
            CaseProgressEmbedded(),
          ) ??
          []) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playerProgressEntityGetId(PlayerProgressEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playerProgressEntityGetLinks(
    PlayerProgressEntity object) {
  return [];
}

void _playerProgressEntityAttach(
    IsarCollection<dynamic> col, Id id, PlayerProgressEntity object) {
  object.id = id;
}

extension PlayerProgressEntityQueryWhereSort
    on QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QWhere> {
  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlayerProgressEntityQueryWhere
    on QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QWhereClause> {
  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterWhereClause>
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

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterWhereClause>
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

extension PlayerProgressEntityQueryFilter on QueryBuilder<PlayerProgressEntity,
    PlayerProgressEntity, QFilterCondition> {
  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> coinsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coins',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> coinsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coins',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> coinsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coins',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> coinsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coins',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> completedCasesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedCases',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> completedCasesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedCases',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> completedCasesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedCases',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> completedCasesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedCases',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> completedCasesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedCases',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> completedCasesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedCases',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> totalStarsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalStars',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> totalStarsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalStars',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> totalStarsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalStars',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
      QAfterFilterCondition> totalStarsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalStars',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlayerProgressEntityQueryObject on QueryBuilder<PlayerProgressEntity,
    PlayerProgressEntity, QFilterCondition> {
  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity,
          QAfterFilterCondition>
      completedCasesElement(FilterQuery<CaseProgressEmbedded> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'completedCases');
    });
  }
}

extension PlayerProgressEntityQueryLinks on QueryBuilder<PlayerProgressEntity,
    PlayerProgressEntity, QFilterCondition> {}

extension PlayerProgressEntityQuerySortBy
    on QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QSortBy> {
  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterSortBy>
      sortByCoins() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coins', Sort.asc);
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterSortBy>
      sortByCoinsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coins', Sort.desc);
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterSortBy>
      sortByTotalStars() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStars', Sort.asc);
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterSortBy>
      sortByTotalStarsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStars', Sort.desc);
    });
  }
}

extension PlayerProgressEntityQuerySortThenBy
    on QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QSortThenBy> {
  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterSortBy>
      thenByCoins() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coins', Sort.asc);
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterSortBy>
      thenByCoinsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coins', Sort.desc);
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterSortBy>
      thenByTotalStars() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStars', Sort.asc);
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QAfterSortBy>
      thenByTotalStarsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStars', Sort.desc);
    });
  }
}

extension PlayerProgressEntityQueryWhereDistinct
    on QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QDistinct> {
  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QDistinct>
      distinctByCoins() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coins');
    });
  }

  QueryBuilder<PlayerProgressEntity, PlayerProgressEntity, QDistinct>
      distinctByTotalStars() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalStars');
    });
  }
}

extension PlayerProgressEntityQueryProperty on QueryBuilder<
    PlayerProgressEntity, PlayerProgressEntity, QQueryProperty> {
  QueryBuilder<PlayerProgressEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlayerProgressEntity, int, QQueryOperations> coinsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coins');
    });
  }

  QueryBuilder<PlayerProgressEntity, List<CaseProgressEmbedded>,
      QQueryOperations> completedCasesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedCases');
    });
  }

  QueryBuilder<PlayerProgressEntity, int, QQueryOperations>
      totalStarsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalStars');
    });
  }
}
