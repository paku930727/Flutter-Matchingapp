import 'package:flutter/material.dart';
import 'package:sukimachi/domain/product.dart';
import 'package:sukimachi/presentation/home/components/product.dart';
import '../../constants.dart';

class BodyContainer extends StatelessWidget {
  const BodyContainer({
    Key? key,
    required this.content,
  }) : super(key: key);

  final Widget content;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      constraints: const BoxConstraints(maxWidth: kMaxWidth),
      child: content,
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    this.crossAxiscount = 3,
    this.aspectRatio = 1.1,
  }) : super(key: key);
  final int crossAxiscount;
  final double aspectRatio;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxiscount,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, index) => Products(
        press: () {},
        product: products[index],
      ),
      itemCount: products.length,
    );
  }
}
