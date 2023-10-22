part of '../flutter_meetboard.dart';

class ContributorCardAsShort extends StatelessWidget {
  const ContributorCardAsShort({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 1 / 1.5,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
