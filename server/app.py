from flask import Flask, request
from gpt import generate_prompt


app = Flask(__name__)


@app.route("/event_request", methods=("GET", "POST"))
def call_gpt():
    if request.method == "POST":
        interest = request.form.get("interest")
        # TODO PLACEHOLDER: parse the interests and turn it into a list of strings
        interests = [interest.strip(), "hockey"]

        response = generate_prompt(interests)
        if response == None:
            # need to make a decision about what is sent back to the front end upon failure
            return "failure"
        DEBUG(response.choices[0].text)

    elif request.method == "GET":
        DEBUG("GET request recieved")

    return "success!"


@app.route("/event-upload", methods=("GET", "POST"))
def call_gpt():
    if request.method == "POST":
        DEBUG("POST request recieved")
    elif request.method == "GET":
        DEBUG("GET request recieved")


def DEBUG(message):
    print(f"--------------------------------------------------------------------")
    print(f"DEBUG: {message} ")
    print(f"--------------------------------------------------------------------")
