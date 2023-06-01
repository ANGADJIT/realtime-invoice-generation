from fastapi import APIRouter, WebSocket
from string import digits
from random import sample
from aws.aws_manager import AwsManager
from time import sleep


class InvoiceGeneratorRoute:

    def __init__(self) -> None:
        self.__router: APIRouter = APIRouter(
            prefix='/invoice', tags=['Invoice'])
        self.__aws_manager: AwsManager = AwsManager()

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

            while count != 10:
                check: bool = self.__aws_manager.check_for_object(
                    object_key=object_key)

                if check:
                    # generate public url
                    url: str = self.__aws_manager.generate_public_url(
                        object_key=object_key)

                    await websocket.send_json({'status': 200, 'file_name': object_key, 'invoice_url': url})
                    return

                count += 1
                sleep(1)

            else:
                await websocket.send_json(
                    {'message': 'error:: something went wrong', 'status': 500})
