# jq-utils

This tool is designed to validate JSON configuration files against a set of policies defined using `jq`. It is especially useful for enforcing configuration policies in CI/CD pipelines and other automated workflows.

## Features

- **Policy Validation**: Check JSON configuration files against multiple `jq` policies.
- **Error Handling**: Detect and report `jq` syntax errors or runtime issues in policies.
- **Failure Detection**: Exit with a non-zero status if any policy fails or encounters an error.
- **Detailed Output**: Provides clear feedback on which policies passed, failed, or encountered errors.

## Requirements

- **jq**: A command-line JSON processor. Install it using your package manager (apt, yum, brew, etc.).
- **bash**: The script is written in bash, which is available on most Unix-like systems.

## Usage

### Command

```
./policy_checker.sh <json-input-file> <policy-directory>
```

### Parameters

- `<json-input-file>`: The path to the JSON file you want to validate.
- `<policy-directory>`: The directory containing your `jq` policy files.

### Example

Suppose you have a JSON file named `config.json` and a directory named `policies` containing your `jq` policies. You can run the script as follows:

```
./policy_checker.sh config.json policies
```

### Output

- **Policy Passed**: If a policy passes with no issues, the script will output:

  ```
  Policy policy_name.jq passed: No issues detected.
  ```

- **Policy Failed**: If a policy fails due to a misconfiguration, the script will output:

  ```
  Policy policy_name.jq failed: Misconfigurations detected.
  <details of the misconfiguration>
  ```

- **Policy Encountered an Error**: If there is a syntax error or runtime error in the policy, the script will output:

  ```
  Policy policy_name.jq encountered an error: Invalid jq syntax or runtime error.
  <jq error message>
  ```

### Summary

At the end of the script's execution, it will provide a summary of the results:
- The number of policies that failed.
- The number of policies that encountered errors.

The script will then exit with a status code:
- `0` if all policies passed without errors.
- `1` if any policy failed or encountered an error.

## Exit Codes

- `0`: All policies passed successfully.
- `1`: One or more policies failed or encountered errors.

## Adding New Policies

To add a new policy, simply create a `jq` script file in the `policy-directory`. The script will automatically pick up and run all `.jq` files in that directory.

### Example Policy

Here’s an example of a `jq` policy (`check_public_acl.jq`) that checks for public ACLs on S3 buckets in a Terraform plan:

```
.resource_changes[]
| select(.type == "aws_s3_bucket")
| select(.change.after.acl | test("public-read|public-read-write"))
| {address, acl: .change.after.acl}
```

Place this file in your `policies` directory and run the script as shown above.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

