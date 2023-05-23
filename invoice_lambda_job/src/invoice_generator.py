from typing import Any


def generate_invoice(event, context) -> Any:
    return event['Records']
