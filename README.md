# Dart License Checker

A script to show licences of dependencies in plain text that can be used in github actions.

```

barbecue | Apache 2.0
pana | BSD
path | BSD
pubspec_parse | BSD

```

## Install  and run Locally

`flutter pub global activate license_checker_for_github_action`

- Make sure you are in the main directory of your Flutter app or Dart program
- Execute `dart_license_checker`

If this doesn't work, you may need to set up your PATH (see https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path)

## Github action
      - name: Check licenses install 
        run: | 
          dart pub global activate license_checker_for_github_action 
      - name: Check licenses
        run: | 
          dart_license_checker

## Showing transitive dependencies

By default, `dart_license_checker` only shows immediate dependencies (the packages you list in your `pubspec.yaml`).

If you want to analyze transitive dependencies too, you can use the `--show-transitive-dependencies` flag:

`dart_license_checker --show-transitive-dependencies`

If you want to output only copyleft dependencies use `--only-copyleft` flag:

`dart_license_checker --only-copyleft`

If you want to output an error if your licenses contain a copyleft license (such as in a github action) add `--fail-on-copyleft` flag:

`dart_license_checker --fail-on-copyleft`

In conjunction with `--only-copyleft` or `--fail-on-copyleft` flag, you might want to ignore some libraries. To do this use `--ignores`:

`dart_license_checker --fail-on-copyleft --ignores 'nm, lib2'`
