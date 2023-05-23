from fastapi import FastAPI

api = FastAPI()


@api.get('/')
def root():
    return 'New Api'
