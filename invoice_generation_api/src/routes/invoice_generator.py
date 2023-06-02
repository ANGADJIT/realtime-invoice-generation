from fastapi import APIRouter, WebSocket, HTTPException, status
from fastapi.responses import FileResponse
from string import digits
from random import sample
from aws.aws_manager import AwsManager
from time import sleep
import requests
from requests import Response
from os import remove, mkdir
from os.path import exists
import threading


class InvoiceGeneratorRoute:

    def __init__(self) -> None:
        self.__router: APIRouter = APIRouter(
            prefix='/invoice', tags=['Invoice'])
        self.__aws_manager: AwsManager = AwsManager()

        # public invoice urls
        self.__public_urls: dict = {}

        self.__register_routes()

    @property
    def router(self) -> APIRouter:
        return self.__router

    def __register_routes(self) -> None:

        @self.__router.websocket('/generate')
        async def generate_invoice(websocket: WebSocket):
            await websocket.accept()  # accept connection

            # get json and process it for kineis put record
            transaction_event: dict = await websocket.receive_json()

            # add transaction id
            transaction_id: str = ''.join(
                sample(digits * 2, k=12))
            transaction_event['transaction_id'] = transaction_id

            # send event to kinesis
            self.__aws_manager.send_event(event=transaction_event)

            # check for 10 seconds for file
            object_key: str = f'{transaction_id}.pdf'

            count: int = 0

            while count != 15:
                check: bool = self.__aws_manager.check_for_object(
                    object_key=object_key)

                if check:
                    # generate public url
                    url: str = self.__aws_manager.generate_public_url(
                        object_key=object_key)

                    # add url to public urls
                    self.__public_urls[transaction_id] = url

                    await websocket.send_json({'status': 200, 'file_name': object_key, 'transaction_id': transaction_id})
                    return

                count += 1
                sleep(1)

            else:
                await websocket.send_json(
                    {'message': 'error:: something went wrong', 'status': 500})

        @self.__router.get('/get_invoice/{transaction_id}')
        def get_invoice(transaction_id: str):
            url: str = self.__public_urls.get(transaction_id)

            if url is not None:
                response: Response = requests.get(url)

                if response.status_code == 200:
                    invoice_pdf: bytes = response.content

                    if not exists('assets'):
                        mkdir('assets')

                    # write file in assets folder
                    file_path: str = f'assets/{transaction_id}.pdf'
                    with open(file_path, 'wb') as pdf_file:
                        pdf_file.write(invoice_pdf)

                    # invoke a file deletion background task
                    threading.Timer(2, lambda: remove(file_path))

                    return FileResponse(file_path, media_type="application/pdf", filename=f'{transaction_id}.pdf')

                else:
                    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail={
                        'error': 'invalid request'})

            else:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail={
                                    'error': 'invalid transaction_id'})
