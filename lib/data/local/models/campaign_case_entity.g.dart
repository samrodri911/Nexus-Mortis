// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_case_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCampaignCaseEntityCollection on Isar {
  IsarCollection<CampaignCaseEntity> get campaignCaseEntitys =>
      this.collection();
}

const CampaignCaseEntitySchema = CollectionSchema(
  name: r'CampaignCaseEntity',
  id: 883558743288501629,
  properties: {
    r'caseId': PropertySchema(
      id: 0,
      name: r'caseId',
      type: IsarType.string,
    ),
    r'caseIndex': PropertySchema(
      id: 1,
      name: r'caseIndex',
      type: IsarType.long,
    ),
    r'caseJson': PropertySchema(
      id: 2,
      name: r'caseJson',
      type: IsarType.string,
    ),
    r'columns': PropertySchema(
      id: 3,
      name: r'columns',
      type: IsarType.long,
    ),
    r'description': PropertySchema(
      id: 4,
      name: r'description',
      type: IsarType.string,
    ),
    r'difficulty': PropertySchema(
      id: 5,
      name: r'difficulty',
      type: IsarType.string,
    ),
    r'difficultyScore': PropertySchema(
      id: 6,
      name: r'difficultyScore',
      type: IsarType.long,
    ),
    r'objects': PropertySchema(
      id: 7,
      name: r'objects',
      type: IsarType.long,
    ),
    r'requiredCaseId': PropertySchema(
      id: 8,
      name: r'requiredCaseId',
      type: IsarType.string,
    ),
    r'rows': PropertySchema(
      id: 9,
      name: r'rows',
      type: IsarType.long,
    ),
    r'seed': PropertySchema(
      id: 10,
      name: r'seed',
      type: IsarType.long,
    ),
    r'suspects': PropertySchema(
      id: 11,
      name: r'suspects',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 12,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _campaignCaseEntityEstimateSize,
  serialize: _campaignCaseEntitySerialize,
  deserialize: _campaignCaseEntityDeserialize,
  deserializeProp: _campaignCaseEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'caseId': IndexSchema(
      id: 7316275356094004476,
      name: r'caseId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'caseId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _campaignCaseEntityGetId,
  getLinks: _campaignCaseEntityGetLinks,
  attach: _campaignCaseEntityAttach,
  version: '3.1.0+1',
);

int _campaignCaseEntityEstimateSize(
  CampaignCaseEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.caseId.length * 3;
  {
    final value = object.caseJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.difficulty.length * 3;
  {
    final value = object.requiredCaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _campaignCaseEntitySerialize(
  CampaignCaseEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.caseId);
  writer.writeLong(offsets[1], object.caseIndex);
  writer.writeString(offsets[2], object.caseJson);
  writer.writeLong(offsets[3], object.columns);
  writer.writeString(offsets[4], object.description);
  writer.writeString(offsets[5], object.difficulty);
  writer.writeLong(offsets[6], object.difficultyScore);
  writer.writeLong(offsets[7], object.objects);
  writer.writeString(offsets[8], object.requiredCaseId);
  writer.writeLong(offsets[9], object.rows);
  writer.writeLong(offsets[10], object.seed);
  writer.writeLong(offsets[11], object.suspects);
  writer.writeString(offsets[12], object.title);
}

CampaignCaseEntity _campaignCaseEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CampaignCaseEntity();
  object.caseId = reader.readString(offsets[0]);
  object.caseIndex = reader.readLong(offsets[1]);
  object.caseJson = reader.readStringOrNull(offsets[2]);
  object.columns = reader.readLong(offsets[3]);
  object.description = reader.readString(offsets[4]);
  object.difficulty = reader.readString(offsets[5]);
  object.difficultyScore = reader.readLong(offsets[6]);
  object.id = id;
  object.objects = reader.readLong(offsets[7]);
  object.requiredCaseId = reader.readStringOrNull(offsets[8]);
  object.rows = reader.readLong(offsets[9]);
  object.seed = reader.readLong(offsets[10]);
  object.suspects = reader.readLong(offsets[11]);
  object.title = reader.readString(offsets[12]);
  return object;
}

P _campaignCaseEntityDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _campaignCaseEntityGetId(CampaignCaseEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _campaignCaseEntityGetLinks(
    CampaignCaseEntity object) {
  return [];
}

void _campaignCaseEntityAttach(
    IsarCollection<dynamic> col, Id id, CampaignCaseEntity object) {
  object.id = id;
}

extension CampaignCaseEntityByIndex on IsarCollection<CampaignCaseEntity> {
  Future<CampaignCaseEntity?> getByCaseId(String caseId) {
    return getByIndex(r'caseId', [caseId]);
  }

  CampaignCaseEntity? getByCaseIdSync(String caseId) {
    return getByIndexSync(r'caseId', [caseId]);
  }

  Future<bool> deleteByCaseId(String caseId) {
    return deleteByIndex(r'caseId', [caseId]);
  }

  bool deleteByCaseIdSync(String caseId) {
    return deleteByIndexSync(r'caseId', [caseId]);
  }

  Future<List<CampaignCaseEntity?>> getAllByCaseId(List<String> caseIdValues) {
    final values = caseIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'caseId', values);
  }

  List<CampaignCaseEntity?> getAllByCaseIdSync(List<String> caseIdValues) {
    final values = caseIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'caseId', values);
  }

  Future<int> deleteAllByCaseId(List<String> caseIdValues) {
    final values = caseIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'caseId', values);
  }

  int deleteAllByCaseIdSync(List<String> caseIdValues) {
    final values = caseIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'caseId', values);
  }

  Future<Id> putByCaseId(CampaignCaseEntity object) {
    return putByIndex(r'caseId', object);
  }

  Id putByCaseIdSync(CampaignCaseEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'caseId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCaseId(List<CampaignCaseEntity> objects) {
    return putAllByIndex(r'caseId', objects);
  }

  List<Id> putAllByCaseIdSync(List<CampaignCaseEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'caseId', objects, saveLinks: saveLinks);
  }
}

extension CampaignCaseEntityQueryWhereSort
    on QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QWhere> {
  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CampaignCaseEntityQueryWhere
    on QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QWhereClause> {
  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterWhereClause>
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

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterWhereClause>
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

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterWhereClause>
      caseIdEqualTo(String caseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'caseId',
        value: [caseId],
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterWhereClause>
      caseIdNotEqualTo(String caseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'caseId',
              lower: [],
              upper: [caseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'caseId',
              lower: [caseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'caseId',
              lower: [caseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'caseId',
              lower: [],
              upper: [caseId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CampaignCaseEntityQueryFilter
    on QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QFilterCondition> {
  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
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

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
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

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
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

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
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

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
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

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
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

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'caseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'caseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'caseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caseIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'caseIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'caseIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'caseIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'caseJson',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'caseJson',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caseJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'caseJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'caseJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'caseJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'caseJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'caseJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'caseJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'caseJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caseJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      caseJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'caseJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      columnsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'columns',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      columnsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'columns',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      columnsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'columns',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      columnsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'columns',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'difficulty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'difficulty',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyScoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficultyScore',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyScoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'difficultyScore',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyScoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'difficultyScore',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      difficultyScoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'difficultyScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
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

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
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

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
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

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      objectsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'objects',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      objectsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'objects',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      objectsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'objects',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      objectsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'objects',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      requiredCaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'requiredCaseId',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      requiredCaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'requiredCaseId',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      requiredCaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requiredCaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      requiredCaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requiredCaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      requiredCaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requiredCaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      requiredCaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requiredCaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      requiredCaseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requiredCaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      requiredCaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requiredCaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      requiredCaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requiredCaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      requiredCaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requiredCaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      requiredCaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requiredCaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      requiredCaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requiredCaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      rowsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rows',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      rowsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rows',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      rowsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rows',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      rowsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rows',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      seedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seed',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      seedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'seed',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      seedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'seed',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      seedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'seed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      suspectsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'suspects',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      suspectsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'suspects',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      suspectsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'suspects',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      suspectsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'suspects',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension CampaignCaseEntityQueryObject
    on QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QFilterCondition> {}

extension CampaignCaseEntityQueryLinks
    on QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QFilterCondition> {}

extension CampaignCaseEntityQuerySortBy
    on QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QSortBy> {
  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByCaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseId', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByCaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseId', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByCaseIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseIndex', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByCaseIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseIndex', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByCaseJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByCaseJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByColumns() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'columns', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByColumnsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'columns', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByDifficultyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyScore', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByDifficultyScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyScore', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByObjects() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objects', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByObjectsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objects', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByRequiredCaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiredCaseId', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByRequiredCaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiredCaseId', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByRows() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rows', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByRowsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rows', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortBySeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seed', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortBySeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seed', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortBySuspects() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suspects', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortBySuspectsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suspects', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension CampaignCaseEntityQuerySortThenBy
    on QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QSortThenBy> {
  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByCaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseId', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByCaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseId', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByCaseIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseIndex', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByCaseIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseIndex', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByCaseJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByCaseJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByColumns() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'columns', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByColumnsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'columns', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByDifficultyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyScore', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByDifficultyScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyScore', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByObjects() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objects', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByObjectsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objects', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByRequiredCaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiredCaseId', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByRequiredCaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiredCaseId', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByRows() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rows', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByRowsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rows', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenBySeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seed', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenBySeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seed', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenBySuspects() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suspects', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenBySuspectsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suspects', Sort.desc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension CampaignCaseEntityQueryWhereDistinct
    on QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct> {
  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct>
      distinctByCaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct>
      distinctByCaseIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caseIndex');
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct>
      distinctByCaseJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caseJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct>
      distinctByColumns() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'columns');
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct>
      distinctByDifficulty({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficulty', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct>
      distinctByDifficultyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficultyScore');
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct>
      distinctByObjects() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'objects');
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct>
      distinctByRequiredCaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requiredCaseId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct>
      distinctByRows() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rows');
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct>
      distinctBySeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seed');
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct>
      distinctBySuspects() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'suspects');
    });
  }

  QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension CampaignCaseEntityQueryProperty
    on QueryBuilder<CampaignCaseEntity, CampaignCaseEntity, QQueryProperty> {
  QueryBuilder<CampaignCaseEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CampaignCaseEntity, String, QQueryOperations> caseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caseId');
    });
  }

  QueryBuilder<CampaignCaseEntity, int, QQueryOperations> caseIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caseIndex');
    });
  }

  QueryBuilder<CampaignCaseEntity, String?, QQueryOperations>
      caseJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caseJson');
    });
  }

  QueryBuilder<CampaignCaseEntity, int, QQueryOperations> columnsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'columns');
    });
  }

  QueryBuilder<CampaignCaseEntity, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<CampaignCaseEntity, String, QQueryOperations>
      difficultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficulty');
    });
  }

  QueryBuilder<CampaignCaseEntity, int, QQueryOperations>
      difficultyScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficultyScore');
    });
  }

  QueryBuilder<CampaignCaseEntity, int, QQueryOperations> objectsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'objects');
    });
  }

  QueryBuilder<CampaignCaseEntity, String?, QQueryOperations>
      requiredCaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requiredCaseId');
    });
  }

  QueryBuilder<CampaignCaseEntity, int, QQueryOperations> rowsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rows');
    });
  }

  QueryBuilder<CampaignCaseEntity, int, QQueryOperations> seedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seed');
    });
  }

  QueryBuilder<CampaignCaseEntity, int, QQueryOperations> suspectsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suspects');
    });
  }

  QueryBuilder<CampaignCaseEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
