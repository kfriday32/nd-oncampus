from flask import Flask, request
from gpt import generate_prompt
import json
import re

app = Flask(__name__)


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


def DEBUG(message):
    print(f"--------------------------------------------------------------------")
    print(f"DEBUG: {message} ")
    print(f"--------------------------------------------------------------------")
