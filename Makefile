.PHONY: init test test-root test-example analyze push

FLUTTER ?= flutter
DART ?= dart

init:
	$(FLUTTER) pub get
	cd example && $(FLUTTER) pub get

test:
	$(MAKE) test-root
	$(MAKE) test-example
	$(MAKE) analyze

test-root:
	$(FLUTTER) test

test-example:
	cd example && $(FLUTTER) test

analyze:
	$(DART) analyze

push: test
	git add .
	git commit -m "$(shell date '+%Y-%m-%d %H:%M')" || true
	git push
