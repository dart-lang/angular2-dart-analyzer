import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/task/dart.dart';
import 'package:angular_analyzer_plugin/src/model.dart';
import 'package:angular_analyzer_plugin/src/tasks.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';
import 'package:unittest/unittest.dart';
import 'package:angular_analyzer_plugin/ast.dart';

import 'abstract_angular.dart';

main() {
  groupSep = ' | ';
  defineReflectiveTests(ConverterTest);
}

@reflectiveTest
class ConverterTest extends AbstractAngularTest {
  String dartCode;
  String htmlCode;
  Source dartSource;
  Source htmlSource;

  List<AbstractDirective> directives;

  Template template;
  List<ResolvedRange> ranges;

  void test_scratch() {
    _addDartSource(r'''
@Component(
    selector: 'name-panel',
    inputs: const ['aaa', 'bbb', 'ccc'])
@View(template: r"<div>AAA</div>")
class NamePanel {
  int aaa;
  int bbb;
  int ccc;
}
@Component(selector: 'test-panel')
@View(templateUrl: 'test_panel.html', directives: const [NamePanel])
class TestPanel {}
''');
    _addHtmlSource(r"""
<name-panel aaa='1' [bbb]='2' bind-ccc='3'></name-panel>
""");
    _resolveSingleTemplate(dartSource);
    ResolvedRange resolvedRange1 = _findResolvedRange("bbb]=");
    ResolvedRange resolvedRange2 = _findResolvedRange('ccc=');
    print(resolvedRange2);
  }

  void _addDartSource(String code) {
    dartCode = '''
import '/angular2/angular2.dart';
$code
''';
    dartSource = newSource('/test_panel.dart', dartCode);
  }

  void _addHtmlSource(String code) {
    htmlCode = code;
    htmlSource = newSource('/test_panel.html', htmlCode);
  }

  void _resolveSingleTemplate(Source dartSource) {
    directives = computeLibraryDirectives(dartSource);
    List<View> views = computeLibraryViews(dartSource);
    View view = views.last;
    // resolve this View
    computeResult(view, HTML_TEMPLATE);
    template = outputs[HTML_TEMPLATE];
    ranges = template.ranges;
    fillErrorListener(HTML_TEMPLATE_ERRORS);
  }

  ResolvedRange _findResolvedRange(String search,
      [ResolvedRangeCondition condition]) {
    return getResolvedRangeAtString(htmlCode, ranges, search, condition);
  }
}
