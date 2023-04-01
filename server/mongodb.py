# mongodb.py
from dotenv import load_dotenv
import os
from pymongo import MongoClient

load_dotenv()
MONGO_PASSWORD = os.getenv("MONGO_PASSWORD")

def get_mongodb():
    # connect to client (mongo user password should be stored in personal .env file)
    mongo_client = MongoClient(f'mongodb+srv://cpreciad:{MONGO_PASSWORD}@test-cluster1.ljrkvvp.mongodb.net/?retryWrites=true&w=majority')

    # access 'campus_events' database
    db = mongo_client['campus_events']

    # access 'event_list' collection
    collection = db['event_list']

    data = collection.find()

    # return a list of dictionaries from the database
    return [document for document in data]
    
def get_partial_data():
    # called from openai.py library for the prompt construction
    data = get_mongodb()

    # format the data to only include the titles and descriptions

    partial_data = [{"title": event["title"], 
                     "description": event["description"], 
                     "id": str(event["_id"])}
                    for event in data]

    return partial_data


def main():
    get_mongodb()
    print(get_partial_data())


if __name__ == '__main__':
    main()
