.PHONY: install lint fmt pre-commit test

install:
	@./install --brew

lint:
	@pre-commit run --all-files || true

fmt:
	@pre-commit run --all-files || true

pre-commit:
	@pip install pre-commit && pre-commit install

test:
	@pytest -q

.PHONY: changelog
changelog:
	@which git-cliff >/dev/null 2>&1 && git-cliff -o CHANGELOG.md || echo "git-cliff not installed; skipping"

.PHONY: release
release:
	@if [ -z "$(VERSION)" ]; then echo "Usage: make release VERSION=vX.Y.Z MSG=\"message\""; exit 1; fi
	@git tag -a $(VERSION) -m "$(or $(MSG),$(VERSION))" && git push origin $(VERSION)
