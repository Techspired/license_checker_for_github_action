import 'dart:convert';
import 'dart:io';

import 'package:pana/pana.dart';
import 'package:pana/src/license.dart';
import 'package:path/path.dart';

const possibleLicenseFileNames = [
  // LICENSE
  'LICENSE',
  'LICENSE.md',
  'license',
  'license.md',
  'License',
  'License.md',
  // LICENCE
  'LICENCE',
  'LICENCE.md',
  'licence',
  'licence.md',
  'Licence',
  'Licence.md',
  // COPYING
  'COPYING',
  'COPYING.md',
  'copying',
  'copying.md',
  'Copying',
  'Copying.md',
  // UNLICENSE
  'UNLICENSE',
  'UNLICENSE.md',
  'unlicense',
  'unlicense.md',
  'Unlicense',
  'Unlicense.md',
];

///The main entrypoint of the script
void main(List<String> arguments) async {
  final showTransitiveDependencies =
      arguments.contains('--show-transitive-dependencies');
  //show only copylefted dependencies
  final onlyLeft = arguments.contains('--only-copyleft');
  //exit 1 if you have a copylefted dependency
  final failOnLeft = arguments.contains('--fail-on-copyleft');
  var ignores = <String>[];
  //try to parse the passed ignores
  try {
    if (arguments.contains('--ignores')) {
      var unparsed = arguments[arguments.indexOf('--ignores') + 1];

      ignores = unparsed.split(', ');
    }
  } catch (e) {
    stderr.writeln(e);
    //if we can't parse the ignores, we exit. The rest of the line may be malformed
    exit(1);
  }

  final pubspecFile = File('pubspec.yaml');

  if (!pubspecFile.existsSync()) {
    stderr.writeln('pubspec.yaml file not found in current directory');
    exit(1);
  }

  final pubspec = Pubspec.parseYaml(pubspecFile.readAsStringSync());

  final packageConfigFile = File('.dart_tool/package_config.json');

  if (!pubspecFile.existsSync()) {
    stderr.writeln(
      '.dart_tool/package_config.json file not found in current directory. You may need to run "flutter pub get" or "pub get"',
    );
    exit(1);
  }

  final packageConfig = json.decode(packageConfigFile.readAsStringSync());

  final rows = <String>[];
  final copyleftRows = <String>[];

  for (final package in packageConfig['packages']) {
    final name = package['name'];

    if (!showTransitiveDependencies) {
      if (!pubspec.dependencies.containsKey(name)) {
        continue;
      }
    }

    String rootUri = package['rootUri'];
    if (rootUri.startsWith('file://')) {
      if (Platform.isWindows) {
        rootUri = rootUri.substring(8);
      } else {
        rootUri = rootUri.substring(7);
      }
    }

    LicenseFile? license;

    for (final fileName in possibleLicenseFileNames) {
      final file = File(join(rootUri, fileName));
      if (file.existsSync()) {
        // ignore: invalid_use_of_visible_for_testing_member
        license = await detectLicenseInFile(file, relativePath: file.path);
        break;
      }
    }

    //create the lines
    //we are not using table format because it is not supported in containers
    if (license != null) {
      if (copyleftOrProprietaryLicenses.contains(license.name) &&
          !ignores.contains(name)) {
        copyleftRows.add(
          name + '|' + license.name,
        );
      }
      rows.add(
        name + '|' + license.name,
      );
    } else {
      rows.add(
        name + '| no license file',
      );
    }
  }

  //print the licenses
  if (onlyLeft && copyleftRows.isNotEmpty) {
    for (var element in copyleftRows) {
      stdout.writeln(element);
    }
  } else if (!onlyLeft && rows.isNotEmpty) {
    for (var element in rows) {
      stdout.writeln(element);
    }
  }
  //now we fail if there was a copylefted dependency and the
  //fail flag is on
  if (failOnLeft && copyleftRows.isNotEmpty) {
    stderr.writeln('You have copylefted dependencies');
    stderr.writeln(
      copyleftRows,
    );
    exit(1);
  }
//exit without error, we are done
  exit(0);
}

const permissiveLicenses = [
  'MIT',
  'BSD',
  'BSD-1-Clause',
  'BSD-2-Clause-Patent',
  'BSD-2-Clause-Views',
  'BSD-2-Clause',
  'BSD-3-Clause-Attribution',
  'BSD-3-Clause-Clear',
  'BSD-3-Clause-LBNL',
  'BSD-3-Clause-Modification',
  'BSD-3-Clause-No-Military-License',
  'BSD-3-Clause-No-Nuclear-License-2014',
  'BSD-3-Clause-No-Nuclear-License',
  'BSD-3-Clause-No-Nuclear-Warranty',
  'BSD-3-Clause-Open-MPI',
  'BSD-3-Clause',
  'BSD-4-Clause-Shortened',
  'BSD-4-Clause-UC',
  'BSD-4-Clause',
  'BSD-Protection',
  'BSD-Source-Code',
  'Apache',
  'Apache-1.0',
  'Apache-1.1',
  'Apache-2.0',
  'Unlicense',
];

const copyleftOrProprietaryLicenses = [
  'MPL',
  'LGPL',
  'AGPL',
  'MPL-1.0',
  'MPL-2.0',
  'GPL',
  'GPL-1.0',
  'GPL-2.0',
  'GPL-3.0',
];
