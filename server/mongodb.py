# mongodb.py 
from dotenv import load_dotenv
import os
from pymongo import MongoClient
from bson import ObjectId
from datetime import datetime
from pprint import pprint

load_dotenv()
MONGO_USERNAME = os.getenv("MONGO_USERNAME")
MONGO_PASSWORD = os.getenv("MONGO_PASSWORD")

# this function will return the collection for the event list. Any time a functoin needs to connect to the database,
# this function will be called
def get_mongodb_collection():
    # connect to client (mongo user password should be stored in personal .env file)
    mongo_client = MongoClient(f'mongodb+srv://{MONGO_USERNAME}:{MONGO_PASSWORD}@test-cluster1.ljrkvvp.mongodb.net/?retryWrites=true&w=majority')
    # access 'campus_events' database
    db = mongo_client['campus_events']

    # access  and return 'event_list' collection
    return db['event_list']

def get_mongodb_user():
    # connect to client
    mongo_client = MongoClient(f'mongodb+srv://{MONGO_USERNAME}:{MONGO_PASSWORD}@test-cluster1.ljrkvvp.mongodb.net/?retryWrites=true&w=majority')
    # access 'campus_events' database
    db = mongo_client['campus_events']
    return db['account_list']

# this function will query all events from the event_list collection and return all events in json format
def get_mongodb_all():
    collection = get_mongodb_collection()

    # get all event doucments in the collection
    data = collection.find()

    # return a json formatted events list of upcoming events (old events filtered)
    return [document for document in data if 
        datetime.strptime(document['time'], "%Y-%m-%d %H:%M:%S.%f") 
        >= 
        datetime.strptime(datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f"),"%Y-%m-%d %H:%M:%S.%f" )]

# this function is utilized by the chatGPT api call to parse only the information necessary
# for chatGPT to parse  
def get_mongodb_gpt():
    # called from openai.py library for the prompt construction
    data = get_mongodb_all()

    # format the data to only include the titles and descriptions

    partial_data = [{"title": event["title"], 
                     "description": event["description"], 
                     "id": str(event["_id"])}
                    for event in data]

    return partial_data

# this function is called after chatGPT returns the ids of events that match the search results. 
# returns a list of json objects corresponding to the ids
def get_mongodb_events(id_list):
    collection = get_mongodb_collection()

    # itterate through the id list and query all completed collections 
    events = [collection.find_one({'_id': ObjectId(id)}) for id in id_list]
    return events

# simple api wrapper for returning all data to flutter
def get_mongodb_flutter():
    data = get_mongodb_all()

    return data

# publish data to collection
def publish_event(new_event):
    events_coll = get_mongodb_collection()
    # insert new event into collection
    created_event = events_coll.insert_one(new_event)
    
    return "successfully posted new event"

# this function returns the entire data set on a user 
def get_mongodb_user_data(user):
    account = get_mongodb_user()
    query = account.find_one({"studentId": user})
    return query

def set_mongodb_user_data(data, user):
    # get the collection and querey the user data
    account = get_mongodb_user()
    query = account.find_one({"studentId": user})
    print(query)
    new_data = {'$set': {"firstName": data['firstName'],
                         "lastName": data['lastName'],
                         "netId": "cpreciad"}}
    account.update_many(query, new_data)

def get_mongodb_user_interests(user):

    # get the user account collection from mongoDB
    account = get_mongodb_user()

    # query the demo user 
    query = account.find_one({"studentId": user})
    if query == None:
        print("error: user was not found")
        return None

    # return the interests list  
    return query['interests']

def set_mongodb_user_interests(interests, user):
    # get the user account from mongoDB
    account = get_mongodb_user()
    
    # query on the demo user to get the appropriate table
    query = account.find_one({"studentId": user})
    if query == None:
        print("error: user was not found")

    # update the users interests
    new_interests = { "$set": {"interests": interests}}
    account.update_one(query, new_interests)


def main():
    # pprint(get_mongodb_flutter())
    # set_mongodb_user_interests(["baseball", "soccer"], "cpreciad")
    # print(get_mongodb_user_interests("cpreciad"))
    pprint(get_mongodb_all())


if __name__ == '__main__':
    main()
