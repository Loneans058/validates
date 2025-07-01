gen:
	dart run build_runner build -d

clean:
	flutter clean

create_splash_screen:
	dart run flutter_native_splash:create --path=flutter_native_splash.yaml

create_launcher_icons:
	dart run flutter_launcher_icons -f flutter_launcher_icons.yaml

.PHONY: build
build:
	flutter clean
	flutter pub get
	dart run build_runner build
	dart run intl_utils:generate
	flutter build web
	mkdir -p cmd/assets
	cp -r build/web/* cmd/assets

