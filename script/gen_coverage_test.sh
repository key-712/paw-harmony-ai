#!/bin/sh

outputFile="$(pwd)/test/coverage_test.dart"
packageName="$(cat pubspec.yaml | grep '^name: ' | awk '{print $2}')"

echo "/// *** 自動生成ファイル - 更新したい場合は script/gen_coverage_test.sh を実行してください *** ///\n" > "$outputFile"
echo "// ignore_for_file: unused_import" >> "$outputFile"
find lib/import -name '*.dart' | awk -v package=$packageName '{gsub("^lib", "", $1); printf("import '\''package:%s%s'\'';\n", package, $1);}' >> "$outputFile"
echo "\nvoid main() {}" >> "$outputFile"
