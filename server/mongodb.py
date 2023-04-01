# mongodb.py

import os
from pymongo import MongoClient

MONGO_CLIENT = os.getenv("MONGO_CLIENT")
MONGO_PORT = os.getenv("MONGO_PORT")

def get_mongodb():
    # connect to client (specify client and port)
    mongo_client = MongoClient(MONGO_CLIENT, MONGO_PORT)

    # access 'campus_events' database
    db = mongo_client['campus_events']

    # access 'event_list' collection
    ev_list = db['event_list']



def main():
    pass

if __name__ == '__main__':
    main()