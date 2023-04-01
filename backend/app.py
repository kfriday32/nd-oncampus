from flask import Flask, request


app = Flask(__name__)


@app.route("/")
def call_gpt():
    if request.method == "POST":
        DEBUG("POST request recieved")

    elif request.method == "GET":
        DEBUG("GET request recieved")

    return "success!"


def DEBUG(message):
    print(f"--------------------------------------------------------------------")
    print(f"DEBUG: {message} ")
    print(f"--------------------------------------------------------------------")
