class Product {
  final String image, title, text;
  final int id;

  Product({
    required this.id,
    required this.image,
    required this.title,
    required this.text,
  });
}

List<Product> products = [
  Product(
    id: 1,
    title: "高品質でおしゃれなロゴデザイン・作成依頼を作成することが可能です。",
    text:
        "ロゴが必要になった時は、スキ街のデザイナーに作成依頼してみませんか。会社やお店のロゴが、オリジナルデザインで本格的なロゴデザインを作ってもらえます。",
    image: "assets/images/hpcreate_image.png",
  ),
  Product(
    id: 2,
    title: "Webマーケティング・集客に関する相談ならこちら。いわゆるSEO内部対策・外部対策を相談できます。",
    text: "",
    image: "assets/images/worries_image.png",
  ),
  Product(
    id: 3,
    title: "動画制作　動画・アニメーション制作や写真の加工や画像編集を依頼できます。",
    text: "",
    image: "assets/images/movie_image.jpeg",
  ),
  Product(
    id: 4,
    title: "写真撮影・素材提供　あなたが欲しい風景、地域の写真の撮影代行をお願いできます。",
    text: "",
    image: "assets/images/camera_image.jpeg",
  ),
  Product(
    id: 5,
    title: "音楽・ナレーション　作曲・アレンジ、音声編集、BGMや効果音の作成までお願いできます",
    text: "",
    image: "assets/images/mic_image.jpeg",
  ),
  Product(
    id: 6,
    title: "Webサイト制作・Web開発 ウェブデザイン、サイト修正の外注依頼できます。フリーランスや制作情報で簡単に比較検討できます。",
    text: "",
    image: "assets/images/work_image.webp",
  ),
];
