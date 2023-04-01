from flask import Flask, request
from gpt import generate_prompt
import json

app = Flask(__name__)


@app.route("/", methods=("GET", "POST"))
def call_gpt():
    if request.method == "POST":
        
        # access interest sent via post body
        data = request.get_json()
        interest = data['interest']

        # TODO PLACEHOLDER: parse the interests and turn it into a list of strings
        interests = [interest.strip(), "hockey"]

        # make call to OpenAI
        response = generate_prompt(interests)
        if response == None:
            # need to make a decision about what is sent back to the front end upon failure
            return "ok"

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
