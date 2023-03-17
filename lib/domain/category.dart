class Category {
  Category({
    required this.name,
    required this.number,
  });

  String name;
  int number;

  factory Category.fromJson(Map data) {
    return Category(
      name: data['name'],
      number: data['number'],
    );
  }
}
