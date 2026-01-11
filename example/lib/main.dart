import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:full_context/full_context.dart';

void main() {
  runApp(App());
}

abstract class EntityBase {
  Map<String, dynamic> toMap();
}

class Entity implements EntityBase {
  final int id;
  final String name;

  Entity({required this.id, required this.name});

  factory Entity.fromMap(Map<String, dynamic> map) {
    return Entity(
      id: map['id'],
      name: map['name'],
    );
  }

  Entity copyWith({
    int? id,
    String? name,
  }) {
    return Entity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Dal {
  Dal(this.db);

  final Database db;

  Future<int> insert<T extends EntityBase>(T entity) {
    return db.insert(
      '$T',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Iterable<T>> getAll<T>(
    T Function(Map<String, dynamic> map) fromMap,
  ) async {
    final rows = await db.rawQuery('SELECT * FROM $T');
    final entities = rows.map(fromMap);
    return entities;
  }
}

class Repository {
  Repository(this.dal);

  final Dal dal;

  Future<int> insert(Entity entity) => dal.insert(entity);
  Future<Iterable<Entity>> getAll() => dal.getAll(Entity.fromMap);
}

class Service {
  Service(this.repository);

  final Repository repository;

  Future<Iterable<Entity>> getAll() => repository.getAll();
  Future<int> insert(Entity entity) => repository.insert(entity);
}

class Controller {
  Controller(this.service);

  final Service service;

  Future<List<Entity>> getAll() async {
    final entities = await service.getAll();
    return entities.toList();
  }

  Future<void> insert(BuildContext context) async {
    final entities = await service.getAll();
    final enity = entities.last;
    final newEntity = enity.copyWith(id: enity.id + 1);
    await service.insert(newEntity);
    final newEntities = await service.getAll();
    if (!context.mounted) return;

    return context.emit(newEntities.toList());
  }
}

class App extends StatelessWidget {
  App({super.key});

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $Entity (id INTEGER PRIMARY KEY, name TEXT)',
    );

    final entity = Entity(id: 1, name: 'Hello World!');
    await db.insert('$Entity', entity.toMap());
  }

  late final factories = [
    () => 1,
    getDatabasesPath,
    (List<GoRoute> routes) => GoRouter(routes: routes, initialLocation: '/'),
    () => [GoRoute(path: '/', builder: (context, state) => Home())],
    (String databasesPath, int version) {
      String path = join(databasesPath, 'demo.db');
      return openDatabase(
        path,
        version: version,
        onCreate: _onCreate,
      );
    }
  ];

  @override
  Widget build(BuildContext context) {
    return FullContext(
      factories: factories,
      listenables: [Database],
      loadingBuilder: (context) => const AppLoading(),
      errorBuilder: (context, error) => AppError(error: error.toString()),
      builder: (context) => MaterialApp.router(
        routerConfig: context.get<GoRouter>(),
        builder: (context, child) => child!,
      ),
    );
  }
}

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class AppError extends StatelessWidget {
  const AppError({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text(error)),
      ),
    );
  }
}

class Home extends StatelessWidget {
  Home({super.key});

  final factories = [
    Dal.new,
    Service.new,
    Controller.new,
    Repository.new,
    (Controller controller) => controller.getAll()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FullContext Example')),
      body: FullContext(
        factories: factories,
        listenables: [List<Entity>],
        loadingBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, error) => Center(child: Text('Error: $error')),
        builder: (context) {
          final entities = context.get<List<Entity>>();
          final controller = context.get<Controller>();

          return InkWell(
            onTap: () => controller.insert(context),
            child: ListView.separated(
              itemCount: entities.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final entity = entities[index];
                return ListTile(
                  title: Text('ID: ${entity.id}'),
                  subtitle: Text('Name: ${entity.name}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
