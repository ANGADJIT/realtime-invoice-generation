from fastapi import FastAPI
from routes.invoice_generator import InvoiceGeneratorRoute

api = FastAPI()

# routes
invoice_generator_route: InvoiceGeneratorRoute = InvoiceGeneratorRoute()

api.include_router(invoice_generator_route.router)


@api.get('/')
def root():
    return 'Invoice Generator API:: check docs at http://API_URL:8000/docs'
