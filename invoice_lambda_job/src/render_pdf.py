from jinja2 import Template
import convertapi
from os import environ
from os.path import exists
from os import remove


class RenderPdf:

    def __init__(self, data: dict) -> None:
        self.__data: dict = data

    def __render_html(self) -> None:
        with open('templates/invoice.html') as invoice_template:
            invoice_template = Template(invoice_template.read())

            self.__rendered_invoice = invoice_template.render(**self.__data)

    def __render_pdf(self) -> bytes:
        rendered_html_file: str = '/tmp/rendered_invoice.html'
        rendered_html_pdf: str = '/tmp/rendered_invoice.pdf'

        # save file before covertion
        with open(rendered_html_file, 'w') as rendered:
            rendered.write(self.__rendered_invoice)

        # add secret to api
        convertapi.api_secret = environ.get('SECRET')

        convertapi.convert('pdf', {
            'File': rendered_html_file
        }, from_format='html').save_files(rendered_html_pdf)

        # re-open and covert back to bytes format
        with open(rendered_html_pdf, 'rb') as bytes_file:
            pdf_file: bytes = bytes_file.read()

        # delete temp file
        if exists(rendered_html_file) and exists(rendered_html_pdf):
            remove(rendered_html_file)
            remove(rendered_html_pdf)

        return pdf_file

    def __call__(self) -> bytes:
        self.__render_html()
        invoice_pdf: bytes = self.__render_pdf()

        return invoice_pdf