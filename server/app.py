from flask import Flask, request
from gpt import generate_prompt
import mongodb
import json
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

        # make call to OpenAI
        response = generate_prompt(interests)
        if response == None:
            # need to make a decision about what is sent back to the front end upon failure
            return "failure"

        # return the generated results
        response_data = response.choices[0].text
        DEBUG(response_data)
        return response_data

    elif request.method == "GET":
        DEBUG("GET request recieved")

    return "success!"


# route to publish events
@app.route('/publish', methods=["GET", "POST"])
def publish_event():
    if request.method == "GET":
        return "<p>publish get request</p>"
    else:
        # get data to publish from post request
        data = request.get_json()
        print(data)

        # post event to MongoDB
        mongodb.publish_event()

        title = data['title']
        print(title)

        # send post request to mongodb
        return "<p>publish post request</p>"


def DEBUG(message):
    print(f"--------------------------------------------------------------------")
    print(f"DEBUG: {message} ")
    print(f"--------------------------------------------------------------------")
