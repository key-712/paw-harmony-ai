import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _NoWithOpacityPlugin();

class _NoWithOpacityPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        NoWithOpacityRule(),
      ];
}

class NoWithOpacityRule extends DartLintRule {
  NoWithOpacityRule() : super(code: _code);

  static const _code = LintCode(
    name: 'no_with_opacity',
    problemMessage: '`withOpacity()` is not allowed. Use `withValues(alpha:)` instead.',
    correctionMessage: 'Replace with `withValues(alpha:)`.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name == 'withOpacity') {
        reporter.reportErrorForNode(_code, node);
      }
    });
  }
}
