.PHONY: install lint fmt pre-commit test doctoc

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

doctoc:
	@echo "Generating table of contents for all markdown files..."
	@command -v doctoc >/dev/null 2>&1 || { echo "doctoc not installed. Installing..."; npm install -g doctoc; }
	@find . -name "*.md" \
		-not -path "*/node_modules/*" \
		-not -path "*/.git/*" \
		-not -path "*/vendor/*" \
		-not -path "*/vim/plugged/*" \
		-exec doctoc --github --notitle {} \;
	@echo "✓ Table of contents generated successfully!"

.PHONY: changelog
changelog:
	@which git-cliff >/dev/null 2>&1 && git-cliff -o CHANGELOG.md || echo "git-cliff not installed; skipping"

.PHONY: release
release:
	@if [ -z "$(VERSION)" ]; then echo "Usage: make release VERSION=vX.Y.Z MSG=\"message\""; exit 1; fi
	@git tag -a $(VERSION) -m "$(or $(MSG),$(VERSION))" && git push origin $(VERSION)
