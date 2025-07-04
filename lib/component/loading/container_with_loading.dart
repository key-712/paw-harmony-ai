import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/provider.dart';

/// 引数で渡したWidgetにローディング表示機能を追加するWidget
class ContainerWithLoading extends ConsumerWidget {
  /// 引数で渡したWidgetにローディング表示機能を追加するWidget
  const ContainerWithLoading({
    super.key,
    required this.child,
  });

  /// 子Widget
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingStateProvider);

    return Stack(
      children: [
        child,
        isLoading ? const Loading() : const SizedBox(),
      ],
    );
  }
}
