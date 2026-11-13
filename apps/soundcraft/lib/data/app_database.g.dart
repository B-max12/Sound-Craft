// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalTracksTable extends LocalTracks
    with TableInfo<$LocalTracksTable, LocalTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uriKindMeta = const VerificationMeta(
    'uriKind',
  );
  @override
  late final GeneratedColumn<String> uriKind = GeneratedColumn<String>(
    'uri_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artworkBlobMeta = const VerificationMeta(
    'artworkBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> artworkBlob =
      GeneratedColumn<Uint8List>(
        'artwork_blob',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
    'modified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMissingMeta = const VerificationMeta(
    'isMissing',
  );
  @override
  late final GeneratedColumn<bool> isMissing = GeneratedColumn<bool>(
    'is_missing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_missing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uri,
    uriKind,
    title,
    artist,
    album,
    durationMs,
    sizeBytes,
    genre,
    fingerprint,
    artworkBlob,
    modifiedAt,
    isMissing,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTrack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('uri')) {
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('uri_kind')) {
      context.handle(
        _uriKindMeta,
        uriKind.isAcceptableOrUnknown(data['uri_kind']!, _uriKindMeta),
      );
    } else if (isInserting) {
      context.missing(_uriKindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('artwork_blob')) {
      context.handle(
        _artworkBlobMeta,
        artworkBlob.isAcceptableOrUnknown(
          data['artwork_blob']!,
          _artworkBlobMeta,
        ),
      );
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    }
    if (data.containsKey('is_missing')) {
      context.handle(
        _isMissingMeta,
        isMissing.isAcceptableOrUnknown(data['is_missing']!, _isMissingMeta),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {fingerprint},
  ];
  @override
  LocalTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTrack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
      uriKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri_kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      artworkBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}artwork_blob'],
      ),
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified_at'],
      ),
      isMissing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_missing'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $LocalTracksTable createAlias(String alias) {
    return $LocalTracksTable(attachedDatabase, alias);
  }
}

class LocalTrack extends DataClass implements Insertable<LocalTrack> {
  final String id;
  final String uri;
  final String uriKind;
  final String title;
  final String? artist;
  final String? album;
  final int? durationMs;
  final int? sizeBytes;
  final String? genre;
  final String fingerprint;
  final Uint8List? artworkBlob;
  final DateTime? modifiedAt;
  final bool isMissing;
  final DateTime importedAt;
  const LocalTrack({
    required this.id,
    required this.uri,
    required this.uriKind,
    required this.title,
    this.artist,
    this.album,
    this.durationMs,
    this.sizeBytes,
    this.genre,
    required this.fingerprint,
    this.artworkBlob,
    this.modifiedAt,
    required this.isMissing,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['uri'] = Variable<String>(uri);
    map['uri_kind'] = Variable<String>(uriKind);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    map['fingerprint'] = Variable<String>(fingerprint);
    if (!nullToAbsent || artworkBlob != null) {
      map['artwork_blob'] = Variable<Uint8List>(artworkBlob);
    }
    if (!nullToAbsent || modifiedAt != null) {
      map['modified_at'] = Variable<DateTime>(modifiedAt);
    }
    map['is_missing'] = Variable<bool>(isMissing);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  LocalTracksCompanion toCompanion(bool nullToAbsent) {
    return LocalTracksCompanion(
      id: Value(id),
      uri: Value(uri),
      uriKind: Value(uriKind),
      title: Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      fingerprint: Value(fingerprint),
      artworkBlob: artworkBlob == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkBlob),
      modifiedAt: modifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedAt),
      isMissing: Value(isMissing),
      importedAt: Value(importedAt),
    );
  }

  factory LocalTrack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTrack(
      id: serializer.fromJson<String>(json['id']),
      uri: serializer.fromJson<String>(json['uri']),
      uriKind: serializer.fromJson<String>(json['uriKind']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      genre: serializer.fromJson<String?>(json['genre']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      artworkBlob: serializer.fromJson<Uint8List?>(json['artworkBlob']),
      modifiedAt: serializer.fromJson<DateTime?>(json['modifiedAt']),
      isMissing: serializer.fromJson<bool>(json['isMissing']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'uri': serializer.toJson<String>(uri),
      'uriKind': serializer.toJson<String>(uriKind),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'durationMs': serializer.toJson<int?>(durationMs),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'genre': serializer.toJson<String?>(genre),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'artworkBlob': serializer.toJson<Uint8List?>(artworkBlob),
      'modifiedAt': serializer.toJson<DateTime?>(modifiedAt),
      'isMissing': serializer.toJson<bool>(isMissing),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  LocalTrack copyWith({
    String? id,
    String? uri,
    String? uriKind,
    String? title,
    Value<String?> artist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<int?> sizeBytes = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    String? fingerprint,
    Value<Uint8List?> artworkBlob = const Value.absent(),
    Value<DateTime?> modifiedAt = const Value.absent(),
    bool? isMissing,
    DateTime? importedAt,
  }) => LocalTrack(
    id: id ?? this.id,
    uri: uri ?? this.uri,
    uriKind: uriKind ?? this.uriKind,
    title: title ?? this.title,
    artist: artist.present ? artist.value : this.artist,
    album: album.present ? album.value : this.album,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    genre: genre.present ? genre.value : this.genre,
    fingerprint: fingerprint ?? this.fingerprint,
    artworkBlob: artworkBlob.present ? artworkBlob.value : this.artworkBlob,
    modifiedAt: modifiedAt.present ? modifiedAt.value : this.modifiedAt,
    isMissing: isMissing ?? this.isMissing,
    importedAt: importedAt ?? this.importedAt,
  );
  LocalTrack copyWithCompanion(LocalTracksCompanion data) {
    return LocalTrack(
      id: data.id.present ? data.id.value : this.id,
      uri: data.uri.present ? data.uri.value : this.uri,
      uriKind: data.uriKind.present ? data.uriKind.value : this.uriKind,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      genre: data.genre.present ? data.genre.value : this.genre,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      artworkBlob: data.artworkBlob.present
          ? data.artworkBlob.value
          : this.artworkBlob,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      isMissing: data.isMissing.present ? data.isMissing.value : this.isMissing,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTrack(')
          ..write('id: $id, ')
          ..write('uri: $uri, ')
          ..write('uriKind: $uriKind, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('genre: $genre, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('artworkBlob: $artworkBlob, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('isMissing: $isMissing, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uri,
    uriKind,
    title,
    artist,
    album,
    durationMs,
    sizeBytes,
    genre,
    fingerprint,
    $driftBlobEquality.hash(artworkBlob),
    modifiedAt,
    isMissing,
    importedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTrack &&
          other.id == this.id &&
          other.uri == this.uri &&
          other.uriKind == this.uriKind &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.durationMs == this.durationMs &&
          other.sizeBytes == this.sizeBytes &&
          other.genre == this.genre &&
          other.fingerprint == this.fingerprint &&
          $driftBlobEquality.equals(other.artworkBlob, this.artworkBlob) &&
          other.modifiedAt == this.modifiedAt &&
          other.isMissing == this.isMissing &&
          other.importedAt == this.importedAt);
}

class LocalTracksCompanion extends UpdateCompanion<LocalTrack> {
  final Value<String> id;
  final Value<String> uri;
  final Value<String> uriKind;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<int?> durationMs;
  final Value<int?> sizeBytes;
  final Value<String?> genre;
  final Value<String> fingerprint;
  final Value<Uint8List?> artworkBlob;
  final Value<DateTime?> modifiedAt;
  final Value<bool> isMissing;
  final Value<DateTime> importedAt;
  final Value<int> rowid;
  const LocalTracksCompanion({
    this.id = const Value.absent(),
    this.uri = const Value.absent(),
    this.uriKind = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.genre = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.artworkBlob = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.isMissing = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTracksCompanion.insert({
    required String id,
    required String uri,
    required String uriKind,
    required String title,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.genre = const Value.absent(),
    required String fingerprint,
    this.artworkBlob = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.isMissing = const Value.absent(),
    required DateTime importedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       uri = Value(uri),
       uriKind = Value(uriKind),
       title = Value(title),
       fingerprint = Value(fingerprint),
       importedAt = Value(importedAt);
  static Insertable<LocalTrack> custom({
    Expression<String>? id,
    Expression<String>? uri,
    Expression<String>? uriKind,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<int>? durationMs,
    Expression<int>? sizeBytes,
    Expression<String>? genre,
    Expression<String>? fingerprint,
    Expression<Uint8List>? artworkBlob,
    Expression<DateTime>? modifiedAt,
    Expression<bool>? isMissing,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uri != null) 'uri': uri,
      if (uriKind != null) 'uri_kind': uriKind,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (durationMs != null) 'duration_ms': durationMs,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (genre != null) 'genre': genre,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (artworkBlob != null) 'artwork_blob': artworkBlob,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (isMissing != null) 'is_missing': isMissing,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTracksCompanion copyWith({
    Value<String>? id,
    Value<String>? uri,
    Value<String>? uriKind,
    Value<String>? title,
    Value<String?>? artist,
    Value<String?>? album,
    Value<int?>? durationMs,
    Value<int?>? sizeBytes,
    Value<String?>? genre,
    Value<String>? fingerprint,
    Value<Uint8List?>? artworkBlob,
    Value<DateTime?>? modifiedAt,
    Value<bool>? isMissing,
    Value<DateTime>? importedAt,
    Value<int>? rowid,
  }) {
    return LocalTracksCompanion(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      uriKind: uriKind ?? this.uriKind,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      genre: genre ?? this.genre,
      fingerprint: fingerprint ?? this.fingerprint,
      artworkBlob: artworkBlob ?? this.artworkBlob,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      isMissing: isMissing ?? this.isMissing,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (uriKind.present) {
      map['uri_kind'] = Variable<String>(uriKind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (artworkBlob.present) {
      map['artwork_blob'] = Variable<Uint8List>(artworkBlob.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    if (isMissing.present) {
      map['is_missing'] = Variable<bool>(isMissing.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTracksCompanion(')
          ..write('id: $id, ')
          ..write('uri: $uri, ')
          ..write('uriKind: $uriKind, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('genre: $genre, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('artworkBlob: $artworkBlob, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('isMissing: $isMissing, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    createdAt,
    updatedAt,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<Playlist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sortOrder;
  const Playlist({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory Playlist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Playlist copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) => Playlist(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, createdAt, updatedAt, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sortOrder == this.sortOrder);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Playlist> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistEntriesTable extends PlaylistEntries
    with TableInfo<$PlaylistEntriesTable, PlaylistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _stableTrackIdMeta = const VerificationMeta(
    'stableTrackId',
  );
  @override
  late final GeneratedColumn<String> stableTrackId = GeneratedColumn<String>(
    'stable_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fallbackTitleMeta = const VerificationMeta(
    'fallbackTitle',
  );
  @override
  late final GeneratedColumn<String> fallbackTitle = GeneratedColumn<String>(
    'fallback_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fallbackArtistMeta = const VerificationMeta(
    'fallbackArtist',
  );
  @override
  late final GeneratedColumn<String> fallbackArtist = GeneratedColumn<String>(
    'fallback_artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fallbackDurationMsMeta =
      const VerificationMeta('fallbackDurationMs');
  @override
  late final GeneratedColumn<int> fallbackDurationMs = GeneratedColumn<int>(
    'fallback_duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playlistId,
    stableTrackId,
    sourceType,
    sourceId,
    ordinal,
    addedAt,
    fallbackTitle,
    fallbackArtist,
    fallbackDurationMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('stable_track_id')) {
      context.handle(
        _stableTrackIdMeta,
        stableTrackId.isAcceptableOrUnknown(
          data['stable_track_id']!,
          _stableTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stableTrackIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('fallback_title')) {
      context.handle(
        _fallbackTitleMeta,
        fallbackTitle.isAcceptableOrUnknown(
          data['fallback_title']!,
          _fallbackTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fallbackTitleMeta);
    }
    if (data.containsKey('fallback_artist')) {
      context.handle(
        _fallbackArtistMeta,
        fallbackArtist.isAcceptableOrUnknown(
          data['fallback_artist']!,
          _fallbackArtistMeta,
        ),
      );
    }
    if (data.containsKey('fallback_duration_ms')) {
      context.handle(
        _fallbackDurationMsMeta,
        fallbackDurationMs.isAcceptableOrUnknown(
          data['fallback_duration_ms']!,
          _fallbackDurationMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      stableTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_track_id'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      fallbackTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fallback_title'],
      )!,
      fallbackArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fallback_artist'],
      ),
      fallbackDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fallback_duration_ms'],
      ),
    );
  }

  @override
  $PlaylistEntriesTable createAlias(String alias) {
    return $PlaylistEntriesTable(attachedDatabase, alias);
  }
}

class PlaylistEntry extends DataClass implements Insertable<PlaylistEntry> {
  final String id;
  final String playlistId;
  final String stableTrackId;
  final String sourceType;
  final String sourceId;
  final int ordinal;
  final DateTime addedAt;
  final String fallbackTitle;
  final String? fallbackArtist;
  final int? fallbackDurationMs;
  const PlaylistEntry({
    required this.id,
    required this.playlistId,
    required this.stableTrackId,
    required this.sourceType,
    required this.sourceId,
    required this.ordinal,
    required this.addedAt,
    required this.fallbackTitle,
    this.fallbackArtist,
    this.fallbackDurationMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['playlist_id'] = Variable<String>(playlistId);
    map['stable_track_id'] = Variable<String>(stableTrackId);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['ordinal'] = Variable<int>(ordinal);
    map['added_at'] = Variable<DateTime>(addedAt);
    map['fallback_title'] = Variable<String>(fallbackTitle);
    if (!nullToAbsent || fallbackArtist != null) {
      map['fallback_artist'] = Variable<String>(fallbackArtist);
    }
    if (!nullToAbsent || fallbackDurationMs != null) {
      map['fallback_duration_ms'] = Variable<int>(fallbackDurationMs);
    }
    return map;
  }

  PlaylistEntriesCompanion toCompanion(bool nullToAbsent) {
    return PlaylistEntriesCompanion(
      id: Value(id),
      playlistId: Value(playlistId),
      stableTrackId: Value(stableTrackId),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      ordinal: Value(ordinal),
      addedAt: Value(addedAt),
      fallbackTitle: Value(fallbackTitle),
      fallbackArtist: fallbackArtist == null && nullToAbsent
          ? const Value.absent()
          : Value(fallbackArtist),
      fallbackDurationMs: fallbackDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(fallbackDurationMs),
    );
  }

  factory PlaylistEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistEntry(
      id: serializer.fromJson<String>(json['id']),
      playlistId: serializer.fromJson<String>(json['playlistId']),
      stableTrackId: serializer.fromJson<String>(json['stableTrackId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      fallbackTitle: serializer.fromJson<String>(json['fallbackTitle']),
      fallbackArtist: serializer.fromJson<String?>(json['fallbackArtist']),
      fallbackDurationMs: serializer.fromJson<int?>(json['fallbackDurationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'playlistId': serializer.toJson<String>(playlistId),
      'stableTrackId': serializer.toJson<String>(stableTrackId),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'ordinal': serializer.toJson<int>(ordinal),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'fallbackTitle': serializer.toJson<String>(fallbackTitle),
      'fallbackArtist': serializer.toJson<String?>(fallbackArtist),
      'fallbackDurationMs': serializer.toJson<int?>(fallbackDurationMs),
    };
  }

  PlaylistEntry copyWith({
    String? id,
    String? playlistId,
    String? stableTrackId,
    String? sourceType,
    String? sourceId,
    int? ordinal,
    DateTime? addedAt,
    String? fallbackTitle,
    Value<String?> fallbackArtist = const Value.absent(),
    Value<int?> fallbackDurationMs = const Value.absent(),
  }) => PlaylistEntry(
    id: id ?? this.id,
    playlistId: playlistId ?? this.playlistId,
    stableTrackId: stableTrackId ?? this.stableTrackId,
    sourceType: sourceType ?? this.sourceType,
    sourceId: sourceId ?? this.sourceId,
    ordinal: ordinal ?? this.ordinal,
    addedAt: addedAt ?? this.addedAt,
    fallbackTitle: fallbackTitle ?? this.fallbackTitle,
    fallbackArtist: fallbackArtist.present
        ? fallbackArtist.value
        : this.fallbackArtist,
    fallbackDurationMs: fallbackDurationMs.present
        ? fallbackDurationMs.value
        : this.fallbackDurationMs,
  );
  PlaylistEntry copyWithCompanion(PlaylistEntriesCompanion data) {
    return PlaylistEntry(
      id: data.id.present ? data.id.value : this.id,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      stableTrackId: data.stableTrackId.present
          ? data.stableTrackId.value
          : this.stableTrackId,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      fallbackTitle: data.fallbackTitle.present
          ? data.fallbackTitle.value
          : this.fallbackTitle,
      fallbackArtist: data.fallbackArtist.present
          ? data.fallbackArtist.value
          : this.fallbackArtist,
      fallbackDurationMs: data.fallbackDurationMs.present
          ? data.fallbackDurationMs.value
          : this.fallbackDurationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntry(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('stableTrackId: $stableTrackId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('ordinal: $ordinal, ')
          ..write('addedAt: $addedAt, ')
          ..write('fallbackTitle: $fallbackTitle, ')
          ..write('fallbackArtist: $fallbackArtist, ')
          ..write('fallbackDurationMs: $fallbackDurationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    playlistId,
    stableTrackId,
    sourceType,
    sourceId,
    ordinal,
    addedAt,
    fallbackTitle,
    fallbackArtist,
    fallbackDurationMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistEntry &&
          other.id == this.id &&
          other.playlistId == this.playlistId &&
          other.stableTrackId == this.stableTrackId &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.ordinal == this.ordinal &&
          other.addedAt == this.addedAt &&
          other.fallbackTitle == this.fallbackTitle &&
          other.fallbackArtist == this.fallbackArtist &&
          other.fallbackDurationMs == this.fallbackDurationMs);
}

class PlaylistEntriesCompanion extends UpdateCompanion<PlaylistEntry> {
  final Value<String> id;
  final Value<String> playlistId;
  final Value<String> stableTrackId;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<int> ordinal;
  final Value<DateTime> addedAt;
  final Value<String> fallbackTitle;
  final Value<String?> fallbackArtist;
  final Value<int?> fallbackDurationMs;
  final Value<int> rowid;
  const PlaylistEntriesCompanion({
    this.id = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.stableTrackId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.fallbackTitle = const Value.absent(),
    this.fallbackArtist = const Value.absent(),
    this.fallbackDurationMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistEntriesCompanion.insert({
    required String id,
    required String playlistId,
    required String stableTrackId,
    required String sourceType,
    required String sourceId,
    required int ordinal,
    required DateTime addedAt,
    required String fallbackTitle,
    this.fallbackArtist = const Value.absent(),
    this.fallbackDurationMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       playlistId = Value(playlistId),
       stableTrackId = Value(stableTrackId),
       sourceType = Value(sourceType),
       sourceId = Value(sourceId),
       ordinal = Value(ordinal),
       addedAt = Value(addedAt),
       fallbackTitle = Value(fallbackTitle);
  static Insertable<PlaylistEntry> custom({
    Expression<String>? id,
    Expression<String>? playlistId,
    Expression<String>? stableTrackId,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<int>? ordinal,
    Expression<DateTime>? addedAt,
    Expression<String>? fallbackTitle,
    Expression<String>? fallbackArtist,
    Expression<int>? fallbackDurationMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistId != null) 'playlist_id': playlistId,
      if (stableTrackId != null) 'stable_track_id': stableTrackId,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (ordinal != null) 'ordinal': ordinal,
      if (addedAt != null) 'added_at': addedAt,
      if (fallbackTitle != null) 'fallback_title': fallbackTitle,
      if (fallbackArtist != null) 'fallback_artist': fallbackArtist,
      if (fallbackDurationMs != null)
        'fallback_duration_ms': fallbackDurationMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? playlistId,
    Value<String>? stableTrackId,
    Value<String>? sourceType,
    Value<String>? sourceId,
    Value<int>? ordinal,
    Value<DateTime>? addedAt,
    Value<String>? fallbackTitle,
    Value<String?>? fallbackArtist,
    Value<int?>? fallbackDurationMs,
    Value<int>? rowid,
  }) {
    return PlaylistEntriesCompanion(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      stableTrackId: stableTrackId ?? this.stableTrackId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      ordinal: ordinal ?? this.ordinal,
      addedAt: addedAt ?? this.addedAt,
      fallbackTitle: fallbackTitle ?? this.fallbackTitle,
      fallbackArtist: fallbackArtist ?? this.fallbackArtist,
      fallbackDurationMs: fallbackDurationMs ?? this.fallbackDurationMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (stableTrackId.present) {
      map['stable_track_id'] = Variable<String>(stableTrackId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (fallbackTitle.present) {
      map['fallback_title'] = Variable<String>(fallbackTitle.value);
    }
    if (fallbackArtist.present) {
      map['fallback_artist'] = Variable<String>(fallbackArtist.value);
    }
    if (fallbackDurationMs.present) {
      map['fallback_duration_ms'] = Variable<int>(fallbackDurationMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntriesCompanion(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('stableTrackId: $stableTrackId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('ordinal: $ordinal, ')
          ..write('addedAt: $addedAt, ')
          ..write('fallbackTitle: $fallbackTitle, ')
          ..write('fallbackArtist: $fallbackArtist, ')
          ..write('fallbackDurationMs: $fallbackDurationMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, Favorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Favorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Favorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class Favorite extends DataClass implements Insertable<Favorite> {
  final String id;
  final DateTime addedAt;
  const Favorite({required this.id, required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(id: Value(id), addedAt: Value(addedAt));
  }

  factory Favorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      id: serializer.fromJson<String>(json['id']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  Favorite copyWith({String? id, DateTime? addedAt}) =>
      Favorite(id: id ?? this.id, addedAt: addedAt ?? this.addedAt);
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      id: data.id.present ? data.id.value : this.id,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('id: $id, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Favorite &&
          other.id == this.id &&
          other.addedAt == this.addedAt);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<String> id;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.id = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String id,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       addedAt = Value(addedAt);
  static Insertable<Favorite> custom({
    Expression<String>? id,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      id: id ?? this.id,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('id: $id, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListeningHistoryTable extends ListeningHistory
    with TableInfo<$ListeningHistoryTable, ListeningHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListeningHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _stableTrackIdMeta = const VerificationMeta(
    'stableTrackId',
  );
  @override
  late final GeneratedColumn<String> stableTrackId = GeneratedColumn<String>(
    'stable_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPositionMsMeta = const VerificationMeta(
    'lastPositionMs',
  );
  @override
  late final GeneratedColumn<int> lastPositionMs = GeneratedColumn<int>(
    'last_position_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listenedMsMeta = const VerificationMeta(
    'listenedMs',
  );
  @override
  late final GeneratedColumn<int> listenedMs = GeneratedColumn<int>(
    'listened_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceLocalMeta = const VerificationMeta(
    'deviceLocal',
  );
  @override
  late final GeneratedColumn<bool> deviceLocal = GeneratedColumn<bool>(
    'device_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("device_local" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stableTrackId,
    sourceType,
    startedAt,
    lastPositionMs,
    listenedMs,
    completed,
    deviceLocal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'listening_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListeningHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('stable_track_id')) {
      context.handle(
        _stableTrackIdMeta,
        stableTrackId.isAcceptableOrUnknown(
          data['stable_track_id']!,
          _stableTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stableTrackIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('last_position_ms')) {
      context.handle(
        _lastPositionMsMeta,
        lastPositionMs.isAcceptableOrUnknown(
          data['last_position_ms']!,
          _lastPositionMsMeta,
        ),
      );
    }
    if (data.containsKey('listened_ms')) {
      context.handle(
        _listenedMsMeta,
        listenedMs.isAcceptableOrUnknown(data['listened_ms']!, _listenedMsMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('device_local')) {
      context.handle(
        _deviceLocalMeta,
        deviceLocal.isAcceptableOrUnknown(
          data['device_local']!,
          _deviceLocalMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListeningHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListeningHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      stableTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_track_id'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      lastPositionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_position_ms'],
      ),
      listenedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}listened_ms'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      deviceLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}device_local'],
      )!,
    );
  }

  @override
  $ListeningHistoryTable createAlias(String alias) {
    return $ListeningHistoryTable(attachedDatabase, alias);
  }
}

class ListeningHistoryData extends DataClass
    implements Insertable<ListeningHistoryData> {
  final int id;
  final String stableTrackId;
  final String sourceType;
  final DateTime startedAt;
  final int? lastPositionMs;
  final int listenedMs;
  final bool completed;
  final bool deviceLocal;
  const ListeningHistoryData({
    required this.id,
    required this.stableTrackId,
    required this.sourceType,
    required this.startedAt,
    this.lastPositionMs,
    required this.listenedMs,
    required this.completed,
    required this.deviceLocal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['stable_track_id'] = Variable<String>(stableTrackId);
    map['source_type'] = Variable<String>(sourceType);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || lastPositionMs != null) {
      map['last_position_ms'] = Variable<int>(lastPositionMs);
    }
    map['listened_ms'] = Variable<int>(listenedMs);
    map['completed'] = Variable<bool>(completed);
    map['device_local'] = Variable<bool>(deviceLocal);
    return map;
  }

  ListeningHistoryCompanion toCompanion(bool nullToAbsent) {
    return ListeningHistoryCompanion(
      id: Value(id),
      stableTrackId: Value(stableTrackId),
      sourceType: Value(sourceType),
      startedAt: Value(startedAt),
      lastPositionMs: lastPositionMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPositionMs),
      listenedMs: Value(listenedMs),
      completed: Value(completed),
      deviceLocal: Value(deviceLocal),
    );
  }

  factory ListeningHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListeningHistoryData(
      id: serializer.fromJson<int>(json['id']),
      stableTrackId: serializer.fromJson<String>(json['stableTrackId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      lastPositionMs: serializer.fromJson<int?>(json['lastPositionMs']),
      listenedMs: serializer.fromJson<int>(json['listenedMs']),
      completed: serializer.fromJson<bool>(json['completed']),
      deviceLocal: serializer.fromJson<bool>(json['deviceLocal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'stableTrackId': serializer.toJson<String>(stableTrackId),
      'sourceType': serializer.toJson<String>(sourceType),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'lastPositionMs': serializer.toJson<int?>(lastPositionMs),
      'listenedMs': serializer.toJson<int>(listenedMs),
      'completed': serializer.toJson<bool>(completed),
      'deviceLocal': serializer.toJson<bool>(deviceLocal),
    };
  }

  ListeningHistoryData copyWith({
    int? id,
    String? stableTrackId,
    String? sourceType,
    DateTime? startedAt,
    Value<int?> lastPositionMs = const Value.absent(),
    int? listenedMs,
    bool? completed,
    bool? deviceLocal,
  }) => ListeningHistoryData(
    id: id ?? this.id,
    stableTrackId: stableTrackId ?? this.stableTrackId,
    sourceType: sourceType ?? this.sourceType,
    startedAt: startedAt ?? this.startedAt,
    lastPositionMs: lastPositionMs.present
        ? lastPositionMs.value
        : this.lastPositionMs,
    listenedMs: listenedMs ?? this.listenedMs,
    completed: completed ?? this.completed,
    deviceLocal: deviceLocal ?? this.deviceLocal,
  );
  ListeningHistoryData copyWithCompanion(ListeningHistoryCompanion data) {
    return ListeningHistoryData(
      id: data.id.present ? data.id.value : this.id,
      stableTrackId: data.stableTrackId.present
          ? data.stableTrackId.value
          : this.stableTrackId,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      lastPositionMs: data.lastPositionMs.present
          ? data.lastPositionMs.value
          : this.lastPositionMs,
      listenedMs: data.listenedMs.present
          ? data.listenedMs.value
          : this.listenedMs,
      completed: data.completed.present ? data.completed.value : this.completed,
      deviceLocal: data.deviceLocal.present
          ? data.deviceLocal.value
          : this.deviceLocal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListeningHistoryData(')
          ..write('id: $id, ')
          ..write('stableTrackId: $stableTrackId, ')
          ..write('sourceType: $sourceType, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('listenedMs: $listenedMs, ')
          ..write('completed: $completed, ')
          ..write('deviceLocal: $deviceLocal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    stableTrackId,
    sourceType,
    startedAt,
    lastPositionMs,
    listenedMs,
    completed,
    deviceLocal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListeningHistoryData &&
          other.id == this.id &&
          other.stableTrackId == this.stableTrackId &&
          other.sourceType == this.sourceType &&
          other.startedAt == this.startedAt &&
          other.lastPositionMs == this.lastPositionMs &&
          other.listenedMs == this.listenedMs &&
          other.completed == this.completed &&
          other.deviceLocal == this.deviceLocal);
}

class ListeningHistoryCompanion extends UpdateCompanion<ListeningHistoryData> {
  final Value<int> id;
  final Value<String> stableTrackId;
  final Value<String> sourceType;
  final Value<DateTime> startedAt;
  final Value<int?> lastPositionMs;
  final Value<int> listenedMs;
  final Value<bool> completed;
  final Value<bool> deviceLocal;
  const ListeningHistoryCompanion({
    this.id = const Value.absent(),
    this.stableTrackId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastPositionMs = const Value.absent(),
    this.listenedMs = const Value.absent(),
    this.completed = const Value.absent(),
    this.deviceLocal = const Value.absent(),
  });
  ListeningHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String stableTrackId,
    required String sourceType,
    required DateTime startedAt,
    this.lastPositionMs = const Value.absent(),
    this.listenedMs = const Value.absent(),
    this.completed = const Value.absent(),
    this.deviceLocal = const Value.absent(),
  }) : stableTrackId = Value(stableTrackId),
       sourceType = Value(sourceType),
       startedAt = Value(startedAt);
  static Insertable<ListeningHistoryData> custom({
    Expression<int>? id,
    Expression<String>? stableTrackId,
    Expression<String>? sourceType,
    Expression<DateTime>? startedAt,
    Expression<int>? lastPositionMs,
    Expression<int>? listenedMs,
    Expression<bool>? completed,
    Expression<bool>? deviceLocal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stableTrackId != null) 'stable_track_id': stableTrackId,
      if (sourceType != null) 'source_type': sourceType,
      if (startedAt != null) 'started_at': startedAt,
      if (lastPositionMs != null) 'last_position_ms': lastPositionMs,
      if (listenedMs != null) 'listened_ms': listenedMs,
      if (completed != null) 'completed': completed,
      if (deviceLocal != null) 'device_local': deviceLocal,
    });
  }

  ListeningHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? stableTrackId,
    Value<String>? sourceType,
    Value<DateTime>? startedAt,
    Value<int?>? lastPositionMs,
    Value<int>? listenedMs,
    Value<bool>? completed,
    Value<bool>? deviceLocal,
  }) {
    return ListeningHistoryCompanion(
      id: id ?? this.id,
      stableTrackId: stableTrackId ?? this.stableTrackId,
      sourceType: sourceType ?? this.sourceType,
      startedAt: startedAt ?? this.startedAt,
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
      listenedMs: listenedMs ?? this.listenedMs,
      completed: completed ?? this.completed,
      deviceLocal: deviceLocal ?? this.deviceLocal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (stableTrackId.present) {
      map['stable_track_id'] = Variable<String>(stableTrackId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (lastPositionMs.present) {
      map['last_position_ms'] = Variable<int>(lastPositionMs.value);
    }
    if (listenedMs.present) {
      map['listened_ms'] = Variable<int>(listenedMs.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (deviceLocal.present) {
      map['device_local'] = Variable<bool>(deviceLocal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListeningHistoryCompanion(')
          ..write('id: $id, ')
          ..write('stableTrackId: $stableTrackId, ')
          ..write('sourceType: $sourceType, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('listenedMs: $listenedMs, ')
          ..write('completed: $completed, ')
          ..write('deviceLocal: $deviceLocal')
          ..write(')'))
        .toString();
  }
}

class $RecentSearchesTable extends RecentSearches
    with TableInfo<$RecentSearchesTable, RecentSearche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, query, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_searches';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentSearche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {query},
  ];
  @override
  RecentSearche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSearche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $RecentSearchesTable createAlias(String alias) {
    return $RecentSearchesTable(attachedDatabase, alias);
  }
}

class RecentSearche extends DataClass implements Insertable<RecentSearche> {
  final int id;
  final String query;
  final DateTime at;
  const RecentSearche({
    required this.id,
    required this.query,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  RecentSearchesCompanion toCompanion(bool nullToAbsent) {
    return RecentSearchesCompanion(
      id: Value(id),
      query: Value(query),
      at: Value(at),
    );
  }

  factory RecentSearche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSearche(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  RecentSearche copyWith({int? id, String? query, DateTime? at}) =>
      RecentSearche(
        id: id ?? this.id,
        query: query ?? this.query,
        at: at ?? this.at,
      );
  RecentSearche copyWithCompanion(RecentSearchesCompanion data) {
    return RecentSearche(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearche(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSearche &&
          other.id == this.id &&
          other.query == this.query &&
          other.at == this.at);
}

class RecentSearchesCompanion extends UpdateCompanion<RecentSearche> {
  final Value<int> id;
  final Value<String> query;
  final Value<DateTime> at;
  const RecentSearchesCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.at = const Value.absent(),
  });
  RecentSearchesCompanion.insert({
    this.id = const Value.absent(),
    required String query,
    required DateTime at,
  }) : query = Value(query),
       at = Value(at);
  static Insertable<RecentSearche> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<DateTime>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (at != null) 'at': at,
    });
  }

  RecentSearchesCompanion copyWith({
    Value<int>? id,
    Value<String>? query,
    Value<DateTime>? at,
  }) {
    return RecentSearchesCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchesCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $DownloadJobsTable extends DownloadJobs
    with TableInfo<$DownloadJobsTable, DownloadJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stableTrackIdMeta = const VerificationMeta(
    'stableTrackId',
  );
  @override
  late final GeneratedColumn<String> stableTrackId = GeneratedColumn<String>(
    'stable_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetPathMeta = const VerificationMeta(
    'targetPath',
  );
  @override
  late final GeneratedColumn<String> targetPath = GeneratedColumn<String>(
    'target_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tempPathMeta = const VerificationMeta(
    'tempPath',
  );
  @override
  late final GeneratedColumn<String> tempPath = GeneratedColumn<String>(
    'temp_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesTotalMeta = const VerificationMeta(
    'bytesTotal',
  );
  @override
  late final GeneratedColumn<int> bytesTotal = GeneratedColumn<int>(
    'bytes_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bytesWrittenMeta = const VerificationMeta(
    'bytesWritten',
  );
  @override
  late final GeneratedColumn<int> bytesWritten = GeneratedColumn<int>(
    'bytes_written',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _canResumeMeta = const VerificationMeta(
    'canResume',
  );
  @override
  late final GeneratedColumn<bool> canResume = GeneratedColumn<bool>(
    'can_resume',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_resume" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _permissionProofMeta = const VerificationMeta(
    'permissionProof',
  );
  @override
  late final GeneratedColumn<String> permissionProof = GeneratedColumn<String>(
    'permission_proof',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stableTrackId,
    provider,
    title,
    artist,
    targetPath,
    tempPath,
    bytesTotal,
    bytesWritten,
    state,
    errorCode,
    attemptCount,
    canResume,
    permissionProof,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('stable_track_id')) {
      context.handle(
        _stableTrackIdMeta,
        stableTrackId.isAcceptableOrUnknown(
          data['stable_track_id']!,
          _stableTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stableTrackIdMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('target_path')) {
      context.handle(
        _targetPathMeta,
        targetPath.isAcceptableOrUnknown(data['target_path']!, _targetPathMeta),
      );
    } else if (isInserting) {
      context.missing(_targetPathMeta);
    }
    if (data.containsKey('temp_path')) {
      context.handle(
        _tempPathMeta,
        tempPath.isAcceptableOrUnknown(data['temp_path']!, _tempPathMeta),
      );
    } else if (isInserting) {
      context.missing(_tempPathMeta);
    }
    if (data.containsKey('bytes_total')) {
      context.handle(
        _bytesTotalMeta,
        bytesTotal.isAcceptableOrUnknown(data['bytes_total']!, _bytesTotalMeta),
      );
    }
    if (data.containsKey('bytes_written')) {
      context.handle(
        _bytesWrittenMeta,
        bytesWritten.isAcceptableOrUnknown(
          data['bytes_written']!,
          _bytesWrittenMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('can_resume')) {
      context.handle(
        _canResumeMeta,
        canResume.isAcceptableOrUnknown(data['can_resume']!, _canResumeMeta),
      );
    }
    if (data.containsKey('permission_proof')) {
      context.handle(
        _permissionProofMeta,
        permissionProof.isAcceptableOrUnknown(
          data['permission_proof']!,
          _permissionProofMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_permissionProofMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      stableTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_track_id'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      targetPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_path'],
      )!,
      tempPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}temp_path'],
      )!,
      bytesTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_total'],
      ),
      bytesWritten: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_written'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      canResume: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_resume'],
      )!,
      permissionProof: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permission_proof'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DownloadJobsTable createAlias(String alias) {
    return $DownloadJobsTable(attachedDatabase, alias);
  }
}

class DownloadJob extends DataClass implements Insertable<DownloadJob> {
  final String id;
  final String stableTrackId;
  final String provider;
  final String title;
  final String? artist;
  final String targetPath;
  final String tempPath;
  final int? bytesTotal;
  final int bytesWritten;
  final String state;
  final String? errorCode;
  final int attemptCount;
  final bool canResume;
  final String permissionProof;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DownloadJob({
    required this.id,
    required this.stableTrackId,
    required this.provider,
    required this.title,
    this.artist,
    required this.targetPath,
    required this.tempPath,
    this.bytesTotal,
    required this.bytesWritten,
    required this.state,
    this.errorCode,
    required this.attemptCount,
    required this.canResume,
    required this.permissionProof,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['stable_track_id'] = Variable<String>(stableTrackId);
    map['provider'] = Variable<String>(provider);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    map['target_path'] = Variable<String>(targetPath);
    map['temp_path'] = Variable<String>(tempPath);
    if (!nullToAbsent || bytesTotal != null) {
      map['bytes_total'] = Variable<int>(bytesTotal);
    }
    map['bytes_written'] = Variable<int>(bytesWritten);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    map['attempt_count'] = Variable<int>(attemptCount);
    map['can_resume'] = Variable<bool>(canResume);
    map['permission_proof'] = Variable<String>(permissionProof);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DownloadJobsCompanion toCompanion(bool nullToAbsent) {
    return DownloadJobsCompanion(
      id: Value(id),
      stableTrackId: Value(stableTrackId),
      provider: Value(provider),
      title: Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      targetPath: Value(targetPath),
      tempPath: Value(tempPath),
      bytesTotal: bytesTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(bytesTotal),
      bytesWritten: Value(bytesWritten),
      state: Value(state),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      attemptCount: Value(attemptCount),
      canResume: Value(canResume),
      permissionProof: Value(permissionProof),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadJob(
      id: serializer.fromJson<String>(json['id']),
      stableTrackId: serializer.fromJson<String>(json['stableTrackId']),
      provider: serializer.fromJson<String>(json['provider']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      targetPath: serializer.fromJson<String>(json['targetPath']),
      tempPath: serializer.fromJson<String>(json['tempPath']),
      bytesTotal: serializer.fromJson<int?>(json['bytesTotal']),
      bytesWritten: serializer.fromJson<int>(json['bytesWritten']),
      state: serializer.fromJson<String>(json['state']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      canResume: serializer.fromJson<bool>(json['canResume']),
      permissionProof: serializer.fromJson<String>(json['permissionProof']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'stableTrackId': serializer.toJson<String>(stableTrackId),
      'provider': serializer.toJson<String>(provider),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'targetPath': serializer.toJson<String>(targetPath),
      'tempPath': serializer.toJson<String>(tempPath),
      'bytesTotal': serializer.toJson<int?>(bytesTotal),
      'bytesWritten': serializer.toJson<int>(bytesWritten),
      'state': serializer.toJson<String>(state),
      'errorCode': serializer.toJson<String?>(errorCode),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'canResume': serializer.toJson<bool>(canResume),
      'permissionProof': serializer.toJson<String>(permissionProof),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DownloadJob copyWith({
    String? id,
    String? stableTrackId,
    String? provider,
    String? title,
    Value<String?> artist = const Value.absent(),
    String? targetPath,
    String? tempPath,
    Value<int?> bytesTotal = const Value.absent(),
    int? bytesWritten,
    String? state,
    Value<String?> errorCode = const Value.absent(),
    int? attemptCount,
    bool? canResume,
    String? permissionProof,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DownloadJob(
    id: id ?? this.id,
    stableTrackId: stableTrackId ?? this.stableTrackId,
    provider: provider ?? this.provider,
    title: title ?? this.title,
    artist: artist.present ? artist.value : this.artist,
    targetPath: targetPath ?? this.targetPath,
    tempPath: tempPath ?? this.tempPath,
    bytesTotal: bytesTotal.present ? bytesTotal.value : this.bytesTotal,
    bytesWritten: bytesWritten ?? this.bytesWritten,
    state: state ?? this.state,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    attemptCount: attemptCount ?? this.attemptCount,
    canResume: canResume ?? this.canResume,
    permissionProof: permissionProof ?? this.permissionProof,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DownloadJob copyWithCompanion(DownloadJobsCompanion data) {
    return DownloadJob(
      id: data.id.present ? data.id.value : this.id,
      stableTrackId: data.stableTrackId.present
          ? data.stableTrackId.value
          : this.stableTrackId,
      provider: data.provider.present ? data.provider.value : this.provider,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      targetPath: data.targetPath.present
          ? data.targetPath.value
          : this.targetPath,
      tempPath: data.tempPath.present ? data.tempPath.value : this.tempPath,
      bytesTotal: data.bytesTotal.present
          ? data.bytesTotal.value
          : this.bytesTotal,
      bytesWritten: data.bytesWritten.present
          ? data.bytesWritten.value
          : this.bytesWritten,
      state: data.state.present ? data.state.value : this.state,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      canResume: data.canResume.present ? data.canResume.value : this.canResume,
      permissionProof: data.permissionProof.present
          ? data.permissionProof.value
          : this.permissionProof,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadJob(')
          ..write('id: $id, ')
          ..write('stableTrackId: $stableTrackId, ')
          ..write('provider: $provider, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('targetPath: $targetPath, ')
          ..write('tempPath: $tempPath, ')
          ..write('bytesTotal: $bytesTotal, ')
          ..write('bytesWritten: $bytesWritten, ')
          ..write('state: $state, ')
          ..write('errorCode: $errorCode, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('canResume: $canResume, ')
          ..write('permissionProof: $permissionProof, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    stableTrackId,
    provider,
    title,
    artist,
    targetPath,
    tempPath,
    bytesTotal,
    bytesWritten,
    state,
    errorCode,
    attemptCount,
    canResume,
    permissionProof,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadJob &&
          other.id == this.id &&
          other.stableTrackId == this.stableTrackId &&
          other.provider == this.provider &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.targetPath == this.targetPath &&
          other.tempPath == this.tempPath &&
          other.bytesTotal == this.bytesTotal &&
          other.bytesWritten == this.bytesWritten &&
          other.state == this.state &&
          other.errorCode == this.errorCode &&
          other.attemptCount == this.attemptCount &&
          other.canResume == this.canResume &&
          other.permissionProof == this.permissionProof &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DownloadJobsCompanion extends UpdateCompanion<DownloadJob> {
  final Value<String> id;
  final Value<String> stableTrackId;
  final Value<String> provider;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String> targetPath;
  final Value<String> tempPath;
  final Value<int?> bytesTotal;
  final Value<int> bytesWritten;
  final Value<String> state;
  final Value<String?> errorCode;
  final Value<int> attemptCount;
  final Value<bool> canResume;
  final Value<String> permissionProof;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DownloadJobsCompanion({
    this.id = const Value.absent(),
    this.stableTrackId = const Value.absent(),
    this.provider = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.targetPath = const Value.absent(),
    this.tempPath = const Value.absent(),
    this.bytesTotal = const Value.absent(),
    this.bytesWritten = const Value.absent(),
    this.state = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.canResume = const Value.absent(),
    this.permissionProof = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadJobsCompanion.insert({
    required String id,
    required String stableTrackId,
    required String provider,
    required String title,
    this.artist = const Value.absent(),
    required String targetPath,
    required String tempPath,
    this.bytesTotal = const Value.absent(),
    this.bytesWritten = const Value.absent(),
    required String state,
    this.errorCode = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.canResume = const Value.absent(),
    required String permissionProof,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       stableTrackId = Value(stableTrackId),
       provider = Value(provider),
       title = Value(title),
       targetPath = Value(targetPath),
       tempPath = Value(tempPath),
       state = Value(state),
       permissionProof = Value(permissionProof),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DownloadJob> custom({
    Expression<String>? id,
    Expression<String>? stableTrackId,
    Expression<String>? provider,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? targetPath,
    Expression<String>? tempPath,
    Expression<int>? bytesTotal,
    Expression<int>? bytesWritten,
    Expression<String>? state,
    Expression<String>? errorCode,
    Expression<int>? attemptCount,
    Expression<bool>? canResume,
    Expression<String>? permissionProof,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stableTrackId != null) 'stable_track_id': stableTrackId,
      if (provider != null) 'provider': provider,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (targetPath != null) 'target_path': targetPath,
      if (tempPath != null) 'temp_path': tempPath,
      if (bytesTotal != null) 'bytes_total': bytesTotal,
      if (bytesWritten != null) 'bytes_written': bytesWritten,
      if (state != null) 'state': state,
      if (errorCode != null) 'error_code': errorCode,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (canResume != null) 'can_resume': canResume,
      if (permissionProof != null) 'permission_proof': permissionProof,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadJobsCompanion copyWith({
    Value<String>? id,
    Value<String>? stableTrackId,
    Value<String>? provider,
    Value<String>? title,
    Value<String?>? artist,
    Value<String>? targetPath,
    Value<String>? tempPath,
    Value<int?>? bytesTotal,
    Value<int>? bytesWritten,
    Value<String>? state,
    Value<String?>? errorCode,
    Value<int>? attemptCount,
    Value<bool>? canResume,
    Value<String>? permissionProof,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DownloadJobsCompanion(
      id: id ?? this.id,
      stableTrackId: stableTrackId ?? this.stableTrackId,
      provider: provider ?? this.provider,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      targetPath: targetPath ?? this.targetPath,
      tempPath: tempPath ?? this.tempPath,
      bytesTotal: bytesTotal ?? this.bytesTotal,
      bytesWritten: bytesWritten ?? this.bytesWritten,
      state: state ?? this.state,
      errorCode: errorCode ?? this.errorCode,
      attemptCount: attemptCount ?? this.attemptCount,
      canResume: canResume ?? this.canResume,
      permissionProof: permissionProof ?? this.permissionProof,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (stableTrackId.present) {
      map['stable_track_id'] = Variable<String>(stableTrackId.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (targetPath.present) {
      map['target_path'] = Variable<String>(targetPath.value);
    }
    if (tempPath.present) {
      map['temp_path'] = Variable<String>(tempPath.value);
    }
    if (bytesTotal.present) {
      map['bytes_total'] = Variable<int>(bytesTotal.value);
    }
    if (bytesWritten.present) {
      map['bytes_written'] = Variable<int>(bytesWritten.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (canResume.present) {
      map['can_resume'] = Variable<bool>(canResume.value);
    }
    if (permissionProof.present) {
      map['permission_proof'] = Variable<String>(permissionProof.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadJobsCompanion(')
          ..write('id: $id, ')
          ..write('stableTrackId: $stableTrackId, ')
          ..write('provider: $provider, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('targetPath: $targetPath, ')
          ..write('tempPath: $tempPath, ')
          ..write('bytesTotal: $bytesTotal, ')
          ..write('bytesWritten: $bytesWritten, ')
          ..write('state: $state, ')
          ..write('errorCode: $errorCode, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('canResume: $canResume, ')
          ..write('permissionProof: $permissionProof, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueueMetaTable extends QueueMeta
    with TableInfo<$QueueMetaTable, QueueMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeIndexMeta = const VerificationMeta(
    'activeIndex',
  );
  @override
  late final GeneratedColumn<int> activeIndex = GeneratedColumn<int>(
    'active_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shuffleMeta = const VerificationMeta(
    'shuffle',
  );
  @override
  late final GeneratedColumn<bool> shuffle = GeneratedColumn<bool>(
    'shuffle',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _shuffleSeedMeta = const VerificationMeta(
    'shuffleSeed',
  );
  @override
  late final GeneratedColumn<int> shuffleSeed = GeneratedColumn<int>(
    'shuffle_seed',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatModeMeta = const VerificationMeta(
    'repeatMode',
  );
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
    'repeat_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('off'),
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activeIndex,
    positionMs,
    shuffle,
    shuffleSeed,
    repeatMode,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('active_index')) {
      context.handle(
        _activeIndexMeta,
        activeIndex.isAcceptableOrUnknown(
          data['active_index']!,
          _activeIndexMeta,
        ),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('shuffle')) {
      context.handle(
        _shuffleMeta,
        shuffle.isAcceptableOrUnknown(data['shuffle']!, _shuffleMeta),
      );
    }
    if (data.containsKey('shuffle_seed')) {
      context.handle(
        _shuffleSeedMeta,
        shuffleSeed.isAcceptableOrUnknown(
          data['shuffle_seed']!,
          _shuffleSeedMeta,
        ),
      );
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
        _repeatModeMeta,
        repeatMode.isAcceptableOrUnknown(data['repeat_mode']!, _repeatModeMeta),
      );
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueMetaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      activeIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_index'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      shuffle: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle'],
      )!,
      shuffleSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shuffle_seed'],
      ),
      repeatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_mode'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $QueueMetaTable createAlias(String alias) {
    return $QueueMetaTable(attachedDatabase, alias);
  }
}

class QueueMetaData extends DataClass implements Insertable<QueueMetaData> {
  final int id;
  final int activeIndex;
  final int positionMs;
  final bool shuffle;
  final int? shuffleSeed;
  final String repeatMode;
  final DateTime savedAt;
  const QueueMetaData({
    required this.id,
    required this.activeIndex,
    required this.positionMs,
    required this.shuffle,
    this.shuffleSeed,
    required this.repeatMode,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['active_index'] = Variable<int>(activeIndex);
    map['position_ms'] = Variable<int>(positionMs);
    map['shuffle'] = Variable<bool>(shuffle);
    if (!nullToAbsent || shuffleSeed != null) {
      map['shuffle_seed'] = Variable<int>(shuffleSeed);
    }
    map['repeat_mode'] = Variable<String>(repeatMode);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  QueueMetaCompanion toCompanion(bool nullToAbsent) {
    return QueueMetaCompanion(
      id: Value(id),
      activeIndex: Value(activeIndex),
      positionMs: Value(positionMs),
      shuffle: Value(shuffle),
      shuffleSeed: shuffleSeed == null && nullToAbsent
          ? const Value.absent()
          : Value(shuffleSeed),
      repeatMode: Value(repeatMode),
      savedAt: Value(savedAt),
    );
  }

  factory QueueMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueMetaData(
      id: serializer.fromJson<int>(json['id']),
      activeIndex: serializer.fromJson<int>(json['activeIndex']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      shuffle: serializer.fromJson<bool>(json['shuffle']),
      shuffleSeed: serializer.fromJson<int?>(json['shuffleSeed']),
      repeatMode: serializer.fromJson<String>(json['repeatMode']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activeIndex': serializer.toJson<int>(activeIndex),
      'positionMs': serializer.toJson<int>(positionMs),
      'shuffle': serializer.toJson<bool>(shuffle),
      'shuffleSeed': serializer.toJson<int?>(shuffleSeed),
      'repeatMode': serializer.toJson<String>(repeatMode),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  QueueMetaData copyWith({
    int? id,
    int? activeIndex,
    int? positionMs,
    bool? shuffle,
    Value<int?> shuffleSeed = const Value.absent(),
    String? repeatMode,
    DateTime? savedAt,
  }) => QueueMetaData(
    id: id ?? this.id,
    activeIndex: activeIndex ?? this.activeIndex,
    positionMs: positionMs ?? this.positionMs,
    shuffle: shuffle ?? this.shuffle,
    shuffleSeed: shuffleSeed.present ? shuffleSeed.value : this.shuffleSeed,
    repeatMode: repeatMode ?? this.repeatMode,
    savedAt: savedAt ?? this.savedAt,
  );
  QueueMetaData copyWithCompanion(QueueMetaCompanion data) {
    return QueueMetaData(
      id: data.id.present ? data.id.value : this.id,
      activeIndex: data.activeIndex.present
          ? data.activeIndex.value
          : this.activeIndex,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      shuffle: data.shuffle.present ? data.shuffle.value : this.shuffle,
      shuffleSeed: data.shuffleSeed.present
          ? data.shuffleSeed.value
          : this.shuffleSeed,
      repeatMode: data.repeatMode.present
          ? data.repeatMode.value
          : this.repeatMode,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueMetaData(')
          ..write('id: $id, ')
          ..write('activeIndex: $activeIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('shuffle: $shuffle, ')
          ..write('shuffleSeed: $shuffleSeed, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activeIndex,
    positionMs,
    shuffle,
    shuffleSeed,
    repeatMode,
    savedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueMetaData &&
          other.id == this.id &&
          other.activeIndex == this.activeIndex &&
          other.positionMs == this.positionMs &&
          other.shuffle == this.shuffle &&
          other.shuffleSeed == this.shuffleSeed &&
          other.repeatMode == this.repeatMode &&
          other.savedAt == this.savedAt);
}

class QueueMetaCompanion extends UpdateCompanion<QueueMetaData> {
  final Value<int> id;
  final Value<int> activeIndex;
  final Value<int> positionMs;
  final Value<bool> shuffle;
  final Value<int?> shuffleSeed;
  final Value<String> repeatMode;
  final Value<DateTime> savedAt;
  const QueueMetaCompanion({
    this.id = const Value.absent(),
    this.activeIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.shuffle = const Value.absent(),
    this.shuffleSeed = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  QueueMetaCompanion.insert({
    this.id = const Value.absent(),
    this.activeIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.shuffle = const Value.absent(),
    this.shuffleSeed = const Value.absent(),
    this.repeatMode = const Value.absent(),
    required DateTime savedAt,
  }) : savedAt = Value(savedAt);
  static Insertable<QueueMetaData> custom({
    Expression<int>? id,
    Expression<int>? activeIndex,
    Expression<int>? positionMs,
    Expression<bool>? shuffle,
    Expression<int>? shuffleSeed,
    Expression<String>? repeatMode,
    Expression<DateTime>? savedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activeIndex != null) 'active_index': activeIndex,
      if (positionMs != null) 'position_ms': positionMs,
      if (shuffle != null) 'shuffle': shuffle,
      if (shuffleSeed != null) 'shuffle_seed': shuffleSeed,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (savedAt != null) 'saved_at': savedAt,
    });
  }

  QueueMetaCompanion copyWith({
    Value<int>? id,
    Value<int>? activeIndex,
    Value<int>? positionMs,
    Value<bool>? shuffle,
    Value<int?>? shuffleSeed,
    Value<String>? repeatMode,
    Value<DateTime>? savedAt,
  }) {
    return QueueMetaCompanion(
      id: id ?? this.id,
      activeIndex: activeIndex ?? this.activeIndex,
      positionMs: positionMs ?? this.positionMs,
      shuffle: shuffle ?? this.shuffle,
      shuffleSeed: shuffleSeed ?? this.shuffleSeed,
      repeatMode: repeatMode ?? this.repeatMode,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activeIndex.present) {
      map['active_index'] = Variable<int>(activeIndex.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (shuffle.present) {
      map['shuffle'] = Variable<bool>(shuffle.value);
    }
    if (shuffleSeed.present) {
      map['shuffle_seed'] = Variable<int>(shuffleSeed.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueMetaCompanion(')
          ..write('id: $id, ')
          ..write('activeIndex: $activeIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('shuffle: $shuffle, ')
          ..write('shuffleSeed: $shuffleSeed, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }
}

class $QueueItemsTable extends QueueItems
    with TableInfo<$QueueItemsTable, QueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stableTrackIdMeta = const VerificationMeta(
    'stableTrackId',
  );
  @override
  late final GeneratedColumn<String> stableTrackId = GeneratedColumn<String>(
    'stable_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkUrlMeta = const VerificationMeta(
    'artworkUrl',
  );
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
    'artwork_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUriMeta = const VerificationMeta(
    'localUri',
  );
  @override
  late final GeneratedColumn<String> localUri = GeneratedColumn<String>(
    'local_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ordinal,
    stableTrackId,
    sourceType,
    sourceId,
    title,
    artist,
    artworkUrl,
    durationMs,
    localUri,
    sourceUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('stable_track_id')) {
      context.handle(
        _stableTrackIdMeta,
        stableTrackId.isAcceptableOrUnknown(
          data['stable_track_id']!,
          _stableTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stableTrackIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
        _artworkUrlMeta,
        artworkUrl.isAcceptableOrUnknown(data['artwork_url']!, _artworkUrlMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('local_uri')) {
      context.handle(
        _localUriMeta,
        localUri.isAcceptableOrUnknown(data['local_uri']!, _localUriMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      stableTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_track_id'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      artworkUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_url'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      localUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_uri'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
    );
  }

  @override
  $QueueItemsTable createAlias(String alias) {
    return $QueueItemsTable(attachedDatabase, alias);
  }
}

class QueueItem extends DataClass implements Insertable<QueueItem> {
  final int id;
  final int ordinal;
  final String stableTrackId;
  final String sourceType;
  final String sourceId;
  final String title;
  final String? artist;
  final String? artworkUrl;
  final int? durationMs;
  final String? localUri;
  final String? sourceUrl;
  const QueueItem({
    required this.id,
    required this.ordinal,
    required this.stableTrackId,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    this.artist,
    this.artworkUrl,
    this.durationMs,
    this.localUri,
    this.sourceUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ordinal'] = Variable<int>(ordinal);
    map['stable_track_id'] = Variable<String>(stableTrackId);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || localUri != null) {
      map['local_uri'] = Variable<String>(localUri);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    return map;
  }

  QueueItemsCompanion toCompanion(bool nullToAbsent) {
    return QueueItemsCompanion(
      id: Value(id),
      ordinal: Value(ordinal),
      stableTrackId: Value(stableTrackId),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      title: Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      localUri: localUri == null && nullToAbsent
          ? const Value.absent()
          : Value(localUri),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
    );
  }

  factory QueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueItem(
      id: serializer.fromJson<int>(json['id']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      stableTrackId: serializer.fromJson<String>(json['stableTrackId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      localUri: serializer.fromJson<String?>(json['localUri']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ordinal': serializer.toJson<int>(ordinal),
      'stableTrackId': serializer.toJson<String>(stableTrackId),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'durationMs': serializer.toJson<int?>(durationMs),
      'localUri': serializer.toJson<String?>(localUri),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
    };
  }

  QueueItem copyWith({
    int? id,
    int? ordinal,
    String? stableTrackId,
    String? sourceType,
    String? sourceId,
    String? title,
    Value<String?> artist = const Value.absent(),
    Value<String?> artworkUrl = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> localUri = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
  }) => QueueItem(
    id: id ?? this.id,
    ordinal: ordinal ?? this.ordinal,
    stableTrackId: stableTrackId ?? this.stableTrackId,
    sourceType: sourceType ?? this.sourceType,
    sourceId: sourceId ?? this.sourceId,
    title: title ?? this.title,
    artist: artist.present ? artist.value : this.artist,
    artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    localUri: localUri.present ? localUri.value : this.localUri,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
  );
  QueueItem copyWithCompanion(QueueItemsCompanion data) {
    return QueueItem(
      id: data.id.present ? data.id.value : this.id,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      stableTrackId: data.stableTrackId.present
          ? data.stableTrackId.value
          : this.stableTrackId,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      artworkUrl: data.artworkUrl.present
          ? data.artworkUrl.value
          : this.artworkUrl,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      localUri: data.localUri.present ? data.localUri.value : this.localUri,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueItem(')
          ..write('id: $id, ')
          ..write('ordinal: $ordinal, ')
          ..write('stableTrackId: $stableTrackId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('durationMs: $durationMs, ')
          ..write('localUri: $localUri, ')
          ..write('sourceUrl: $sourceUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ordinal,
    stableTrackId,
    sourceType,
    sourceId,
    title,
    artist,
    artworkUrl,
    durationMs,
    localUri,
    sourceUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueItem &&
          other.id == this.id &&
          other.ordinal == this.ordinal &&
          other.stableTrackId == this.stableTrackId &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.artworkUrl == this.artworkUrl &&
          other.durationMs == this.durationMs &&
          other.localUri == this.localUri &&
          other.sourceUrl == this.sourceUrl);
}

class QueueItemsCompanion extends UpdateCompanion<QueueItem> {
  final Value<int> id;
  final Value<int> ordinal;
  final Value<String> stableTrackId;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String?> artworkUrl;
  final Value<int?> durationMs;
  final Value<String?> localUri;
  final Value<String?> sourceUrl;
  const QueueItemsCompanion({
    this.id = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.stableTrackId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.localUri = const Value.absent(),
    this.sourceUrl = const Value.absent(),
  });
  QueueItemsCompanion.insert({
    this.id = const Value.absent(),
    required int ordinal,
    required String stableTrackId,
    required String sourceType,
    required String sourceId,
    required String title,
    this.artist = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.localUri = const Value.absent(),
    this.sourceUrl = const Value.absent(),
  }) : ordinal = Value(ordinal),
       stableTrackId = Value(stableTrackId),
       sourceType = Value(sourceType),
       sourceId = Value(sourceId),
       title = Value(title);
  static Insertable<QueueItem> custom({
    Expression<int>? id,
    Expression<int>? ordinal,
    Expression<String>? stableTrackId,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? artworkUrl,
    Expression<int>? durationMs,
    Expression<String>? localUri,
    Expression<String>? sourceUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ordinal != null) 'ordinal': ordinal,
      if (stableTrackId != null) 'stable_track_id': stableTrackId,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (durationMs != null) 'duration_ms': durationMs,
      if (localUri != null) 'local_uri': localUri,
      if (sourceUrl != null) 'source_url': sourceUrl,
    });
  }

  QueueItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? ordinal,
    Value<String>? stableTrackId,
    Value<String>? sourceType,
    Value<String>? sourceId,
    Value<String>? title,
    Value<String?>? artist,
    Value<String?>? artworkUrl,
    Value<int?>? durationMs,
    Value<String?>? localUri,
    Value<String?>? sourceUrl,
  }) {
    return QueueItemsCompanion(
      id: id ?? this.id,
      ordinal: ordinal ?? this.ordinal,
      stableTrackId: stableTrackId ?? this.stableTrackId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      durationMs: durationMs ?? this.durationMs,
      localUri: localUri ?? this.localUri,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (stableTrackId.present) {
      map['stable_track_id'] = Variable<String>(stableTrackId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (localUri.present) {
      map['local_uri'] = Variable<String>(localUri.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('ordinal: $ordinal, ')
          ..write('stableTrackId: $stableTrackId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('durationMs: $durationMs, ')
          ..write('localUri: $localUri, ')
          ..write('sourceUrl: $sourceUrl')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonValueMeta = const VerificationMeta(
    'jsonValue',
  );
  @override
  late final GeneratedColumn<String> jsonValue = GeneratedColumn<String>(
    'json_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
    'modified_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    jsonValue,
    schemaVersion,
    modifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('json_value')) {
      context.handle(
        _jsonValueMeta,
        jsonValue.isAcceptableOrUnknown(data['json_value']!, _jsonValueMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonValueMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_modifiedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      jsonValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_value'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified_at'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String jsonValue;
  final int schemaVersion;
  final DateTime modifiedAt;
  const Setting({
    required this.key,
    required this.jsonValue,
    required this.schemaVersion,
    required this.modifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['json_value'] = Variable<String>(jsonValue);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['modified_at'] = Variable<DateTime>(modifiedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      jsonValue: Value(jsonValue),
      schemaVersion: Value(schemaVersion),
      modifiedAt: Value(modifiedAt),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      jsonValue: serializer.fromJson<String>(json['jsonValue']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'jsonValue': serializer.toJson<String>(jsonValue),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
    };
  }

  Setting copyWith({
    String? key,
    String? jsonValue,
    int? schemaVersion,
    DateTime? modifiedAt,
  }) => Setting(
    key: key ?? this.key,
    jsonValue: jsonValue ?? this.jsonValue,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    modifiedAt: modifiedAt ?? this.modifiedAt,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      jsonValue: data.jsonValue.present ? data.jsonValue.value : this.jsonValue,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('jsonValue: $jsonValue, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, jsonValue, schemaVersion, modifiedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.key == this.key &&
          other.jsonValue == this.jsonValue &&
          other.schemaVersion == this.schemaVersion &&
          other.modifiedAt == this.modifiedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> jsonValue;
  final Value<int> schemaVersion;
  final Value<DateTime> modifiedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.jsonValue = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String jsonValue,
    this.schemaVersion = const Value.absent(),
    required DateTime modifiedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       jsonValue = Value(jsonValue),
       modifiedAt = Value(modifiedAt);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? jsonValue,
    Expression<int>? schemaVersion,
    Expression<DateTime>? modifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (jsonValue != null) 'json_value': jsonValue,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? jsonValue,
    Value<int>? schemaVersion,
    Value<DateTime>? modifiedAt,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      jsonValue: jsonValue ?? this.jsonValue,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (jsonValue.present) {
      map['json_value'] = Variable<String>(jsonValue.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('jsonValue: $jsonValue, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportedFoldersTable extends ImportedFolders
    with TableInfo<$ImportedFoldersTable, ImportedFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportedFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accessUriMeta = const VerificationMeta(
    'accessUri',
  );
  @override
  late final GeneratedColumn<String> accessUri = GeneratedColumn<String>(
    'access_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _recursiveMeta = const VerificationMeta(
    'recursive',
  );
  @override
  late final GeneratedColumn<bool> recursive = GeneratedColumn<bool>(
    'recursive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recursive" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastScanAtMeta = const VerificationMeta(
    'lastScanAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastScanAt = GeneratedColumn<DateTime>(
    'last_scan_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, accessUri, recursive, lastScanAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imported_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportedFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('access_uri')) {
      context.handle(
        _accessUriMeta,
        accessUri.isAcceptableOrUnknown(data['access_uri']!, _accessUriMeta),
      );
    } else if (isInserting) {
      context.missing(_accessUriMeta);
    }
    if (data.containsKey('recursive')) {
      context.handle(
        _recursiveMeta,
        recursive.isAcceptableOrUnknown(data['recursive']!, _recursiveMeta),
      );
    }
    if (data.containsKey('last_scan_at')) {
      context.handle(
        _lastScanAtMeta,
        lastScanAt.isAcceptableOrUnknown(
          data['last_scan_at']!,
          _lastScanAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportedFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportedFolder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accessUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_uri'],
      )!,
      recursive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recursive'],
      )!,
      lastScanAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_scan_at'],
      ),
    );
  }

  @override
  $ImportedFoldersTable createAlias(String alias) {
    return $ImportedFoldersTable(attachedDatabase, alias);
  }
}

class ImportedFolder extends DataClass implements Insertable<ImportedFolder> {
  final int id;
  final String accessUri;
  final bool recursive;
  final DateTime? lastScanAt;
  const ImportedFolder({
    required this.id,
    required this.accessUri,
    required this.recursive,
    this.lastScanAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['access_uri'] = Variable<String>(accessUri);
    map['recursive'] = Variable<bool>(recursive);
    if (!nullToAbsent || lastScanAt != null) {
      map['last_scan_at'] = Variable<DateTime>(lastScanAt);
    }
    return map;
  }

  ImportedFoldersCompanion toCompanion(bool nullToAbsent) {
    return ImportedFoldersCompanion(
      id: Value(id),
      accessUri: Value(accessUri),
      recursive: Value(recursive),
      lastScanAt: lastScanAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScanAt),
    );
  }

  factory ImportedFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportedFolder(
      id: serializer.fromJson<int>(json['id']),
      accessUri: serializer.fromJson<String>(json['accessUri']),
      recursive: serializer.fromJson<bool>(json['recursive']),
      lastScanAt: serializer.fromJson<DateTime?>(json['lastScanAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accessUri': serializer.toJson<String>(accessUri),
      'recursive': serializer.toJson<bool>(recursive),
      'lastScanAt': serializer.toJson<DateTime?>(lastScanAt),
    };
  }

  ImportedFolder copyWith({
    int? id,
    String? accessUri,
    bool? recursive,
    Value<DateTime?> lastScanAt = const Value.absent(),
  }) => ImportedFolder(
    id: id ?? this.id,
    accessUri: accessUri ?? this.accessUri,
    recursive: recursive ?? this.recursive,
    lastScanAt: lastScanAt.present ? lastScanAt.value : this.lastScanAt,
  );
  ImportedFolder copyWithCompanion(ImportedFoldersCompanion data) {
    return ImportedFolder(
      id: data.id.present ? data.id.value : this.id,
      accessUri: data.accessUri.present ? data.accessUri.value : this.accessUri,
      recursive: data.recursive.present ? data.recursive.value : this.recursive,
      lastScanAt: data.lastScanAt.present
          ? data.lastScanAt.value
          : this.lastScanAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportedFolder(')
          ..write('id: $id, ')
          ..write('accessUri: $accessUri, ')
          ..write('recursive: $recursive, ')
          ..write('lastScanAt: $lastScanAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accessUri, recursive, lastScanAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportedFolder &&
          other.id == this.id &&
          other.accessUri == this.accessUri &&
          other.recursive == this.recursive &&
          other.lastScanAt == this.lastScanAt);
}

class ImportedFoldersCompanion extends UpdateCompanion<ImportedFolder> {
  final Value<int> id;
  final Value<String> accessUri;
  final Value<bool> recursive;
  final Value<DateTime?> lastScanAt;
  const ImportedFoldersCompanion({
    this.id = const Value.absent(),
    this.accessUri = const Value.absent(),
    this.recursive = const Value.absent(),
    this.lastScanAt = const Value.absent(),
  });
  ImportedFoldersCompanion.insert({
    this.id = const Value.absent(),
    required String accessUri,
    this.recursive = const Value.absent(),
    this.lastScanAt = const Value.absent(),
  }) : accessUri = Value(accessUri);
  static Insertable<ImportedFolder> custom({
    Expression<int>? id,
    Expression<String>? accessUri,
    Expression<bool>? recursive,
    Expression<DateTime>? lastScanAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accessUri != null) 'access_uri': accessUri,
      if (recursive != null) 'recursive': recursive,
      if (lastScanAt != null) 'last_scan_at': lastScanAt,
    });
  }

  ImportedFoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? accessUri,
    Value<bool>? recursive,
    Value<DateTime?>? lastScanAt,
  }) {
    return ImportedFoldersCompanion(
      id: id ?? this.id,
      accessUri: accessUri ?? this.accessUri,
      recursive: recursive ?? this.recursive,
      lastScanAt: lastScanAt ?? this.lastScanAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accessUri.present) {
      map['access_uri'] = Variable<String>(accessUri.value);
    }
    if (recursive.present) {
      map['recursive'] = Variable<bool>(recursive.value);
    }
    if (lastScanAt.present) {
      map['last_scan_at'] = Variable<DateTime>(lastScanAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportedFoldersCompanion(')
          ..write('id: $id, ')
          ..write('accessUri: $accessUri, ')
          ..write('recursive: $recursive, ')
          ..write('lastScanAt: $lastScanAt')
          ..write(')'))
        .toString();
  }
}

class $ProviderCacheTable extends ProviderCache
    with TableInfo<$ProviderCacheTable, ProviderCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ttlSecondsMeta = const VerificationMeta(
    'ttlSeconds',
  );
  @override
  late final GeneratedColumn<int> ttlSeconds = GeneratedColumn<int>(
    'ttl_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(300),
  );
  @override
  List<GeneratedColumn> get $columns => [key, json, fetchedAt, ttlSeconds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provider_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProviderCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('ttl_seconds')) {
      context.handle(
        _ttlSecondsMeta,
        ttlSeconds.isAcceptableOrUnknown(data['ttl_seconds']!, _ttlSecondsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ProviderCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderCacheData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      ttlSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ttl_seconds'],
      )!,
    );
  }

  @override
  $ProviderCacheTable createAlias(String alias) {
    return $ProviderCacheTable(attachedDatabase, alias);
  }
}

class ProviderCacheData extends DataClass
    implements Insertable<ProviderCacheData> {
  final String key;
  final String json;
  final DateTime fetchedAt;
  final int ttlSeconds;
  const ProviderCacheData({
    required this.key,
    required this.json,
    required this.fetchedAt,
    required this.ttlSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['json'] = Variable<String>(json);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['ttl_seconds'] = Variable<int>(ttlSeconds);
    return map;
  }

  ProviderCacheCompanion toCompanion(bool nullToAbsent) {
    return ProviderCacheCompanion(
      key: Value(key),
      json: Value(json),
      fetchedAt: Value(fetchedAt),
      ttlSeconds: Value(ttlSeconds),
    );
  }

  factory ProviderCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderCacheData(
      key: serializer.fromJson<String>(json['key']),
      json: serializer.fromJson<String>(json['json']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      ttlSeconds: serializer.fromJson<int>(json['ttlSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'json': serializer.toJson<String>(json),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'ttlSeconds': serializer.toJson<int>(ttlSeconds),
    };
  }

  ProviderCacheData copyWith({
    String? key,
    String? json,
    DateTime? fetchedAt,
    int? ttlSeconds,
  }) => ProviderCacheData(
    key: key ?? this.key,
    json: json ?? this.json,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    ttlSeconds: ttlSeconds ?? this.ttlSeconds,
  );
  ProviderCacheData copyWithCompanion(ProviderCacheCompanion data) {
    return ProviderCacheData(
      key: data.key.present ? data.key.value : this.key,
      json: data.json.present ? data.json.value : this.json,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      ttlSeconds: data.ttlSeconds.present
          ? data.ttlSeconds.value
          : this.ttlSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProviderCacheData(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('ttlSeconds: $ttlSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, json, fetchedAt, ttlSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderCacheData &&
          other.key == this.key &&
          other.json == this.json &&
          other.fetchedAt == this.fetchedAt &&
          other.ttlSeconds == this.ttlSeconds);
}

class ProviderCacheCompanion extends UpdateCompanion<ProviderCacheData> {
  final Value<String> key;
  final Value<String> json;
  final Value<DateTime> fetchedAt;
  final Value<int> ttlSeconds;
  final Value<int> rowid;
  const ProviderCacheCompanion({
    this.key = const Value.absent(),
    this.json = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.ttlSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProviderCacheCompanion.insert({
    required String key,
    required String json,
    required DateTime fetchedAt,
    this.ttlSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       json = Value(json),
       fetchedAt = Value(fetchedAt);
  static Insertable<ProviderCacheData> custom({
    Expression<String>? key,
    Expression<String>? json,
    Expression<DateTime>? fetchedAt,
    Expression<int>? ttlSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (json != null) 'json': json,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (ttlSeconds != null) 'ttl_seconds': ttlSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProviderCacheCompanion copyWith({
    Value<String>? key,
    Value<String>? json,
    Value<DateTime>? fetchedAt,
    Value<int>? ttlSeconds,
    Value<int>? rowid,
  }) {
    return ProviderCacheCompanion(
      key: key ?? this.key,
      json: json ?? this.json,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      ttlSeconds: ttlSeconds ?? this.ttlSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (ttlSeconds.present) {
      map['ttl_seconds'] = Variable<int>(ttlSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderCacheCompanion(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('ttlSeconds: $ttlSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalTracksTable localTracks = $LocalTracksTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistEntriesTable playlistEntries = $PlaylistEntriesTable(
    this,
  );
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $ListeningHistoryTable listeningHistory = $ListeningHistoryTable(
    this,
  );
  late final $RecentSearchesTable recentSearches = $RecentSearchesTable(this);
  late final $DownloadJobsTable downloadJobs = $DownloadJobsTable(this);
  late final $QueueMetaTable queueMeta = $QueueMetaTable(this);
  late final $QueueItemsTable queueItems = $QueueItemsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $ImportedFoldersTable importedFolders = $ImportedFoldersTable(
    this,
  );
  late final $ProviderCacheTable providerCache = $ProviderCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localTracks,
    playlists,
    playlistEntries,
    favorites,
    listeningHistory,
    recentSearches,
    downloadJobs,
    queueMeta,
    queueItems,
    settings,
    importedFolders,
    providerCache,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LocalTracksTableCreateCompanionBuilder =
    LocalTracksCompanion Function({
      required String id,
      required String uri,
      required String uriKind,
      required String title,
      Value<String?> artist,
      Value<String?> album,
      Value<int?> durationMs,
      Value<int?> sizeBytes,
      Value<String?> genre,
      required String fingerprint,
      Value<Uint8List?> artworkBlob,
      Value<DateTime?> modifiedAt,
      Value<bool> isMissing,
      required DateTime importedAt,
      Value<int> rowid,
    });
typedef $$LocalTracksTableUpdateCompanionBuilder =
    LocalTracksCompanion Function({
      Value<String> id,
      Value<String> uri,
      Value<String> uriKind,
      Value<String> title,
      Value<String?> artist,
      Value<String?> album,
      Value<int?> durationMs,
      Value<int?> sizeBytes,
      Value<String?> genre,
      Value<String> fingerprint,
      Value<Uint8List?> artworkBlob,
      Value<DateTime?> modifiedAt,
      Value<bool> isMissing,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });

class $$LocalTracksTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTracksTable> {
  $$LocalTracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uriKind => $composableBuilder(
    column: $table.uriKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get artworkBlob => $composableBuilder(
    column: $table.artworkBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMissing => $composableBuilder(
    column: $table.isMissing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTracksTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTracksTable> {
  $$LocalTracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uriKind => $composableBuilder(
    column: $table.uriKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get artworkBlob => $composableBuilder(
    column: $table.artworkBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMissing => $composableBuilder(
    column: $table.isMissing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTracksTable> {
  $$LocalTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get uriKind =>
      $composableBuilder(column: $table.uriKind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get artworkBlob => $composableBuilder(
    column: $table.artworkBlob,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMissing =>
      $composableBuilder(column: $table.isMissing, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );
}

class $$LocalTracksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTracksTable,
          LocalTrack,
          $$LocalTracksTableFilterComposer,
          $$LocalTracksTableOrderingComposer,
          $$LocalTracksTableAnnotationComposer,
          $$LocalTracksTableCreateCompanionBuilder,
          $$LocalTracksTableUpdateCompanionBuilder,
          (
            LocalTrack,
            BaseReferences<_$AppDatabase, $LocalTracksTable, LocalTrack>,
          ),
          LocalTrack,
          PrefetchHooks Function()
        > {
  $$LocalTracksTableTableManager(_$AppDatabase db, $LocalTracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<String> uriKind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<Uint8List?> artworkBlob = const Value.absent(),
                Value<DateTime?> modifiedAt = const Value.absent(),
                Value<bool> isMissing = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTracksCompanion(
                id: id,
                uri: uri,
                uriKind: uriKind,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                sizeBytes: sizeBytes,
                genre: genre,
                fingerprint: fingerprint,
                artworkBlob: artworkBlob,
                modifiedAt: modifiedAt,
                isMissing: isMissing,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String uri,
                required String uriKind,
                required String title,
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                required String fingerprint,
                Value<Uint8List?> artworkBlob = const Value.absent(),
                Value<DateTime?> modifiedAt = const Value.absent(),
                Value<bool> isMissing = const Value.absent(),
                required DateTime importedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalTracksCompanion.insert(
                id: id,
                uri: uri,
                uriKind: uriKind,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                sizeBytes: sizeBytes,
                genre: genre,
                fingerprint: fingerprint,
                artworkBlob: artworkBlob,
                modifiedAt: modifiedAt,
                isMissing: isMissing,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalTracksTable, LocalTrack>(table),
                  BaseReferences<_$AppDatabase, $LocalTracksTable, LocalTrack>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTracksTable,
      LocalTrack,
      $$LocalTracksTableFilterComposer,
      $$LocalTracksTableOrderingComposer,
      $$LocalTracksTableAnnotationComposer,
      $$LocalTracksTableCreateCompanionBuilder,
      $$LocalTracksTableUpdateCompanionBuilder,
      (
        LocalTrack,
        BaseReferences<_$AppDatabase, $LocalTracksTable, LocalTrack>,
      ),
      LocalTrack,
      PrefetchHooks Function()
    >;
typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({
  required String id,
  required String title,
  Value<String?> description,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$PlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistEntriesTable, List<PlaylistEntry>>
  _playlistEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistEntries,
    aliasName: 'playlists__id__playlist_entries__playlist_id',
  );

  $$PlaylistEntriesTableProcessedTableManager get playlistEntriesRefs {
    final manager = $$PlaylistEntriesTableTableManager(
      $_db,
      $_db.playlistEntries,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistEntriesRefs(
    Expression<bool> Function($$PlaylistEntriesTableFilterComposer f) f,
  ) {
    final $$PlaylistEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntries,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntriesTableFilterComposer(
            $db: $db,
            $table: $db.playlistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> playlistEntriesRefs<T extends Object>(
    Expression<T> Function($$PlaylistEntriesTableAnnotationComposer a) f,
  ) {
    final $$PlaylistEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntries,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTable,
          Playlist,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (Playlist, $$PlaylistsTableReferences),
          Playlist,
          PrefetchHooks Function({bool playlistEntriesRefs})
        > {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion(
                id: id,
                title: title,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion.insert(
                id: id,
                title: title,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistsTable, Playlist>(table),
                  $$PlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistEntriesRefs) db.playlistEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistEntriesRefs)
                    await $_getPrefetchedDataByColumns<
                      Playlist,
                      $PlaylistsTable,
                      PlaylistEntry,
                      $PlaylistEntriesTable
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistsTableReferences
                          ._playlistEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistsTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistEntriesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'playlist_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTable,
      Playlist,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (Playlist, $$PlaylistsTableReferences),
      Playlist,
      PrefetchHooks Function({bool playlistEntriesRefs})
    >;
typedef $$PlaylistEntriesTableCreateCompanionBuilder =
    PlaylistEntriesCompanion Function({
      required String id,
      required String playlistId,
      required String stableTrackId,
      required String sourceType,
      required String sourceId,
      required int ordinal,
      required DateTime addedAt,
      required String fallbackTitle,
      Value<String?> fallbackArtist,
      Value<int?> fallbackDurationMs,
      Value<int> rowid,
    });
typedef $$PlaylistEntriesTableUpdateCompanionBuilder =
    PlaylistEntriesCompanion Function({
      Value<String> id,
      Value<String> playlistId,
      Value<String> stableTrackId,
      Value<String> sourceType,
      Value<String> sourceId,
      Value<int> ordinal,
      Value<DateTime> addedAt,
      Value<String> fallbackTitle,
      Value<String?> fallbackArtist,
      Value<int?> fallbackDurationMs,
      Value<int> rowid,
    });

final class $$PlaylistEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlaylistEntriesTable, PlaylistEntry> {
  $$PlaylistEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('playlist_entries__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stableTrackId => $composableBuilder(
    column: $table.stableTrackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fallbackTitle => $composableBuilder(
    column: $table.fallbackTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fallbackArtist => $composableBuilder(
    column: $table.fallbackArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fallbackDurationMs => $composableBuilder(
    column: $table.fallbackDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stableTrackId => $composableBuilder(
    column: $table.stableTrackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fallbackTitle => $composableBuilder(
    column: $table.fallbackTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fallbackArtist => $composableBuilder(
    column: $table.fallbackArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fallbackDurationMs => $composableBuilder(
    column: $table.fallbackDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stableTrackId => $composableBuilder(
    column: $table.stableTrackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<String> get fallbackTitle => $composableBuilder(
    column: $table.fallbackTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fallbackArtist => $composableBuilder(
    column: $table.fallbackArtist,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fallbackDurationMs => $composableBuilder(
    column: $table.fallbackDurationMs,
    builder: (column) => column,
  );

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistEntriesTable,
          PlaylistEntry,
          $$PlaylistEntriesTableFilterComposer,
          $$PlaylistEntriesTableOrderingComposer,
          $$PlaylistEntriesTableAnnotationComposer,
          $$PlaylistEntriesTableCreateCompanionBuilder,
          $$PlaylistEntriesTableUpdateCompanionBuilder,
          (PlaylistEntry, $$PlaylistEntriesTableReferences),
          PlaylistEntry,
          PrefetchHooks Function({bool playlistId})
        > {
  $$PlaylistEntriesTableTableManager(
    _$AppDatabase db,
    $PlaylistEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> playlistId = const Value.absent(),
                Value<String> stableTrackId = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<String> fallbackTitle = const Value.absent(),
                Value<String?> fallbackArtist = const Value.absent(),
                Value<int?> fallbackDurationMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistEntriesCompanion(
                id: id,
                playlistId: playlistId,
                stableTrackId: stableTrackId,
                sourceType: sourceType,
                sourceId: sourceId,
                ordinal: ordinal,
                addedAt: addedAt,
                fallbackTitle: fallbackTitle,
                fallbackArtist: fallbackArtist,
                fallbackDurationMs: fallbackDurationMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String playlistId,
                required String stableTrackId,
                required String sourceType,
                required String sourceId,
                required int ordinal,
                required DateTime addedAt,
                required String fallbackTitle,
                Value<String?> fallbackArtist = const Value.absent(),
                Value<int?> fallbackDurationMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistEntriesCompanion.insert(
                id: id,
                playlistId: playlistId,
                stableTrackId: stableTrackId,
                sourceType: sourceType,
                sourceId: sourceId,
                ordinal: ordinal,
                addedAt: addedAt,
                fallbackTitle: fallbackTitle,
                fallbackArtist: fallbackArtist,
                fallbackDurationMs: fallbackDurationMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistEntriesTable, PlaylistEntry>(table),
                  $$PlaylistEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$PlaylistEntriesTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$PlaylistEntriesTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistEntriesTable,
      PlaylistEntry,
      $$PlaylistEntriesTableFilterComposer,
      $$PlaylistEntriesTableOrderingComposer,
      $$PlaylistEntriesTableAnnotationComposer,
      $$PlaylistEntriesTableCreateCompanionBuilder,
      $$PlaylistEntriesTableUpdateCompanionBuilder,
      (PlaylistEntry, $$PlaylistEntriesTableReferences),
      PlaylistEntry,
      PrefetchHooks Function({bool playlistId})
    >;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required String id,
  required DateTime addedAt,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> id,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          Favorite,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
          Favorite,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => FavoritesCompanion(id: id, addedAt: addedAt, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion.insert(
                id: id,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTable, Favorite>(table),
                  BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      Favorite,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
      Favorite,
      PrefetchHooks Function()
    >;
typedef $$ListeningHistoryTableCreateCompanionBuilder =
    ListeningHistoryCompanion Function({
      Value<int> id,
      required String stableTrackId,
      required String sourceType,
      required DateTime startedAt,
      Value<int?> lastPositionMs,
      Value<int> listenedMs,
      Value<bool> completed,
      Value<bool> deviceLocal,
    });
typedef $$ListeningHistoryTableUpdateCompanionBuilder =
    ListeningHistoryCompanion Function({
      Value<int> id,
      Value<String> stableTrackId,
      Value<String> sourceType,
      Value<DateTime> startedAt,
      Value<int?> lastPositionMs,
      Value<int> listenedMs,
      Value<bool> completed,
      Value<bool> deviceLocal,
    });

class $$ListeningHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ListeningHistoryTable> {
  $$ListeningHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stableTrackId => $composableBuilder(
    column: $table.stableTrackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deviceLocal => $composableBuilder(
    column: $table.deviceLocal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ListeningHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ListeningHistoryTable> {
  $$ListeningHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stableTrackId => $composableBuilder(
    column: $table.stableTrackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deviceLocal => $composableBuilder(
    column: $table.deviceLocal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ListeningHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListeningHistoryTable> {
  $$ListeningHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stableTrackId => $composableBuilder(
    column: $table.stableTrackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get deviceLocal => $composableBuilder(
    column: $table.deviceLocal,
    builder: (column) => column,
  );
}

class $$ListeningHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ListeningHistoryTable,
          ListeningHistoryData,
          $$ListeningHistoryTableFilterComposer,
          $$ListeningHistoryTableOrderingComposer,
          $$ListeningHistoryTableAnnotationComposer,
          $$ListeningHistoryTableCreateCompanionBuilder,
          $$ListeningHistoryTableUpdateCompanionBuilder,
          (
            ListeningHistoryData,
            BaseReferences<
              _$AppDatabase,
              $ListeningHistoryTable,
              ListeningHistoryData
            >,
          ),
          ListeningHistoryData,
          PrefetchHooks Function()
        > {
  $$ListeningHistoryTableTableManager(
    _$AppDatabase db,
    $ListeningHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListeningHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListeningHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListeningHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> stableTrackId = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int?> lastPositionMs = const Value.absent(),
                Value<int> listenedMs = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> deviceLocal = const Value.absent(),
              }) => ListeningHistoryCompanion(
                id: id,
                stableTrackId: stableTrackId,
                sourceType: sourceType,
                startedAt: startedAt,
                lastPositionMs: lastPositionMs,
                listenedMs: listenedMs,
                completed: completed,
                deviceLocal: deviceLocal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String stableTrackId,
                required String sourceType,
                required DateTime startedAt,
                Value<int?> lastPositionMs = const Value.absent(),
                Value<int> listenedMs = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> deviceLocal = const Value.absent(),
              }) => ListeningHistoryCompanion.insert(
                id: id,
                stableTrackId: stableTrackId,
                sourceType: sourceType,
                startedAt: startedAt,
                lastPositionMs: lastPositionMs,
                listenedMs: listenedMs,
                completed: completed,
                deviceLocal: deviceLocal,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ListeningHistoryTable, ListeningHistoryData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ListeningHistoryTable,
                    ListeningHistoryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ListeningHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ListeningHistoryTable,
      ListeningHistoryData,
      $$ListeningHistoryTableFilterComposer,
      $$ListeningHistoryTableOrderingComposer,
      $$ListeningHistoryTableAnnotationComposer,
      $$ListeningHistoryTableCreateCompanionBuilder,
      $$ListeningHistoryTableUpdateCompanionBuilder,
      (
        ListeningHistoryData,
        BaseReferences<
          _$AppDatabase,
          $ListeningHistoryTable,
          ListeningHistoryData
        >,
      ),
      ListeningHistoryData,
      PrefetchHooks Function()
    >;
typedef $$RecentSearchesTableCreateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<int> id,
      required String query,
      required DateTime at,
    });
typedef $$RecentSearchesTableUpdateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<int> id,
      Value<String> query,
      Value<DateTime> at,
    });

class $$RecentSearchesTableFilterComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentSearchesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentSearchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$RecentSearchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentSearchesTable,
          RecentSearche,
          $$RecentSearchesTableFilterComposer,
          $$RecentSearchesTableOrderingComposer,
          $$RecentSearchesTableAnnotationComposer,
          $$RecentSearchesTableCreateCompanionBuilder,
          $$RecentSearchesTableUpdateCompanionBuilder,
          (
            RecentSearche,
            BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearche>,
          ),
          RecentSearche,
          PrefetchHooks Function()
        > {
  $$RecentSearchesTableTableManager(
    _$AppDatabase db,
    $RecentSearchesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentSearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> query = const Value.absent(),
            Value<DateTime> at = const Value.absent(),
          }) => RecentSearchesCompanion(id: id, query: query, at: at),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String query,
            required DateTime at,
          }) => RecentSearchesCompanion.insert(id: id, query: query, at: at),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecentSearchesTable, RecentSearche>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecentSearchesTable,
                    RecentSearche
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentSearchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentSearchesTable,
      RecentSearche,
      $$RecentSearchesTableFilterComposer,
      $$RecentSearchesTableOrderingComposer,
      $$RecentSearchesTableAnnotationComposer,
      $$RecentSearchesTableCreateCompanionBuilder,
      $$RecentSearchesTableUpdateCompanionBuilder,
      (
        RecentSearche,
        BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearche>,
      ),
      RecentSearche,
      PrefetchHooks Function()
    >;
typedef $$DownloadJobsTableCreateCompanionBuilder =
    DownloadJobsCompanion Function({
      required String id,
      required String stableTrackId,
      required String provider,
      required String title,
      Value<String?> artist,
      required String targetPath,
      required String tempPath,
      Value<int?> bytesTotal,
      Value<int> bytesWritten,
      required String state,
      Value<String?> errorCode,
      Value<int> attemptCount,
      Value<bool> canResume,
      required String permissionProof,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DownloadJobsTableUpdateCompanionBuilder =
    DownloadJobsCompanion Function({
      Value<String> id,
      Value<String> stableTrackId,
      Value<String> provider,
      Value<String> title,
      Value<String?> artist,
      Value<String> targetPath,
      Value<String> tempPath,
      Value<int?> bytesTotal,
      Value<int> bytesWritten,
      Value<String> state,
      Value<String?> errorCode,
      Value<int> attemptCount,
      Value<bool> canResume,
      Value<String> permissionProof,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DownloadJobsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadJobsTable> {
  $$DownloadJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stableTrackId => $composableBuilder(
    column: $table.stableTrackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetPath => $composableBuilder(
    column: $table.targetPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tempPath => $composableBuilder(
    column: $table.tempPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesTotal => $composableBuilder(
    column: $table.bytesTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesWritten => $composableBuilder(
    column: $table.bytesWritten,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canResume => $composableBuilder(
    column: $table.canResume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissionProof => $composableBuilder(
    column: $table.permissionProof,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadJobsTable> {
  $$DownloadJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stableTrackId => $composableBuilder(
    column: $table.stableTrackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetPath => $composableBuilder(
    column: $table.targetPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tempPath => $composableBuilder(
    column: $table.tempPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesTotal => $composableBuilder(
    column: $table.bytesTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesWritten => $composableBuilder(
    column: $table.bytesWritten,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canResume => $composableBuilder(
    column: $table.canResume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissionProof => $composableBuilder(
    column: $table.permissionProof,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadJobsTable> {
  $$DownloadJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stableTrackId => $composableBuilder(
    column: $table.stableTrackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get targetPath => $composableBuilder(
    column: $table.targetPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tempPath =>
      $composableBuilder(column: $table.tempPath, builder: (column) => column);

  GeneratedColumn<int> get bytesTotal => $composableBuilder(
    column: $table.bytesTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bytesWritten => $composableBuilder(
    column: $table.bytesWritten,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canResume =>
      $composableBuilder(column: $table.canResume, builder: (column) => column);

  GeneratedColumn<String> get permissionProof => $composableBuilder(
    column: $table.permissionProof,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadJobsTable,
          DownloadJob,
          $$DownloadJobsTableFilterComposer,
          $$DownloadJobsTableOrderingComposer,
          $$DownloadJobsTableAnnotationComposer,
          $$DownloadJobsTableCreateCompanionBuilder,
          $$DownloadJobsTableUpdateCompanionBuilder,
          (
            DownloadJob,
            BaseReferences<_$AppDatabase, $DownloadJobsTable, DownloadJob>,
          ),
          DownloadJob,
          PrefetchHooks Function()
        > {
  $$DownloadJobsTableTableManager(_$AppDatabase db, $DownloadJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> stableTrackId = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String> targetPath = const Value.absent(),
                Value<String> tempPath = const Value.absent(),
                Value<int?> bytesTotal = const Value.absent(),
                Value<int> bytesWritten = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<bool> canResume = const Value.absent(),
                Value<String> permissionProof = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadJobsCompanion(
                id: id,
                stableTrackId: stableTrackId,
                provider: provider,
                title: title,
                artist: artist,
                targetPath: targetPath,
                tempPath: tempPath,
                bytesTotal: bytesTotal,
                bytesWritten: bytesWritten,
                state: state,
                errorCode: errorCode,
                attemptCount: attemptCount,
                canResume: canResume,
                permissionProof: permissionProof,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String stableTrackId,
                required String provider,
                required String title,
                Value<String?> artist = const Value.absent(),
                required String targetPath,
                required String tempPath,
                Value<int?> bytesTotal = const Value.absent(),
                Value<int> bytesWritten = const Value.absent(),
                required String state,
                Value<String?> errorCode = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<bool> canResume = const Value.absent(),
                required String permissionProof,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DownloadJobsCompanion.insert(
                id: id,
                stableTrackId: stableTrackId,
                provider: provider,
                title: title,
                artist: artist,
                targetPath: targetPath,
                tempPath: tempPath,
                bytesTotal: bytesTotal,
                bytesWritten: bytesWritten,
                state: state,
                errorCode: errorCode,
                attemptCount: attemptCount,
                canResume: canResume,
                permissionProof: permissionProof,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadJobsTable, DownloadJob>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DownloadJobsTable,
                    DownloadJob
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadJobsTable,
      DownloadJob,
      $$DownloadJobsTableFilterComposer,
      $$DownloadJobsTableOrderingComposer,
      $$DownloadJobsTableAnnotationComposer,
      $$DownloadJobsTableCreateCompanionBuilder,
      $$DownloadJobsTableUpdateCompanionBuilder,
      (
        DownloadJob,
        BaseReferences<_$AppDatabase, $DownloadJobsTable, DownloadJob>,
      ),
      DownloadJob,
      PrefetchHooks Function()
    >;
typedef $$QueueMetaTableCreateCompanionBuilder = QueueMetaCompanion Function({
  Value<int> id,
  Value<int> activeIndex,
  Value<int> positionMs,
  Value<bool> shuffle,
  Value<int?> shuffleSeed,
  Value<String> repeatMode,
  required DateTime savedAt,
});
typedef $$QueueMetaTableUpdateCompanionBuilder = QueueMetaCompanion Function({
  Value<int> id,
  Value<int> activeIndex,
  Value<int> positionMs,
  Value<bool> shuffle,
  Value<int?> shuffleSeed,
  Value<String> repeatMode,
  Value<DateTime> savedAt,
});

class $$QueueMetaTableFilterComposer
    extends Composer<_$AppDatabase, $QueueMetaTable> {
  $$QueueMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeIndex => $composableBuilder(
    column: $table.activeIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffle => $composableBuilder(
    column: $table.shuffle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shuffleSeed => $composableBuilder(
    column: $table.shuffleSeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueueMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueMetaTable> {
  $$QueueMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeIndex => $composableBuilder(
    column: $table.activeIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffle => $composableBuilder(
    column: $table.shuffle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shuffleSeed => $composableBuilder(
    column: $table.shuffleSeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueueMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueMetaTable> {
  $$QueueMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get activeIndex => $composableBuilder(
    column: $table.activeIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shuffle =>
      $composableBuilder(column: $table.shuffle, builder: (column) => column);

  GeneratedColumn<int> get shuffleSeed => $composableBuilder(
    column: $table.shuffleSeed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$QueueMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueMetaTable,
          QueueMetaData,
          $$QueueMetaTableFilterComposer,
          $$QueueMetaTableOrderingComposer,
          $$QueueMetaTableAnnotationComposer,
          $$QueueMetaTableCreateCompanionBuilder,
          $$QueueMetaTableUpdateCompanionBuilder,
          (
            QueueMetaData,
            BaseReferences<_$AppDatabase, $QueueMetaTable, QueueMetaData>,
          ),
          QueueMetaData,
          PrefetchHooks Function()
        > {
  $$QueueMetaTableTableManager(_$AppDatabase db, $QueueMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> activeIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> shuffle = const Value.absent(),
                Value<int?> shuffleSeed = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
              }) => QueueMetaCompanion(
                id: id,
                activeIndex: activeIndex,
                positionMs: positionMs,
                shuffle: shuffle,
                shuffleSeed: shuffleSeed,
                repeatMode: repeatMode,
                savedAt: savedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> activeIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> shuffle = const Value.absent(),
                Value<int?> shuffleSeed = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                required DateTime savedAt,
              }) => QueueMetaCompanion.insert(
                id: id,
                activeIndex: activeIndex,
                positionMs: positionMs,
                shuffle: shuffle,
                shuffleSeed: shuffleSeed,
                repeatMode: repeatMode,
                savedAt: savedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QueueMetaTable, QueueMetaData>(table),
                  BaseReferences<_$AppDatabase, $QueueMetaTable, QueueMetaData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueueMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueMetaTable,
      QueueMetaData,
      $$QueueMetaTableFilterComposer,
      $$QueueMetaTableOrderingComposer,
      $$QueueMetaTableAnnotationComposer,
      $$QueueMetaTableCreateCompanionBuilder,
      $$QueueMetaTableUpdateCompanionBuilder,
      (
        QueueMetaData,
        BaseReferences<_$AppDatabase, $QueueMetaTable, QueueMetaData>,
      ),
      QueueMetaData,
      PrefetchHooks Function()
    >;
typedef $$QueueItemsTableCreateCompanionBuilder = QueueItemsCompanion Function({
  Value<int> id,
  required int ordinal,
  required String stableTrackId,
  required String sourceType,
  required String sourceId,
  required String title,
  Value<String?> artist,
  Value<String?> artworkUrl,
  Value<int?> durationMs,
  Value<String?> localUri,
  Value<String?> sourceUrl,
});
typedef $$QueueItemsTableUpdateCompanionBuilder = QueueItemsCompanion Function({
  Value<int> id,
  Value<int> ordinal,
  Value<String> stableTrackId,
  Value<String> sourceType,
  Value<String> sourceId,
  Value<String> title,
  Value<String?> artist,
  Value<String?> artworkUrl,
  Value<int?> durationMs,
  Value<String?> localUri,
  Value<String?> sourceUrl,
});

class $$QueueItemsTableFilterComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stableTrackId => $composableBuilder(
    column: $table.stableTrackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localUri => $composableBuilder(
    column: $table.localUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueueItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stableTrackId => $composableBuilder(
    column: $table.stableTrackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localUri => $composableBuilder(
    column: $table.localUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueueItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<String> get stableTrackId => $composableBuilder(
    column: $table.stableTrackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localUri =>
      $composableBuilder(column: $table.localUri, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);
}

class $$QueueItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueItemsTable,
          QueueItem,
          $$QueueItemsTableFilterComposer,
          $$QueueItemsTableOrderingComposer,
          $$QueueItemsTableAnnotationComposer,
          $$QueueItemsTableCreateCompanionBuilder,
          $$QueueItemsTableUpdateCompanionBuilder,
          (
            QueueItem,
            BaseReferences<_$AppDatabase, $QueueItemsTable, QueueItem>,
          ),
          QueueItem,
          PrefetchHooks Function()
        > {
  $$QueueItemsTableTableManager(_$AppDatabase db, $QueueItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<String> stableTrackId = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> artworkUrl = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> localUri = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
              }) => QueueItemsCompanion(
                id: id,
                ordinal: ordinal,
                stableTrackId: stableTrackId,
                sourceType: sourceType,
                sourceId: sourceId,
                title: title,
                artist: artist,
                artworkUrl: artworkUrl,
                durationMs: durationMs,
                localUri: localUri,
                sourceUrl: sourceUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ordinal,
                required String stableTrackId,
                required String sourceType,
                required String sourceId,
                required String title,
                Value<String?> artist = const Value.absent(),
                Value<String?> artworkUrl = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> localUri = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
              }) => QueueItemsCompanion.insert(
                id: id,
                ordinal: ordinal,
                stableTrackId: stableTrackId,
                sourceType: sourceType,
                sourceId: sourceId,
                title: title,
                artist: artist,
                artworkUrl: artworkUrl,
                durationMs: durationMs,
                localUri: localUri,
                sourceUrl: sourceUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QueueItemsTable, QueueItem>(table),
                  BaseReferences<_$AppDatabase, $QueueItemsTable, QueueItem>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueueItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueItemsTable,
      QueueItem,
      $$QueueItemsTableFilterComposer,
      $$QueueItemsTableOrderingComposer,
      $$QueueItemsTableAnnotationComposer,
      $$QueueItemsTableCreateCompanionBuilder,
      $$QueueItemsTableUpdateCompanionBuilder,
      (QueueItem, BaseReferences<_$AppDatabase, $QueueItemsTable, QueueItem>),
      QueueItem,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String jsonValue,
  Value<int> schemaVersion,
  required DateTime modifiedAt,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> jsonValue,
  Value<int> schemaVersion,
  Value<DateTime> modifiedAt,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonValue => $composableBuilder(
    column: $table.jsonValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonValue => $composableBuilder(
    column: $table.jsonValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get jsonValue =>
      $composableBuilder(column: $table.jsonValue, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> jsonValue = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<DateTime> modifiedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                key: key,
                jsonValue: jsonValue,
                schemaVersion: schemaVersion,
                modifiedAt: modifiedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String jsonValue,
                Value<int> schemaVersion = const Value.absent(),
                required DateTime modifiedAt,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                jsonValue: jsonValue,
                schemaVersion: schemaVersion,
                modifiedAt: modifiedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$ImportedFoldersTableCreateCompanionBuilder =
    ImportedFoldersCompanion Function({
      Value<int> id,
      required String accessUri,
      Value<bool> recursive,
      Value<DateTime?> lastScanAt,
    });
typedef $$ImportedFoldersTableUpdateCompanionBuilder =
    ImportedFoldersCompanion Function({
      Value<int> id,
      Value<String> accessUri,
      Value<bool> recursive,
      Value<DateTime?> lastScanAt,
    });

class $$ImportedFoldersTableFilterComposer
    extends Composer<_$AppDatabase, $ImportedFoldersTable> {
  $$ImportedFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessUri => $composableBuilder(
    column: $table.accessUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recursive => $composableBuilder(
    column: $table.recursive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastScanAt => $composableBuilder(
    column: $table.lastScanAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportedFoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportedFoldersTable> {
  $$ImportedFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessUri => $composableBuilder(
    column: $table.accessUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recursive => $composableBuilder(
    column: $table.recursive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastScanAt => $composableBuilder(
    column: $table.lastScanAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportedFoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportedFoldersTable> {
  $$ImportedFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accessUri =>
      $composableBuilder(column: $table.accessUri, builder: (column) => column);

  GeneratedColumn<bool> get recursive =>
      $composableBuilder(column: $table.recursive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastScanAt => $composableBuilder(
    column: $table.lastScanAt,
    builder: (column) => column,
  );
}

class $$ImportedFoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportedFoldersTable,
          ImportedFolder,
          $$ImportedFoldersTableFilterComposer,
          $$ImportedFoldersTableOrderingComposer,
          $$ImportedFoldersTableAnnotationComposer,
          $$ImportedFoldersTableCreateCompanionBuilder,
          $$ImportedFoldersTableUpdateCompanionBuilder,
          (
            ImportedFolder,
            BaseReferences<
              _$AppDatabase,
              $ImportedFoldersTable,
              ImportedFolder
            >,
          ),
          ImportedFolder,
          PrefetchHooks Function()
        > {
  $$ImportedFoldersTableTableManager(
    _$AppDatabase db,
    $ImportedFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportedFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportedFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportedFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> accessUri = const Value.absent(),
                Value<bool> recursive = const Value.absent(),
                Value<DateTime?> lastScanAt = const Value.absent(),
              }) => ImportedFoldersCompanion(
                id: id,
                accessUri: accessUri,
                recursive: recursive,
                lastScanAt: lastScanAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String accessUri,
                Value<bool> recursive = const Value.absent(),
                Value<DateTime?> lastScanAt = const Value.absent(),
              }) => ImportedFoldersCompanion.insert(
                id: id,
                accessUri: accessUri,
                recursive: recursive,
                lastScanAt: lastScanAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportedFoldersTable, ImportedFolder>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ImportedFoldersTable,
                    ImportedFolder
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportedFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportedFoldersTable,
      ImportedFolder,
      $$ImportedFoldersTableFilterComposer,
      $$ImportedFoldersTableOrderingComposer,
      $$ImportedFoldersTableAnnotationComposer,
      $$ImportedFoldersTableCreateCompanionBuilder,
      $$ImportedFoldersTableUpdateCompanionBuilder,
      (
        ImportedFolder,
        BaseReferences<_$AppDatabase, $ImportedFoldersTable, ImportedFolder>,
      ),
      ImportedFolder,
      PrefetchHooks Function()
    >;
typedef $$ProviderCacheTableCreateCompanionBuilder =
    ProviderCacheCompanion Function({
      required String key,
      required String json,
      required DateTime fetchedAt,
      Value<int> ttlSeconds,
      Value<int> rowid,
    });
typedef $$ProviderCacheTableUpdateCompanionBuilder =
    ProviderCacheCompanion Function({
      Value<String> key,
      Value<String> json,
      Value<DateTime> fetchedAt,
      Value<int> ttlSeconds,
      Value<int> rowid,
    });

class $$ProviderCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ProviderCacheTable> {
  $$ProviderCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ttlSeconds => $composableBuilder(
    column: $table.ttlSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProviderCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ProviderCacheTable> {
  $$ProviderCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ttlSeconds => $composableBuilder(
    column: $table.ttlSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProviderCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProviderCacheTable> {
  $$ProviderCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<int> get ttlSeconds => $composableBuilder(
    column: $table.ttlSeconds,
    builder: (column) => column,
  );
}

class $$ProviderCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProviderCacheTable,
          ProviderCacheData,
          $$ProviderCacheTableFilterComposer,
          $$ProviderCacheTableOrderingComposer,
          $$ProviderCacheTableAnnotationComposer,
          $$ProviderCacheTableCreateCompanionBuilder,
          $$ProviderCacheTableUpdateCompanionBuilder,
          (
            ProviderCacheData,
            BaseReferences<
              _$AppDatabase,
              $ProviderCacheTable,
              ProviderCacheData
            >,
          ),
          ProviderCacheData,
          PrefetchHooks Function()
        > {
  $$ProviderCacheTableTableManager(_$AppDatabase db, $ProviderCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProviderCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProviderCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProviderCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> ttlSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderCacheCompanion(
                key: key,
                json: json,
                fetchedAt: fetchedAt,
                ttlSeconds: ttlSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String json,
                required DateTime fetchedAt,
                Value<int> ttlSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderCacheCompanion.insert(
                key: key,
                json: json,
                fetchedAt: fetchedAt,
                ttlSeconds: ttlSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProviderCacheTable, ProviderCacheData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ProviderCacheTable,
                    ProviderCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProviderCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProviderCacheTable,
      ProviderCacheData,
      $$ProviderCacheTableFilterComposer,
      $$ProviderCacheTableOrderingComposer,
      $$ProviderCacheTableAnnotationComposer,
      $$ProviderCacheTableCreateCompanionBuilder,
      $$ProviderCacheTableUpdateCompanionBuilder,
      (
        ProviderCacheData,
        BaseReferences<_$AppDatabase, $ProviderCacheTable, ProviderCacheData>,
      ),
      ProviderCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalTracksTableTableManager get localTracks =>
      $$LocalTracksTableTableManager(_db, _db.localTracks);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistEntriesTableTableManager get playlistEntries =>
      $$PlaylistEntriesTableTableManager(_db, _db.playlistEntries);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$ListeningHistoryTableTableManager get listeningHistory =>
      $$ListeningHistoryTableTableManager(_db, _db.listeningHistory);
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(_db, _db.recentSearches);
  $$DownloadJobsTableTableManager get downloadJobs =>
      $$DownloadJobsTableTableManager(_db, _db.downloadJobs);
  $$QueueMetaTableTableManager get queueMeta =>
      $$QueueMetaTableTableManager(_db, _db.queueMeta);
  $$QueueItemsTableTableManager get queueItems =>
      $$QueueItemsTableTableManager(_db, _db.queueItems);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$ImportedFoldersTableTableManager get importedFolders =>
      $$ImportedFoldersTableTableManager(_db, _db.importedFolders);
  $$ProviderCacheTableTableManager get providerCache =>
      $$ProviderCacheTableTableManager(_db, _db.providerCache);
}
