from flask import Flask, request
from gpt import generate_prompt
import mongodb
import json
from bson.json_util import dumps
from mongodb import get_mongodb_flutter, get_mongodb_user_interests, rem_following_event, set_mongodb_user_interests, get_user_following, add_following_event, get_mongodb_events
import re

app = Flask(__name__)

# route to get events based on interests
@app.route("/", methods=("GET", "POST"))
def call_gpt():
    if request.method == "POST":
        
        # access interest sent via post body
        data = request.get_json()
        interests = data['interest']

        interests = re.split(', |,| ',interests)

        # save the interests list to the account list of MongoDB
        set_mongodb_user_interests(interests, "cpreciad")

        # make call to OpenAI and retrieve the data
        data = generate_prompt(interests)
        if data == None:
            # need to make a decision about what is sent back to the front end upon failure
            return "failure"

        # return the generated results

        return dumps(data)

    elif request.method == "GET":
        data = get_mongodb_flutter()
        return dumps(data)

    return "success!"

# route to publish events
@app.route('/publish', methods=["GET", "POST"])
def publish_event():
    if request.method == "GET":
        return "<p>publish get request</p>"
    else:
        # get data to publish from post request
        data = request.get_json()
        # post event to MongoDB
        new_event = mongodb.publish_event(data)
        return new_event


@app.route('/refresh', methods=["GET"])
def refresh_suggested():
    if request.method == "GET":

        # retrieve the interests list form mongoDB and run the prompt generation 
        interests = get_mongodb_user_interests("cpreciad")
        
        data = generate_prompt(interests)
        if data == None:
            return "failure"
        
        return dumps(data)

@app.route('/followingIds', methods=["GET"])
def following_eventIds():
    demo_user = "cpreciad"
    # retries the list of events followed by user
    if request.method == "GET":
        return dumps(get_user_following(demo_user))
        
@app.route('/following', methods=["GET", "POST"])
def following_events():
    demo_user = "cpreciad"
    # retries the list of events followed by user
    if request.method == "GET":
        following = get_user_following(demo_user)
        print(f"following: ${following}")

        # get actual events based on list of event ids
        events = get_mongodb_events(following)

        return dumps(events)
    # add an event to list of following
    else:
        data = request.get_json()
        event_id = data["event_id"]
        new_following = add_following_event(demo_user, event_id)
        return dumps(new_following)

@app.route('/unfollow', methods=["POST"])
def unfollow_events():
    demo_user = "cpreciad"
    if request.method == "POST":
        data = request.get_json()
        event_id = data["event_id"]
        new_following = rem_following_event(demo_user, event_id)
        return dumps(new_following)


def DEBUG(message):
    print(f"--------------------------------------------------------------------")
    print(f"DEBUG: {message} ")
    print(f"--------------------------------------------------------------------")
