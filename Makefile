.PHONY: help init validate fmt fmt-check test lint clean install-tools

# Default target
help: ## Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install-tools: ## Install required tools
	@echo "Installing required tools..."
	@command -v terraform >/dev/null 2>&1 || { echo "Please install Terraform"; exit 1; }
	@command -v pre-commit >/dev/null 2>&1 || pip install pre-commit
	@command -v terraform-docs >/dev/null 2>&1 || { echo "Please install terraform-docs: https://terraform-docs.io/"; exit 1; }
	@command -v tflint >/dev/null 2>&1 || { echo "Please install tflint: https://github.com/terraform-linters/tflint"; exit 1; }
	@pre-commit install
	@echo "Tools installed successfully!"

init: ## Initialize Terraform
	@echo "Initializing Terraform..."
	@terraform init -backend=false

validate: init ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	@terraform validate

fmt: ## Format Terraform files
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive

fmt-check: ## Check if Terraform files are formatted
	@echo "Checking Terraform file formatting..."
	@terraform fmt -check -recursive

test: init ## Run Terraform tests (requires Azure credentials)
	@echo "Running Terraform tests..."
	@terraform test

lint: ## Run all linting tools
	@echo "Running pre-commit hooks..."
	@pre-commit run --all-files

docs: ## Generate documentation
	@echo "Generating documentation..."
	@terraform-docs markdown table --config .config/.terraform-docs.yml --output-file README.md --output-mode inject .

clean: ## Clean up temporary files
	@echo "Cleaning up..."
	@rm -rf .terraform
	@rm -f .terraform.lock.hcl
	@find . -type f -name "*.tfstate*" -delete
	@echo "Cleanup complete!"

pre-commit: fmt lint ## Run format and lint checks

all: init validate fmt-check lint ## Run all checks
	@echo "All checks passed!"
