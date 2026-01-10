class FCModel<V, E> {
  FCModel({required this.value, required this.loading, this.error});

  final V? value;
  final E? error;
  final bool loading;
}
