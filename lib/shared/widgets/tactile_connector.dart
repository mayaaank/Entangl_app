import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TactileConnector extends StatelessWidget {
  final double height;

  const TactileConnector({super.key, this.height = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: SizedBox(
          width: 8,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 1.5, color: AppColors.outline),
              Align(
                alignment: Alignment.topCenter,
                child: _node(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _node(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _node() {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline, width: 1.5),
      ),
    );
  }
}
