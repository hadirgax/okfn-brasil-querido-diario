PROJECT_NAME ?= querido-diario
CONDAENV_NAME ?= $(PROJECT_NAME)
CONDAENV_BIN_PATH ?= $$(conda info --base)/envs/$(CONDAENV_NAME)/bin
SRC_DIRS := ./data_collection

ISORT_ARGS := --combine-star --combine-as --order-by-type --thirdparty scrapy --multi-line 3 --trailing-comma --force-grid-wrap 0 --use-parentheses --line-width 88

export PYTHONPATH := .:./data_collection

# ===== Environment =====
env-create:
	conda create -n $(CONDAENV_NAME) -c conda-forge -y \
		python=3.10 \
		pip=24
	$(CONDAENV_BIN_PATH)/python -m pip install uv

env-install:
	$(CONDAENV_BIN_PATH)/python -m uv pip install -r $(SRC_DIRS)/requirements-dev.txt
	$(CONDAENV_BIN_PATH)/pre-commit install
	@echo "#\n# To activate this environment, use:\n#\n#\t$$ conda activate $(CONDAENV_NAME)"
	@echo "#\n# To deactivate an active environment, use:\n#\n#\t$$ conda deactivate"

env-remove:
	conda remove -n $(CONDAENV_NAME) --all -y

env-update:env-remove env-create env-install


# ===== Lint & Format =====

check:
	python3 -m isort --check --diff $(ISORT_ARGS) $(SRC_DIRS)
	python3 -m black --check $(SRC_DIRS)
	flake8 $(SRC_DIRS)

format:
	python3 -m isort --apply $(ISORT_ARGS) $(SRC_DIRS)
	python3 -m black $(SRC_DIRS)


# ===== Run =====

run_spider:
	cd $(SRC_DIRS) && scrapy crawl $(SPIDER)

sql:
	cd $(SRC_DIRS) && sqlite3 querido-diario.db

clean:
	find ./$(SRC_DIRS)/data/* -type d -exec rm -rv {} \;

shell:
	cd $(SRC_DIRS) && scrapy shell

run_spider_since:
	cd $(SRC_DIRS) && scrapy crawl -a start_date=$(START_DATE) $(SPIDER)

compile:
	cd data_collection; \
	pip-compile --upgrade --no-annotate --allow-unsafe --generate-hashes requirements.in; \
	pip-compile --upgrade --no-annotate --allow-unsafe --generate-hashes requirements-dev.in
