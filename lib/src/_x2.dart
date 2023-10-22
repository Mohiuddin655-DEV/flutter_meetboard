part of '../flutter_meetboard.dart';

class _X2 extends StatefulWidget {
  const _X2({
    super.key,
  });

  @override
  State<_X2> createState() => _X2State();
}

class _X2State extends State<_X2> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _BoardItem(
          width: double.infinity,
          height: double.infinity,
          background: Colors.green.withOpacity(0.1),
        ),
        const Positioned(
          right: 0,
          child: ContributorCardAsShort(),
        ),
      ],
    );
  }
}
