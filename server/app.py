from flask import Flask, request, jsonify
from gpt import generate_prompt, generate_interests
import mongodb
import json
from bson.json_util import dumps
from mongodb import get_mongodb_flutter, get_mongodb_user_interests, set_mongodb_user_interests, get_mongodb_user_data, set_mongodb_user_data
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

# route to get the user information from mongoDB
@app.route('/user', methods=["GET", "POST"])
def query_user():
    if request.method == 'GET':
        data = get_mongodb_user_data("cpreciad")
        # generate suggestion interests, only add them to the data if the user has suggestions
        suggestions = generate_interests(data['interests']) 
        if suggestions:
            data['suggestions'] = suggestions
        DEBUG(data)
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
                return "no"
            response = {"suggestions": suggestions}
            return jsonify(response), 200

    return "done"

        

def DEBUG(message):
    print(f"--------------------------------------------------------------------")
    print(f"DEBUG: {message} ")
    print(f"--------------------------------------------------------------------")
