# Contributing to terraform-azurerm-application-gateway

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for details.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/terraform-azurerm-application-gateway.git`
3. Add the upstream remote: `git remote add upstream https://github.com/aztfm/terraform-azurerm-application-gateway.git`
4. Create a new branch: `git checkout -b feature/your-feature-name`

## Development Setup

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.9.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [pre-commit](https://pre-commit.com/) for code quality checks
- [terraform-docs](https://terraform-docs.io/) for documentation generation
- [tflint](https://github.com/terraform-linters/tflint) for linting

### Using Dev Container

This repository includes a Dev Container configuration. If you use VS Code with the Remote-Containers extension:

1. Open the repository in VS Code
2. Click "Reopen in Container" when prompted
3. All dependencies will be automatically installed

### Manual Setup

```bash
# Install pre-commit hooks
pre-commit install

# Initialize Terraform
terraform init

# Validate the configuration
terraform validate

# Format the code
terraform fmt -recursive
```

## How to Contribute

### Reporting Bugs

Before creating a bug report:

- Check the existing issues to avoid duplicates
- Collect relevant information (Terraform version, Azure provider version, error messages, etc.)

Create a bug report with:

- Clear and descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Relevant logs and error messages
- Your environment details

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:

- Use a clear and descriptive title
- Provide a detailed description of the proposed functionality
- Include examples of how the feature would be used
- Explain why this enhancement would be useful

### Code Contributions

1. Ensure your code follows the [Coding Standards](#coding-standards)
2. Add or update tests as needed
3. Update documentation to reflect your changes
4. Run all tests and validation checks
5. Submit a pull request

## Pull Request Process

1. **Update your branch**: Sync with the upstream main branch before submitting
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run pre-commit checks**: Ensure all checks pass
   ```bash
   pre-commit run --all-files
   ```

3. **Test your changes**: Run Terraform validation and tests
   ```bash
   terraform init -backend=false
   terraform validate
   terraform test  # If you have Azure credentials configured
   ```

4. **Update documentation**: If your PR changes functionality, update:
   - README.md (if applicable)
   - CHANGELOG.md (add entry under "Unreleased" section)
   - Code comments
   - The documentation will be auto-generated via terraform-docs

5. **Create Pull Request**:
   - Use a clear and descriptive title
   - Reference any related issues
   - Describe what your changes do and why
   - Include screenshots for UI changes (if applicable)

6. **Code Review**: Address reviewer feedback and make necessary changes

7. **Merge**: Once approved, a maintainer will merge your PR

## Coding Standards

### Terraform Style

- Follow [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- Use `terraform fmt` to format your code
- Use meaningful resource and variable names
- Add descriptions to all variables and outputs
- Use validation blocks for input variables where appropriate

### File Organization

```
.
├── main.tf              # Main resource definitions
├── variables.tf         # Input variables with descriptions and validations
├── outputs.tf           # Output values with descriptions
├── versions.tf          # Provider version constraints
├── README.md            # Module documentation
├── CHANGELOG.md         # Version history
├── examples/            # Usage examples
│   └── example-name/
│       ├── main.tf
│       ├── providers.tf
│       └── version.tf
└── tests/              # Test files
    └── *.tftest.hcl
```

### Naming Conventions

- Use lowercase with underscores for resource names: `resource_name`
- Use descriptive names that indicate purpose
- Prefix internal/private resources with underscore: `_internal_resource`
- Use consistent naming across similar resources

### Variable Validation

Add validation blocks to variables when possible:

```hcl
variable "example" {
  type        = string
  description = "Example variable"
  
  validation {
    condition     = length(var.example) > 0
    error_message = "The example variable must not be empty."
  }
}
```

## Testing

### Unit Tests

This module uses Terraform's native testing framework:

```bash
terraform test
```

Tests are located in the `tests/` directory and use the `.tftest.hcl` extension.

### Manual Testing

When testing manually:

1. Create a test environment in Azure
2. Apply the module with test configuration
3. Verify resources are created correctly
4. Clean up resources after testing

### Pre-commit Checks

Before committing, pre-commit runs:

- Terraform format check
- Terraform validation
- Documentation generation
- Markdown linting
- TFLint checks

## Documentation

- All public variables must have a `description`
- All outputs must have a `description`
- Update examples when adding new features
- Use terraform-docs format for consistency
- Keep README.md up to date

Documentation is auto-generated using terraform-docs. The configuration is in `.config/.terraform-docs.yml`.

## Questions?

If you have questions:

- Check existing issues and discussions
- Review the README.md and examples
- Create a new issue with the "question" label

Thank you for contributing!
