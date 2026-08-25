// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStatisticsEntityCollection on Isar {
  IsarCollection<StatisticsEntity> get statisticsEntitys => this.collection();
}

const StatisticsEntitySchema = CollectionSchema(
  name: r'StatisticsEntity',
  id: -6583886862633228771,
  properties: {
    r'bestStarsJson': PropertySchema(
      id: 0,
      name: r'bestStarsJson',
      type: IsarType.string,
    ),
    r'campaignCasesSolved': PropertySchema(
      id: 1,
      name: r'campaignCasesSolved',
      type: IsarType.long,
    ),
    r'proceduralCasesSolved': PropertySchema(
      id: 2,
      name: r'proceduralCasesSolved',
      type: IsarType.long,
    ),
    r'puzzlesSolved': PropertySchema(
      id: 3,
      name: r'puzzlesSolved',
      type: IsarType.long,
    ),
    r'totalCoinsEarned': PropertySchema(
      id: 4,
      name: r'totalCoinsEarned',
      type: IsarType.long,
    ),
    r'totalHintsUsed': PropertySchema(
      id: 5,
      name: r'totalHintsUsed',
      type: IsarType.long,
    ),
    r'totalPlayTimeSeconds': PropertySchema(
      id: 6,
      name: r'totalPlayTimeSeconds',
      type: IsarType.long,
    ),
    r'totalStarsEarned': PropertySchema(
      id: 7,
      name: r'totalStarsEarned',
      type: IsarType.long,
    )
  },
  estimateSize: _statisticsEntityEstimateSize,
  serialize: _statisticsEntitySerialize,
  deserialize: _statisticsEntityDeserialize,
  deserializeProp: _statisticsEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _statisticsEntityGetId,
  getLinks: _statisticsEntityGetLinks,
  attach: _statisticsEntityAttach,
  version: '3.1.0+1',
);

int _statisticsEntityEstimateSize(
  StatisticsEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bestStarsJson.length * 3;
  return bytesCount;
}

void _statisticsEntitySerialize(
  StatisticsEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bestStarsJson);
  writer.writeLong(offsets[1], object.campaignCasesSolved);
  writer.writeLong(offsets[2], object.proceduralCasesSolved);
  writer.writeLong(offsets[3], object.puzzlesSolved);
  writer.writeLong(offsets[4], object.totalCoinsEarned);
  writer.writeLong(offsets[5], object.totalHintsUsed);
  writer.writeLong(offsets[6], object.totalPlayTimeSeconds);
  writer.writeLong(offsets[7], object.totalStarsEarned);
}

StatisticsEntity _statisticsEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StatisticsEntity();
  object.bestStarsJson = reader.readString(offsets[0]);
  object.campaignCasesSolved = reader.readLong(offsets[1]);
  object.id = id;
  object.proceduralCasesSolved = reader.readLong(offsets[2]);
  object.puzzlesSolved = reader.readLong(offsets[3]);
  object.totalCoinsEarned = reader.readLong(offsets[4]);
  object.totalHintsUsed = reader.readLong(offsets[5]);
  object.totalPlayTimeSeconds = reader.readLong(offsets[6]);
  object.totalStarsEarned = reader.readLong(offsets[7]);
  return object;
}

P _statisticsEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _statisticsEntityGetId(StatisticsEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _statisticsEntityGetLinks(StatisticsEntity object) {
  return [];
}

void _statisticsEntityAttach(
    IsarCollection<dynamic> col, Id id, StatisticsEntity object) {
  object.id = id;
}

extension StatisticsEntityQueryWhereSort
    on QueryBuilder<StatisticsEntity, StatisticsEntity, QWhere> {
  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StatisticsEntityQueryWhere
    on QueryBuilder<StatisticsEntity, StatisticsEntity, QWhereClause> {
  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterWhereClause>
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

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterWhereClause> idBetween(
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

extension StatisticsEntityQueryFilter
    on QueryBuilder<StatisticsEntity, StatisticsEntity, QFilterCondition> {
  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      bestStarsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bestStarsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      bestStarsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bestStarsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      bestStarsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bestStarsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      bestStarsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bestStarsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      bestStarsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bestStarsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      bestStarsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bestStarsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      bestStarsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bestStarsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      bestStarsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bestStarsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      bestStarsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bestStarsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      bestStarsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bestStarsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      campaignCasesSolvedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campaignCasesSolved',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      campaignCasesSolvedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'campaignCasesSolved',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      campaignCasesSolvedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'campaignCasesSolved',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      campaignCasesSolvedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'campaignCasesSolved',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
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

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
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

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
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

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      proceduralCasesSolvedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proceduralCasesSolved',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      proceduralCasesSolvedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proceduralCasesSolved',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      proceduralCasesSolvedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proceduralCasesSolved',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      proceduralCasesSolvedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proceduralCasesSolved',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      puzzlesSolvedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'puzzlesSolved',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      puzzlesSolvedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'puzzlesSolved',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      puzzlesSolvedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'puzzlesSolved',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      puzzlesSolvedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'puzzlesSolved',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalCoinsEarnedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCoinsEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalCoinsEarnedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCoinsEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalCoinsEarnedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCoinsEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalCoinsEarnedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCoinsEarned',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalHintsUsedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalHintsUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalHintsUsedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalHintsUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalHintsUsedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalHintsUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalHintsUsedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalHintsUsed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalPlayTimeSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPlayTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalPlayTimeSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPlayTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalPlayTimeSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPlayTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalPlayTimeSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPlayTimeSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalStarsEarnedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalStarsEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalStarsEarnedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalStarsEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalStarsEarnedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalStarsEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterFilterCondition>
      totalStarsEarnedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalStarsEarned',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StatisticsEntityQueryObject
    on QueryBuilder<StatisticsEntity, StatisticsEntity, QFilterCondition> {}

extension StatisticsEntityQueryLinks
    on QueryBuilder<StatisticsEntity, StatisticsEntity, QFilterCondition> {}

extension StatisticsEntityQuerySortBy
    on QueryBuilder<StatisticsEntity, StatisticsEntity, QSortBy> {
  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByBestStarsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStarsJson', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByBestStarsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStarsJson', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByCampaignCasesSolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignCasesSolved', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByCampaignCasesSolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignCasesSolved', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByProceduralCasesSolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proceduralCasesSolved', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByProceduralCasesSolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proceduralCasesSolved', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByPuzzlesSolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'puzzlesSolved', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByPuzzlesSolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'puzzlesSolved', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByTotalCoinsEarned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCoinsEarned', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByTotalCoinsEarnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCoinsEarned', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByTotalHintsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHintsUsed', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByTotalHintsUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHintsUsed', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByTotalPlayTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPlayTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByTotalPlayTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPlayTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByTotalStarsEarned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStarsEarned', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      sortByTotalStarsEarnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStarsEarned', Sort.desc);
    });
  }
}

extension StatisticsEntityQuerySortThenBy
    on QueryBuilder<StatisticsEntity, StatisticsEntity, QSortThenBy> {
  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByBestStarsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStarsJson', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByBestStarsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStarsJson', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByCampaignCasesSolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignCasesSolved', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByCampaignCasesSolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignCasesSolved', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByProceduralCasesSolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proceduralCasesSolved', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByProceduralCasesSolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proceduralCasesSolved', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByPuzzlesSolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'puzzlesSolved', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByPuzzlesSolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'puzzlesSolved', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByTotalCoinsEarned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCoinsEarned', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByTotalCoinsEarnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCoinsEarned', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByTotalHintsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHintsUsed', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByTotalHintsUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHintsUsed', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByTotalPlayTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPlayTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByTotalPlayTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPlayTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByTotalStarsEarned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStarsEarned', Sort.asc);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QAfterSortBy>
      thenByTotalStarsEarnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStarsEarned', Sort.desc);
    });
  }
}

extension StatisticsEntityQueryWhereDistinct
    on QueryBuilder<StatisticsEntity, StatisticsEntity, QDistinct> {
  QueryBuilder<StatisticsEntity, StatisticsEntity, QDistinct>
      distinctByBestStarsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bestStarsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QDistinct>
      distinctByCampaignCasesSolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campaignCasesSolved');
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QDistinct>
      distinctByProceduralCasesSolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proceduralCasesSolved');
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QDistinct>
      distinctByPuzzlesSolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'puzzlesSolved');
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QDistinct>
      distinctByTotalCoinsEarned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCoinsEarned');
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QDistinct>
      distinctByTotalHintsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalHintsUsed');
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QDistinct>
      distinctByTotalPlayTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPlayTimeSeconds');
    });
  }

  QueryBuilder<StatisticsEntity, StatisticsEntity, QDistinct>
      distinctByTotalStarsEarned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalStarsEarned');
    });
  }
}

extension StatisticsEntityQueryProperty
    on QueryBuilder<StatisticsEntity, StatisticsEntity, QQueryProperty> {
  QueryBuilder<StatisticsEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StatisticsEntity, String, QQueryOperations>
      bestStarsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bestStarsJson');
    });
  }

  QueryBuilder<StatisticsEntity, int, QQueryOperations>
      campaignCasesSolvedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campaignCasesSolved');
    });
  }

  QueryBuilder<StatisticsEntity, int, QQueryOperations>
      proceduralCasesSolvedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proceduralCasesSolved');
    });
  }

  QueryBuilder<StatisticsEntity, int, QQueryOperations>
      puzzlesSolvedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'puzzlesSolved');
    });
  }

  QueryBuilder<StatisticsEntity, int, QQueryOperations>
      totalCoinsEarnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCoinsEarned');
    });
  }

  QueryBuilder<StatisticsEntity, int, QQueryOperations>
      totalHintsUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalHintsUsed');
    });
  }

  QueryBuilder<StatisticsEntity, int, QQueryOperations>
      totalPlayTimeSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPlayTimeSeconds');
    });
  }

  QueryBuilder<StatisticsEntity, int, QQueryOperations>
      totalStarsEarnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalStarsEarned');
    });
  }
}
