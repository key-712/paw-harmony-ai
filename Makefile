.PHONY: test

# 環境変数のデフォルト値
FASTLANE_USER ?= 
FASTLANE_PASSWORD ?= 
MATCH_KEYCHAIN_PASSWORD ?= 
MATCH_PASSWORD ?= 

FIREBASE_PROJECT_ID=crelve-paw-harmony-ai
APP_ID=crelve.pawHarmonyAi.mobile
PREVIOUS_FLAVOR := $(shell cat previous_flavor.txt)

test:
	sh script/gen_coverage_test.sh
# 	テスト時の環境変数を変更したい場合は、test.envを編集してください。
	fvm flutter test --coverage --dart-define-from-file=dart_env/test.env
	genhtml coverage/lcov.info -o coverage/html
	open coverage/html/index.html

run:
	echo $(FLAVOR) > previous_flavor.txt
	fvm flutter run -d all --dart-define-from-file=dart_env/$(FLAVOR).env

build-ipa:
ifndef BUILD_NUMBER
	fvm flutter build ipa --export-options-plist=ios/ExportOptions$(EXPORT_OPTIONS_SUFFIX).plist --dart-define-from-file=dart_env/$(FLAVOR).env
else
	fvm flutter build ipa --export-options-plist=ios/ExportOptions$(EXPORT_OPTIONS_SUFFIX).plist --dart-define-from-file=dart_env/$(FLAVOR).env --build-number=$(BUILD_NUMBER)
endif

build-aab:
ifndef BUILD_NUMBER
	fvm flutter build appbundle --dart-define-from-file=dart_env/$(FLAVOR).env
else
	fvm flutter build appbundle --dart-define-from-file=dart_env/$(FLAVOR).env --build-number=$(BUILD_NUMBER)
endif

release:
	fastlane release_$(FLAVOR) --env

release-ios:
	cd ios && MATCH_KEYCHAIN_PASSWORD=$(MATCH_KEYCHAIN_PASSWORD) MATCH_PASSWORD=$(MATCH_PASSWORD) APP_STORE_CONNECT_KEY_PATH=$(APP_STORE_CONNECT_KEY_PATH) bundle exec fastlane release_ios_$(FLAVOR) env:$(FLAVOR)

release-android:
	bundle exec fastlane release_android_$(FLAVOR) --env
# flutter build appbundle

create-launcher-icon:
	fvm flutter pub run flutter_launcher_icons -f launcher_icon/setting/$(FLAVOR).yaml

create-native-splash:
	fvm dart run flutter_native_splash:create

gen-firebase-config:
# rm -f ios/firebase_app_id_file.json
	rm -f android/app/google-services.json
	rm -f ios/Runner/GoogleService-Info.plist
	rm -f lib/firebase_options.dart
	fvm flutter pub get
	fvm dart pub global run flutterfire_cli:flutterfire configure \
		--yes \
		--project=$(FIREBASE_PROJECT_ID)$(FIREBASE_PROJECT_ID_SUFFIX) \
		--platforms=android,ios \
		--android-package-name=$(APP_ID)$(APP_ID_SUFFIX) \
		--ios-bundle-id=$(APP_ID)$(APP_ID_SUFFIX)

sync-code-signing:
	cd ios && MATCH_KEYCHAIN_PASSWORD=$(MATCH_KEYCHAIN_PASSWORD) MATCH_PASSWORD=$(MATCH_PASSWORD) FASTLANE_USER=$(FASTLANE_USER) FASTLANE_PASSWORD=$(FASTLANE_PASSWORD) bundle exec fastlane read_code_signing env:$(CODE_SIGNING_ENV) run_mode:$(RUN_MODE)
	
upload-file:
	keytool -genkey -v -keystore ./key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

clean:
	fvm flutter clean
	
setup:
	fvm flutter clean
	fvm dart pub get && fvm dart run build_runner build --delete-conflicting-outputs
	fvm flutter pub get
	fvm flutter precache --ios && cd ios && pod install --repo-update
	fvm flutter gen-l10n
	fvm dart pub get

update-gen:
	fvm flutter clean
	fvm dart pub get
	fvm flutter gen-l10n

open-widgetbook:
	fvm dart run build_runner build --delete-conflicting-outputs
	fvm flutter run -t ./lib/widgetbook/main.dart -d Chrome

run-dev:
ifneq ($(PREVIOUS_FLAVOR), dev)
	make create-launcher-icon FLAVOR=dev
	make gen-firebase-config FIREBASE_PROJECT_ID_SUFFIX=-dev APP_ID_SUFFIX=.dev
endif
	make run FLAVOR=dev

run-prod:
ifneq ($(PREVIOUS_FLAVOR), prod)
	make create-launcher-icon FLAVOR=prod
	make gen-firebase-config FIREBASE_PROJECT_ID_SUFFIX=-prod APP_ID_SUFFIX=.prod
endif
	make run FLAVOR=prod

release-prod-ios:
ifndef BUILD_NUMBER
	@echo エラー：release-prod-iosを実行する際は、BUILD_NUMBERを引数に指定してください！
else
	make clean && make setup
	make create-launcher-icon FLAVOR=prod
	# make sync-code-signing CODE_SIGNING_ENV=prod  # 一時的に無効化
	make build-ipa EXPORT_OPTIONS_SUFFIX=prod FLAVOR=prod BUILD_NUMBER=$(BUILD_NUMBER)
	cd ios && MATCH_PASSWORD=$(MATCH_PASSWORD) APP_STORE_CONNECT_KEY_PATH=./keys/AuthKey_$(APP_STORE_CONNECT_KEY_ID).p8 bundle exec fastlane release_ios_prod
endif

release-prod-android:
ifndef BUILD_NUMBER
	@echo エラー：release-prod-androidを実行する際は、BUILD_NUMBERを引数に指定してください！
else
	make clean && fvm flutter pub get && fvm flutter pub run build_runner build --delete-conflicting-outputs
	make create-launcher-icon FLAVOR=prod
	make build-aab FLAVOR=prod BUILD_NUMBER=$(BUILD_NUMBER)
	make release-android FLAVOR=prod
endif

set-deploy:
# https://qiita.com/masaibar/items/c378b4f01b707ac2506a
		firebase init
		echo google.com, pub-2443502666087876, DIRECT, f08c47fec0942fa0 > public/app-ads.txt
