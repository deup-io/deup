# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
-  hide subtitle item when time is not matching


## [2.1.0] - 22/05/2022.

- **BREAKING**: Name changed from `SubTitleWrapper` to `SubtitleWrapper`.
- Code quality improvements and refactoring.

## [2.0.3] - 21/05/2022.

- Added possibility to add background color to the text.
- After the last subtitle item the text will be removed.

## [2.0.2] - 21/05/2022.

- Updated dependencies. 
- Resolved minor lint issues.

## [2.0.1] - 15/04/2021.

- Changed all pre-release package versions to release ones.

## [2.0.0] - 7/03/2021.

- Migrated to sound null safety.
- Cleaned up null safety code and typing.
- Fixed some deprecation issues.
- Changed linting rules to be stricter.

## [2.0.0-nullsafety.0] - 3/02/2021.

- Migrated to sound null safety.
- Fixed some deprecation issues.

## [1.0.4] - 27 november 2020.

- Added a check to see if content-types end with a semicolon 👀.  
- Added a fix for content-types that end with a semicolon 👨‍🔧.

## [1.0.3] - 6 october 2020.

- Added more tests and completer coverage.
- Added option to dynamically update the subtitles during playback. 
- Updated the readme to provide some better information.

## [1.0.2] - 2 august 2020.

- Added unit tests and code coverage to the package.
- Added a MIT licence to the package.
- Implemented BLoC pattern for handling subtitles and state changes.
- Added support for loading local subtitles by using subtitle content on the controller.
- Added support for srt.

## [1.0.1] - 2 august 2020.

- Added unit tests and code coverage to the package.
- Implemented BLoC pattern for handling subtitles and state changes.
- Added support for loading local subtitles by using subtitle content on the controller.
- Added support for srt.

## [1.0.0] - 1 august 2020.

- Implemented BLoC pattern for handling subtitles and state changes.
- Added support for loading local subtitles by using subtitle content on the controller.
- Added support for srt.

## [0.1.6] - 26 june 2020.

- Added support to select an specific decoder. Defaults to utf8
- Added support for dynamic setting of decoder depending on server site charset, Defaults to utf8
- Fixed issue related to fallback to utf8

## [0.1.5] - 26 june 2020.

- Added support to select an specific decoder. Defaults to utf8
- Added support for dynamic setting of decoder depending on server site charset, Defaults to utf8

## [0.1.4] - 25 june 2020.

- Added support to select an specific decoder. Defaults to utf8

## [0.1.3] - 24 june 2020.

- Fixed issue with special text items

## [0.1.2] - 23 june 2020.

- Fixed issue with special text items

## [0.1.1] - 24 april 2020.

- Fixed issue with special text items

## [0.1.0] - 24 april 2020.

- Fixed issue with multiple lines

## [0.0.10] - 14 feb 2020.

- Added stripping for most tags
- Fixed numbers not showing in subtitles.

## [0.0.9] - Feb 7, 2020.

- Fixed issue with regex

## [0.0.8] - Feb 7, 2020.

- Fixed issue with regex

## [0.0.7] - 10 dec 2019.

- Fixed issue with regex

## [0.0.6] - 10 dec 2019.

- Fixed issue with regex

## [0.0.5] - 02 oct 2019.

- Updated readme 

## [0.0.4] - 02 oct 2019.

- Fix for empty lines
- No default bool for show subs

## [0.0.3] - 02 oct 2019.

- Added styling options for subtitles 
- Added positioning for subtitles 

## [0.0.2] - 02 oct 2019.

- Fixed regex problem for vtt

## [0.0.1] - 01 oct 2019.

- initial release.
