<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

This package was made to facilitate State manipulation. Basically, you just need to add the State Type to the context to manipulate it via the context itself.

## Features

- You can create a Type provider via the FullContext Widget;
- In FullContext's children you can manipulate States through their Type in the Context.

## Getting started

Add type provider and create a type:

```dart
Widget build(BuildContext context) => FullContext(
    onInit: (context) => context.set<int>(1),
    builder: (context) => YourWidget(),
);
```

## Usage

When you have a FullContext as a parent directly or indirectly with the Type you want to use started:

```dart
Widget build(BuildContext context) => InkWell(
    onTap: () => context.emit<int>(context.get<int>() + 1),
    child: FCBuilder<int>((context, snapshot) =>
        snapshot.hasData
        ? Text(snapshot.data!)
        : const CircularProgressIndicator(),
    )
);
```

Besides `context.set<S>(state)`, `context.emit<S>(state)` and `context.get<S>()`, we have:

- `context.get$<S>()` which returns `ValueStream<S>`;
- `context.init<S>()` starts type `S` without initial state. Remember that `context.get<S>()` only works after the first `context.emit<S>(state)`;
- `context.emitError<S, E>(E error, [StackTracer? stackTracer])`;
- `context.close<S>()` Closes `S` stream.


## Additional information

Olá, me chamo Lucas, o criador deste pacote. Sou brasileiro e pretendo adicionar Factories nesse projeto após, é claro, tornar o que já tem hoje mais sucinto.

### Metas para o futuro

- Adicionar Factories;
- Criar testes automatizados;
- Criar um exemplo decente.

Tenho em mente tornar esse projeto igual o Services do ASP.NET CORE, com a única diferença de criar na mão as instâncias com o context.
