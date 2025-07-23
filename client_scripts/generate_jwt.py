#
# This script creates a JWT with the proper header and payload and signs it with the RS256 algorithm.
# It is used to authenticate a Service User with a private JWT.
#
# THIS IS A PYTHON SCRIPT INSPIRED BY THE ORIGINAL FROM ZITADEL.
# The original python script from Zitadel can be found here: 
#   https://zitadel.com/docs/guides/integrate/service-users/private-key-jwt#3-create-a-jwt-and-sign-with-private-key
#

import jwt
import datetime
import argparse
import os


def generate_jwt_token(service_user_id, private_key, key_id, api_url):
    """
    Generates a JWT token for ZITADEL authentication.

    Args:
        service_user_id (str): Your ZITADEL service user ID.
        private_key (str): Your private key.
        key_id (str): The key ID associated with your private key.
        api_url (str): The base URL of your ZITADEL API.

    Returns:
        str: The generated JWT token.
    """

    # Get current UTC time and expiration time (5 minutes from now)
    iat = datetime.datetime.now(datetime.timezone.utc)
    exp = iat + datetime.timedelta(minutes=5)

    # Generate JWT claims
    payload = {
        "iss": service_user_id,
        "sub": service_user_id,
        "aud": api_url,
        "exp": exp,
        "iat": iat
    }

    header = {
        "alg": "RS256",
        "kid": key_id
    }

    # Sign the JWT using RS256 algorithm
    encoded_jwt = jwt.encode(payload, private_key, algorithm="RS256", headers=header)
    return encoded_jwt


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate a JWT token for ZITADEL authentication.",
        formatter_class=argparse.RawTextHelpFormatter # For better formatting of help text
    )

    parser.add_argument(
        "service_user_id",
        help="Your ZITADEL service user ID."
    )
    parser.add_argument(
        "private_key",
        help="Your private key.\n"
             "The key should be in PKCS#8 format (e.g., '-----BEGIN PRIVATE KEY-----...')."
    )
    parser.add_argument(
        "key_id",
        help="The key ID associated with your private key."
    )
    parser.add_argument(
        "api_url",
        help="The base URL of your ZITADEL API (e.g., 'https://your-instance.zitadel.cloud')."
    )

    args = parser.parse_args()

    try:
        jwt_token = generate_jwt_token(
            args.service_user_id,
            args.private_key,
            args.key_id,
            args.api_url
        )
        print(f"{jwt_token}")
    except FileNotFoundError as e:
        print(f"Error: {e}")
        exit(1)
    except ValueError as e:
        print(f"Error: {e}")
        exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        exit(1)    