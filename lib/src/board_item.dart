part of '../flutter_meetboard.dart';

class _BoardItem extends StatelessWidget {
  final double? width, height;
  final Color? background;

  const _BoardItem({
    super.key,
    this.width,
    this.height,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: background,
      ),
    );
  }
}
