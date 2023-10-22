part of '../flutter_meetboard.dart';

class Meetboard extends StatefulWidget {
  final List<Contributor> contributors;

  const Meetboard({
    super.key,
    required this.contributors,
  });

  @override
  State<Meetboard> createState() => _MeetboardState();
}

class _MeetboardState extends State<Meetboard> {
  int get contributorCount => widget.contributors.length;

  @override
  Widget build(BuildContext context) {
    var size = widget.contributors.length;
    if (size == 1) {
      return _BoardItem(
        width: double.infinity,
        height: double.infinity,
        background: Colors.red.withOpacity(0.1),
      );
    } else if (size == 2) {
      return const _X2();
    } else {
      return const SizedBox();
    }
  }
}
