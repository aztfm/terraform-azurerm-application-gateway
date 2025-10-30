# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 2.x.x   | :white_check_mark: |
| 1.x.x   | :x:                |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of our Terraform modules seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### How to Report

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of the following methods:

1. **GitHub Security Advisories** (Preferred)
   - Navigate to the [Security tab](https://github.com/aztfm/terraform-azurerm-application-gateway/security/advisories) of this repository
   - Click "Report a vulnerability"
   - Fill out the form with details about the vulnerability

2. **GitHub Issues** (For non-critical issues)
   - Create a new issue with the label `security`
   - Provide as much detail as possible while being mindful not to expose the vulnerability publicly

### What to Include

Please include the following information in your report:

- Type of vulnerability
- Full paths of source file(s) related to the manifestation of the vulnerability
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the vulnerability, including how an attacker might exploit it

### Response Timeline

- **Initial Response**: We will acknowledge your report within 48 hours
- **Status Update**: We will provide a more detailed response within 7 days, indicating the next steps
- **Resolution**: We aim to resolve critical vulnerabilities within 30 days

### What to Expect

After you submit a report:

1. We will confirm receipt of your vulnerability report
2. We will investigate and validate the vulnerability
3. We will work on a fix and coordinate disclosure timing with you
4. We will release a security advisory and patched version
5. We will publicly acknowledge your responsible disclosure (if you wish)

## Security Best Practices

When using this module, we recommend following these security best practices:

### 1. Access Control

- Use Azure RBAC to control who can modify Application Gateway resources
- Implement least privilege access principles
- Use Managed Identities where possible instead of service principals

### 2. SSL/TLS Configuration

- Always use TLS 1.2 or higher (`TLSv1_2` or `TLSv1_3`)
- Use strong cipher suites
- Regularly rotate SSL certificates
- Store certificates in Azure Key Vault, not in code or configuration files

### 3. Network Security

- Use Web Application Firewall (WAF) policies with the `WAF_v2` SKU
- Implement proper network segmentation
- Use private endpoints where appropriate
- Restrict access to Application Gateway management plane

### 4. Secrets Management

- **Never commit sensitive data** to version control:
  - SSL certificate data and passwords
  - Private keys
  - Connection strings
  - Access tokens
- Use Azure Key Vault for certificate storage
- Use Terraform sensitive variables and outputs appropriately
- Consider using `.tfvars` files (excluded from version control) for sensitive values

### 5. State File Security

- Store Terraform state files in a secure backend (e.g., Azure Storage with encryption)
- Enable state file encryption
- Restrict access to state files
- Never commit state files to version control

### 6. Module Version Pinning

- Pin module versions in production: `version = "2.1.0"` instead of `version = ">=2.0.0"`
- Review changelogs before upgrading versions
- Test upgrades in non-production environments first

### 7. Input Validation

- The module includes validation rules for inputs
- Additional validation in your root module is recommended
- Validate CIDR blocks, domain names, and other user inputs

### 8. Azure Policy Compliance

- Ensure your Application Gateway deployment complies with your organization's Azure Policies
- Use Azure Policy to enforce security standards
- Regularly audit your resources for compliance

### 9. Monitoring and Logging

- Enable diagnostic logging for Application Gateway
- Monitor for suspicious activity
- Set up alerts for security-related events
- Regularly review access logs

### 10. Dependency Management

- Regularly update the AzureRM provider version
- Review provider changelog for security updates
- Use Dependabot or similar tools to track dependency updates

## Known Security Considerations

### SSL Certificate Handling

This module supports two methods for SSL certificates:

1. **Azure Key Vault (Recommended)**: Certificates stored in Key Vault
   - More secure
   - Supports automatic certificate renewal
   - Requires Managed Identity

2. **Direct Certificate Data**: Certificates provided as base64-encoded data
   - Less secure
   - Risk of exposing certificate data
   - Use only for testing/development

### WAF Policy

- The `firewall_policy_id` parameter is required when using `WAF_v2` SKU
- Always use WAF for internet-facing Application Gateways
- Regularly review and update WAF rules

## Vulnerability Disclosure Policy

When we receive a security bug report, we will:

1. Confirm the problem and determine affected versions
2. Audit code to find similar problems
3. Prepare fixes for all supported versions
4. Release patches as quickly as possible

## Security Updates

Security updates will be published:

- In the [Security Advisories](https://github.com/aztfm/terraform-azurerm-application-gateway/security/advisories) section
- In the CHANGELOG.md file
- As GitHub releases with security tags

## Questions

If you have questions about this security policy, please create a GitHub issue with the `question` label.

## Attribution

This security policy is based on security best practices for Terraform modules and Azure resources.
