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
