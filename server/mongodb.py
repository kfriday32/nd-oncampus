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


def get_all_data():
    # dummy query
    data = [
        {"title": "Womens Basketball vs. Duke",
         "description": "",
         "location": "Purcelle Pavilion"
         },
        {"title": "Mens Baseball vs. Ohio State",
         "description": "senior game",
         "location": "Eck Field"
         },
        {"title": "Coed Inerhall Baseball Signups!",
         "description": "Must have 5 guys and girls for each baseball team",
         "location": "The Goog"
         },
        {"title": "Hockey Night in South Bend",
         "description": "final game for the seniors",
         "location": "Compton Family Arena"
         },
    ]
    return data


def get_partial_data():
    # called from openai.py library for the prompt construction
    data = get_all_data()

    # format the data to only include the titles and descriptions

    partial_data = [{"title": event["title"], "description": event["description"]}
                    for event in data]

    return partial_data


def main():
    get_partial_data()

if __name__ == '__main__':
    main()