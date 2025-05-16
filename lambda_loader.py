import boto3

def handler(event, context):
    # Parse code bucket and key from the new event structure
    try:
        bucket = event["external_code_location"]["s3_code_bucket"]
        key = event["external_code_location"]["s3_code_key"]
    except (KeyError, TypeError):
        return {"error": "Invalid event format, missing external_code_location.s3_code_bucket or s3_code_key"}

    s3 = boto3.client("s3")
    download_path = "/tmp/lambda_function.py"

    try:
        s3.download_file(bucket, key, download_path)

        with open(download_path) as f:
            code = f.read()

        exec_env = {}
        exec(code, exec_env)

        if "handler" in exec_env:
            return exec_env["handler"](event, context)
        else:
            return {"error": "No handler() found in the downloaded file"}

    except Exception as e:
        return {"error": str(e)}
