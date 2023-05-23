from typing import Any
from jinja2 import Template
import xhtml2pdf.pisa as pisa
from io import BytesIO


class RenderPdf:

    def __init__(self, data: dict) -> None:
        self.__data: dict = data

    def __render_html(self) -> None:
        with open('templates/invoice.html') as invoice_template:
            invoice_template = Template(invoice_template.read())

            self.__rendered_invoice = invoice_template.render(**self.__data)

    def __render_pdf(self):
        invoice_pdf = BytesIO()
        pisa.CreatePDF(self.__rendered_invoice, dest=invoice_pdf)

        return invoice_pdf.getvalue()

    def __call__(self) -> bytes:
        self.__render_html()
        invoice_pdf: bytes = self.__render_pdf()

        return invoice_pdf

