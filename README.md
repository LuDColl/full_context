# Full Context

## Features

- Inject variables with Factories;
- Provide variables in `FullContext` widget;
- Manipulate variables in `context` directly.

## Getting started

```dart
import 'package:flutter/material.dart';
import 'package:full_context/full_context.dart';

class FCExample extends StatelessWidget {
  const FCExample({super.key});

  @override
  Widget build(BuildContext context) => FullContext(
    listenables: [String],
    loadingBuilder: (context) =>
        const Center(child: CircularProgressIndicator()),
    factories: [
      () async {
        final duration = const Duration(seconds: 2);
        await Future.delayed(duration);
        return 1;
      },
      (int number) => number.toString(),
    ],
    builder: (context) => InkWell(
      onTap: () => context.emit<int>(context.get<int>() + 1),
      child: Text(context.get<String>()),
    ),
  );
}
```

## Usage

### required `builder`

Provide a `context`:

```dart
import 'package:flutter/widgets.dart';
import 'package:full_context/full_context.dart';

class FCBuilderExample extends StatelessWidget {
  const FCBuilderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FullContext(builder: (context) => Text('Hello world!'));
  }
}
```

### `factories` and `context.get()`:

Provide variables in context and use:

```dart
import 'package:flutter/widgets.dart';
import 'package:full_context/full_context.dart';

class FCFactoriesExample extends StatelessWidget {
  const FCFactoriesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FullContext(
      factories: [() => 'Hello world!'],
      builder: (context) => Text(context.get<String>()),
    );
  }
}
```

### `listenables` and `context.emit()`

Manipulate varriables and listen changes:

```dart
import 'package:flutter/material.dart';
import 'package:full_context/full_context.dart';

class FCListenablesExample extends StatelessWidget {
  const FCListenablesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FullContext(
      listenables: [String],
      factories: [() => 'Hello world!'],
      builder: (context) => InkWell(
        onTap: () => context.emit<String>('Hello again!'),
        child: Text(context.get<String>()),
      ),
    );
  }
}
```

- If not use `listenables`, the `context.emit()` not listenable and the changes of `context.get()` not showed. 

### `async` with `loadingBuilder` and `errorBuilder`

Provide `context` to `get()` and `emit()` only `Future` finalized:

```dart
import 'package:flutter/material.dart';
import 'package:full_context/full_context.dart';

class FCAsyncExample extends StatelessWidget {
  const FCAsyncExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FullContext(
      listenables: [String],
      factories: [
        () async {
          final duration = const Duration(seconds: 2);
          await Future.delayed(duration);
          return 'Hello world!';
        },
      ],
      loadingBuilder: (context) => const CircularProgressIndicator(),
      errorBuilder: (context, error) => Text('Error: $error'),
      builder: (context) => InkWell(
        onTap: () => context.emit<String>('Hello again!'),
        child: Text(context.get<String>()),
      ),
    );
  }
}
```

* If not use `loadingBuilder` or `errorBuilder`, is used `SizedBox.shrink()` respectivement.

## Addicional info

### Inject Example

```dart
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
```

## Creator Info

Olá, me chamo Lucas e sou criador deste pacote. Sou brasileiro e pretendo melhorar continuamente este pacote.
