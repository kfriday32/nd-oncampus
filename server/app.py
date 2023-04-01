from flask import Flask, request
from openai import generate_prompt


app = Flask(__name__)


@app.route("/")
def call_gpt():
    if request.method == "POST":
        interest = request.form.get("interest")
        response = generate_prompt(interest)
        if response == None:
            # need to make a decision about what is sent back to the front end upon failure
            return "faulure"
        DEBUG(response)

        DEBUG("POST request recieved")

    elif request.method == "GET":
        DEBUG("GET request recieved")

    return "success!"


def DEBUG(message):
    print(f"--------------------------------------------------------------------")
    print(f"DEBUG: {message} ")
    print(f"--------------------------------------------------------------------")
