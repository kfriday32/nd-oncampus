# mongodb.py
from dotenv import load_dotenv
import os
from pymongo import MongoClient

load_dotenv()
MONGO_USER = os.getenv("MONGO_USER")
MONGO_PASSWORD = os.getenv("MONGO_PASSWORD")

def connect_to_db():
    # connect to client (mongo user password should be stored in personal .env file)
    try:
        uri = f'mongodb+srv://{MONGO_USER}:{MONGO_PASSWORD}@test-cluster1.ljrkvvp.mongodb.net/?retryWrites=true&w=majority'
        print(uri)
        mongo_client = MongoClient(uri)
    except Exception as e:
        print(e)

# retrieve data from 'event_list' collection
def get_collection_data():

    mongo_client = connect_to_db()

    # access 'campus_events' database
    db = mongo_client['campus_events']
    # access 'event_list' collection
    collection = db['event_list']
    data = collection.find()

    # return a list of dictionaries from the database
    return [document for document in data]
    

# return subset of event data
def get_partial_data():
    # called from openai.py library for the prompt construction
    data = get_collection_data()

    # format the data to only include the titles and descriptions

    partial_data = [{"title": event["title"], 
                     "description": event["description"], 
                     "id": str(event["_id"])}
                    for event in data]

    return partial_data


# publish data to collection
def publish_event():
    mongo_client = connect_to_db()
    # Send a ping to confirm a successful connection
    try:
        print(mongo_client)
        mongo_client.admin.command('ping')
        print("Pinged your deployment. You successfully connected to MongoDB!")
    except Exception as e:
        print(e)


def main():
    get_collection_data()
    print(get_partial_data())
    publish_event()


if __name__ == '__main__':
    main()
