from flask import Flask, request, jsonify
from gpt import generate_prompt, generate_interests
import mongodb
import json
from bson.json_util import dumps
from mongodb import get_mongodb_flutter, get_mongodb_user_interests, rem_following_event, set_mongodb_user_interests, get_user_following, add_following_event, get_mongodb_events, get_host_events, get_mongodb_user_data, set_mongodb_user_data, get_series_events   
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

# route to refresh the pages 
@app.route('/refresh', methods=["GET"])
def refresh_suggested():
    if request.method == "GET":

        # retrieve the interests list form mongoDB and run the prompt generation 
        interests = get_mongodb_user_interests("cpreciad")
        
        # check if the interests list is empty, and return None if true
        if interests == []:
            response = {"error": "empty"}
            return jsonify(response), 404

        # generate the data  
        data = generate_prompt(interests)
        if data == None:
            response = {{"error": "failure"}}
            return jsonify(response), 404
        
        return dumps(data)

@app.route('/followingHosts', methods=["GET"])
def following_host_list():
    demo_user = "cpreciad"
    # retries the list of events followed by user
    if request.method == "GET":
        return dumps(get_user_following(demo_user))
        
@app.route('/following', methods=["GET", "POST"])
def following_events():
    demo_user = "cpreciad"
    # retries the list of events followed by user
    if request.method == "GET":
        follow_hosts = get_user_following(demo_user)
        follow_events = get_host_events(follow_hosts)

        return dumps(follow_events)
    # add an event to list of following
    else:
        data = request.get_json()
        host = data["host"]
        new_following = add_following_event(demo_user, host)
        return dumps(new_following)

@app.route('/unfollow', methods=["POST"])
def unfollow_events():
    demo_user = "cpreciad"
    if request.method == "POST":
        data = request.get_json()
        host = data["host"]
        new_following = rem_following_event(demo_user, host)
        return dumps(new_following)

# route to get the user information from mongoDB
@app.route('/user', methods=["GET", "POST"])
def query_user():
    if request.method == 'GET':
        data = get_mongodb_user_data("cpreciad")
        # generate suggestion interests, only add them to the data if the user has suggestions
        suggestions = generate_interests(data['interests']) 
        if suggestions:
            data['suggestions'] = suggestions
        else:
            data['suggestions'] = []
        return dumps(data)
    if request.method == 'POST':
        data = request.get_json()
        if 'firstName' in data:
            # save the user profile 
            set_mongodb_user_data(request.get_json(), "cpreciad")
        else:
            # save the user preferences
            set_mongodb_user_interests(data['interests'], "cpreciad")

            # call chatGPT to generate suggested interests
            suggestions = generate_interests(data['interests']) 
            if suggestions == None:
                suggestions = []
            response = {"suggestions": suggestions}
            return jsonify(response), 200

    return "done"

@app.route('/series', methods=["GET"])
def series_events():
    series_id = request.args.get('seriesId')  # Retrieve the seriesId from the query parameters
    series_events = get_series_events(series_id)  # Pass the seriesId to the get_series_events() function
    return dumps(series_events)

def DEBUG(message):
    print(f"--------------------------------------------------------------------")
    print(f"DEBUG: {message} ")
    print(f"--------------------------------------------------------------------")
