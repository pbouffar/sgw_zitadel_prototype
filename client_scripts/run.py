import requests
import json
import sys
import config
from generate_jwt import generate_jwt_token


def oauth_flow_jwt_access_token_with_client_credentials_authentication():

    # Request an access token using client credentials grant
    token_data = {
        'grant_type': 'client_credentials',
        'scope': 'openid profile'
    }
    # Use basic authentication for client_id and client_secret
    auth = (config.CLIENT_ID, config.CLIENT_SECRET)

    print("\nAccessing a secured endpoint....")
    try:
        print("Requesting JWT access token...")
    
        response = requests.post(config.TOKEN_URL, data=token_data, auth=auth)
        response.raise_for_status()  # Raise an HTTPError for bad responses (4xx or 5xx)
        token_response_json = response.json()
        access_token = token_response_json.get('access_token')

        if access_token:
            print("Access token obtained successfully.")
            # print(json.dumps(token_response_json, indent=2)) # Uncomment to see full token response

            # Access a secured endpoint using the obtained access token
            headers = {
                "Authorization": f"Bearer {access_token}"
            }
            secured_response = requests.get(config.SECURED_API, headers=headers)
            secured_response.raise_for_status()
            print(f"Secured endpoint response: {secured_response.text}")

        else:
            print("Failed to obtain access token. 'access_token' not found in response.")
            print(f"Full token response: {response.text}")

    except requests.exceptions.RequestException as e:
        print(f"An error occurred during token request: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"Response content: {e.response.text}")


def oauth_flow_opaque_access_token_with_client_credentials_authentication():

    # Request an access token using client credentials grant
    scope = f"openid profile urn:zitadel:iam:org:project:id:{config.PROJECT_ID}:aud"
    token_data = {
        'grant_type': 'client_credentials',
        'scope': scope
    }
    # Use basic authentication for client_id and client_secret
    auth = (config.CLIENT_ID_2, config.CLIENT_SECRET_2)

    print("\nAccessing a secured endpoint....")
    try:
        print("Requesting opaque access token...")
    
        response = requests.post(config.TOKEN_URL, data=token_data, auth=auth)
        response.raise_for_status()  # Raise an HTTPError for bad responses (4xx or 5xx)
        token_response_json = response.json()
        access_token = token_response_json.get('access_token')

        if access_token:
            print("Access token obtained successfully.")
            # print(json.dumps(token_response_json, indent=2)) # Uncomment to see full token response

            # Access a secured endpoint using the obtained access token
            headers = {
                "Authorization": f"Bearer {access_token}"
            }
            secured_response = requests.get(config.SECURED_API, headers=headers)
            secured_response.raise_for_status()
            print(f"Secured endpoint response: {secured_response.text}")

        else:
            print("Failed to obtain access token. 'access_token' not found in response.")
            print(f"Full token response: {response.text}")

    except requests.exceptions.RequestException as e:
        print(f"An error occurred during token request: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"Response content: {e.response.text}")


def oauth_flow_jwt_access_token_with_private_key_jwt_authentication():

    print("\nGenerating encoded JWT...")
    try:
        encoded_jwt = generate_jwt_token(config.SERVICE_USER_ID, config.PRIVATE_KEY, config.KEY_ID, config.ZITADEL_SERVER)
    except Exception as e:
        print(f"An unexpected error occurred while generating JWT: {e}", file=sys.stderr)
        return


    # Define the data for the POST request (JWT Bearer Token Grant)
    token_data = {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'scope': 'openid', # Requesting the 'openid' scope
        'assertion': encoded_jwt # The generated JWT
    }

    # Define the headers for the POST request
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }

    print("Accessing a secured endpoint....")
    try:
        # Make the POST request to the token endpoint
        print("Requesting JWT access token with JWT private key assertion...")
        response = requests.post(config.TOKEN_URL, data=token_data, headers=headers)
        response.raise_for_status()  # Raise an HTTPError for bad responses (4xx or 5xx)

        # Parse the JSON response
        token_response_json = response.json()
        access_token = token_response_json.get('access_token')

        if access_token:
            print("Access token obtained successfully.")
            # print(json.dumps(token_response_json, indent=2)) # Uncomment to see full token response

            # Set the Authorization header with the Bearer token
            auth_headers = {
                "Authorization": f"Bearer {access_token}"
            }
            # Make the GET request to the secured endpoint
            secured_response = requests.get(config.SECURED_API, headers=auth_headers)
            secured_response.raise_for_status()
            print(f"Secured endpoint response: {secured_response.text}")

        else:
            print("Failed to obtain access token. 'access_token' not found in response.")
            print(f"Full token response: {response.text}")

    except requests.exceptions.RequestException as e:
        print(f"An error occurred during token request or secured endpoint access: {e}", file=sys.stderr)
        if hasattr(e, 'response') and e.response is not None:
            print(f"Response content: {e.response.text}", file=sys.stderr)
        return # Exit if token acquisition or secured access fails


def oauth_flow_opaque_access_token_with_private_key_jwt_authentication():

    print("\nGenerating encoded JWT...")
    try:
        encoded_jwt = generate_jwt_token(config.SERVICE_USER_ID_2, config.PRIVATE_KEY_2, config.KEY_ID_2, config.ZITADEL_SERVER)
    except Exception as e:
        print(f"An unexpected error occurred while generating JWT: {e}", file=sys.stderr)
        return

    # Define the data for the POST request (JWT Bearer Token Grant)
    scope = f"openid profile urn:zitadel:iam:org:project:id:{config.PROJECT_ID}:aud"
    token_data = {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'scope': scope,
        'assertion': encoded_jwt # The generated JWT
    }

    # Define the headers for the POST request
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }

    print("Accessing a secured endpoint....")
    try:
        # Make the POST request to the token endpoint
        print("Requesting opaque access token with JWT private key assertion...")
        response = requests.post(config.TOKEN_URL, data=token_data, headers=headers)
        response.raise_for_status()  # Raise an HTTPError for bad responses (4xx or 5xx)

        # Parse the JSON response
        token_response_json = response.json()
        access_token = token_response_json.get('access_token')

        if access_token:
            print("Access token obtained successfully.")
            # print(json.dumps(token_response_json, indent=2)) # Uncomment to see full token response

            # Set the Authorization header with the Bearer token
            auth_headers = {
                "Authorization": f"Bearer {access_token}"
            }
            # Make the GET request to the secured endpoint
            secured_response = requests.get(config.SECURED_API, headers=auth_headers)
            secured_response.raise_for_status()
            print(f"Secured endpoint response: {secured_response.text}")

        else:
            print("Failed to obtain access token. 'access_token' not found in response.")
            print(f"Full token response: {response.text}")

    except requests.exceptions.RequestException as e:
        print(f"An error occurred during token request or secured endpoint access: {e}", file=sys.stderr)
        if hasattr(e, 'response') and e.response is not None:
            print(f"Response content: {e.response.text}", file=sys.stderr)
        return # Exit if token acquisition or secured access fails
    

def access_public_api():

    # Access a public endpoint
    print("\nAccessing a public endpoint....")
    try:
        public_response = requests.get(config.PUBLIC_API)
        public_response.raise_for_status()
        print(f"Public endpoint response: {public_response.text}")
    except requests.exceptions.RequestException as e:
        print(f"An error occurred during public endpoint request: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"Response content: {e.response.text}")


if __name__ == "__main__":
    oauth_flow_jwt_access_token_with_client_credentials_authentication()
    print("--------------------------------------------------------")
    oauth_flow_jwt_access_token_with_private_key_jwt_authentication()
    print("--------------------------------------------------------")
    oauth_flow_opaque_access_token_with_client_credentials_authentication()
    print("--------------------------------------------------------")
    oauth_flow_opaque_access_token_with_private_key_jwt_authentication()
    print("--------------------------------------------------------")
    access_public_api()        