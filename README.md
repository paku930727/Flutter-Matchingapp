# sukimachi

#　バージョン
Flutter 2.10.4
Dart 2.16.2

#　 Flutter Web ビルド方法　有効にする場合のコマンドはこちら）
flutter config --enable-web

# ビルドコマンド

flutter run もしくは flutter run --debug

## 環境分け
環境分けはFlavorとurlの両方で行っている。
localhostでビルドする場合は下記の通りにportを指定する必要がある。

### GoogleSignInを利用する場合
GoogleSignInではオリジン検証で登録しているURLからのアクセスのみを通す。
本番環境はhttps://localhost:3334 と https://sukimachi.app
開発環境はhttps://localhost:3333 と https://sukimachi-dev-58429.web.app

[参考記事](https://qiita.com/corocn/items/f420f32a1633f2c97b1d)

### フレーバーによる環境分け
開発 --dart-define=FirebaseEnvironment=develop
本番 --dart-define=FirebaseEnvironment=product
エミュレータ --dart-define=FirebaseEnvironment=emulator

# git clone 後にエラーが発生する場合

pubspec.yaml で flutter pub get を実行する


# ディレクトリ構成(lib以下)
一旦はこんな感じで考えています。それぞれのディレクトリの役割は[こちら](https://docs.google.com/spreadsheets/d/1vCbzY4hFzXwjeoGU27Q48cX_sEaEtEnDqxemHZ4jc3c/edit#gid=785666307)

```
lib
├── main.dart
├── config
├── domain
├── exception
├── extension
├── repository
└── presentation
    ├── AA
    │   ├── aa_page.dart
    │   └── aa_model.dart
    ├── BB
    ├── CC

```


# Flutter-Matching
