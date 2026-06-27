import os
from dotenv import load_dotenv, set_key

isTesting = os.getenv('TESTING') or "PYTEST_VERSION" in os.environ
targetenv = ".env.testing" if isTesting else ".env"
load_dotenv(os.path.join(os.path.dirname(__file__), '..', targetenv), override=True)


def strtobool(value: str) -> bool:
    value = value.lower()
    if value in ("y", "yes", "on", "1", "true", "t"):
        return True
    return False


def generate_app_key():
    key = os.urandom(32).hex()
    set_key(targetenv, "APP_KEY", key)


def env(key, default=None):
    v = os.getenv(key)
    return default if v is None or v == '' else v
