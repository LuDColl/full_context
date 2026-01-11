import 'package:flutter/material.dart';
import 'package:full_context/full_context.dart';

class Entity {
  Entity({required this.id, required this.name});

  final int id;
  final String name;

  String get display => '$name $idº';
}

class Dal {
  final List<Entity> _entities = [Entity(id: 1, name: 'Hello world!')];

  Future<List<Entity>> getAll() async {
    final duration = const Duration(milliseconds: 500);
    await Future.delayed(duration);
    return _entities;
  }

  void add(Entity entity) => _entities.add(entity);
}

class Repository {
  Repository(this.dal);

  final Dal dal;

  Future<List<Entity>> getAll() async {
    final duration = const Duration(milliseconds: 500);
    await Future.delayed(duration);
    return dal.getAll();
  }

  void add(Entity entity) => dal.add(entity);
}

class Service {
  Service(this.repository);

  final Repository repository;

  Future<List<Entity>> getAll() async {
    final duration = const Duration(milliseconds: 500);
    await Future.delayed(duration);
    return repository.getAll();
  }

  void add(Entity entity) => repository.add(entity);
}

class Controller {
  Controller(this.service);

  final Service service;

  Future<List<Entity>> getAll() async {
    final duration = const Duration(milliseconds: 500);
    await Future.delayed(duration);
    return service.getAll();
  }

  Future<void> add(BuildContext context) async {
    context.emit<bool>(false);
    final model = context.get<List<Entity>>();
    final entity = Entity(id: model.length + 1, name: 'Hello world!');

    service.add(entity);

    final newModel = await service.getAll();
    if (!context.mounted) return;

    context.emit<List<Entity>>(newModel);
    context.emit<bool>(true);
  }
}

class FCInjectExample extends StatelessWidget {
  const FCInjectExample({super.key});

  @override
  Widget build(BuildContext context) => FullContext(
    listenables: [bool, List<Entity>],
    factories: [
      Dal.new,
      () => true,
      Service.new,
      Controller.new,
      Repository.new,
      (Controller controller) => controller.getAll(),
    ],
    loadingBuilder: (context) {
      return const Center(child: CircularProgressIndicator());
    },
    builder: (context) {
      final enabled = context.get<bool>();
      final model = context.get<List<Entity>>();
      final controller = context.get<Controller>();

      return InkWell(
        onTap: enabled ? () => controller.add(context) : null,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: model.length,
          itemBuilder: (context, index) {
            final entity = model[index];
            return ListTile(title: Text(entity.display));
          },
        ),
      );
    },
  );
}
