from flask import Flask, request, jsonify
import jq
import os

app = Flask(__name__)

# Directory where jq policies are stored
POLICY_DIR = "policies"

# Function to apply jq policies to the incoming JSON request
def check_policies(json_input):
    for policy_file in os.listdir(POLICY_DIR):
        if policy_file.endswith(".jq"):
            policy_path = os.path.join(POLICY_DIR, policy_file)
            try:
                with open(policy_path, 'r') as pf:
                    policy = jq.compile(pf.read())
                result = policy.input(json_input).all()
                
                # If the result is non-empty, consider it a policy failure and halt
                if result:
                    return False, policy_file, result
            except jq.JQError as e:
                return False, policy_file, str(e)

    return True, None, None

@app.route("/validate", methods=["POST"])
def validate():
    json_input = request.json
    is_valid, failed_policy, details = check_policies(json_input)

    if not is_valid:
        return jsonify({
            "status": "failure",
            "failed_policy": failed_policy,
            "details": details
        }), 403  # Return HTTP 403 Forbidden if validation fails

    return jsonify({"status": "success"}), 200  # Return HTTP 200 OK if validation passes

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

