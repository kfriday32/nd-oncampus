from flask import Flask, request, jsonify
from gpt import generate_prompt, generate_interests
import mongodb
import json
from bson.json_util import dumps
from mongodb import get_mongodb_flutter, get_mongodb_user_interests, rem_following_event, set_mongodb_user_interests, get_user_following, add_following_event, get_mongodb_events, get_host_events, get_mongodb_user_data, set_mongodb_user_data, get_series_events, get_series_id_from_name, get_existing_series_names, get_series_info, create_new_user
import re
import bcrypt
import jwt
import os

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

# route to events in the same series
@app.route('/series', methods=["GET"])
def series_events():
    series_id = request.args.get('seriesId')  # Retrieve the seriesId from the query parameters
    series_events = get_series_events(series_id)  # Pass the seriesId to the get_series_events() function
    return dumps(series_events)

# route to series_id using seriesName
@app.route('/seriesID', methods=["GET"])
def series_id():
    series_name = request.args.get('seriesName')
    if series_name:
        series_id = get_series_id_from_name(series_name)
        if series_id is not None:
            return series_id
        else:
            return "Series not found", 404
    else:
        return "Invalid request: seriesName parameter is missing", 400

# route to get seriesInfo using seriesId
@app.route('/seriesinfo', methods=["GET"])
def series_info():
    series_id = request.args.get('seriesId')
    if series_id:
        series_info = get_series_info(series_id)
        if series_info is not None:
            return {
                'seriesName': series_info[0] if series_info[0] is not None else '',
                'seriesDescription': series_info[1] if series_info[1] is not None else ''
            }
        else:
            return {
                'error': 'Series not found'
            }, 404
    else:
        return {
            'error': 'Invalid request: seriesId parameter is missing'
        }, 400

# route to list of existing series names
@app.route('/existingSeries', methods=["GET"])
def existing_series():
    series_names = get_existing_series_names()
    if series_names:
        return jsonify(series_names)
    else:
        return jsonify([])

# route to add series
@app.route('/publishseries', methods=["GET", "POST"])
def publish_series():
    if request.method == "GET":
        return "<p>publish get request</p>"
    else:
        # get data to publish from post request
        data = request.get_json()
        # post event to MongoDB
        new_series = mongodb.publish_series(data)
        return new_series
    
# route to user sign up
@app.route('/signup', methods=['POST'])
def signup():
    try:
        data = request.json
        firstName = data.get('firstName')
        lastName = data.get('lastName')
        studentId = data.get('studentId')
        major = data.get('major')
        college = data.get('college')
        grade = data.get('grade')
        interests = data.get('interests')
        clubs = data.get('clubs')
        follow_events = data.get('follow_events')
        email = data.get('email')
        password = data.get('password')

        # Hash the password
        hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

        create_new_user(firstName, lastName, studentId, email, major, college, grade, interests, clubs, follow_events, hashed_password)

        return jsonify({'message': 'User registered successfully'}), 200

    except Exception as e:
        print(f'An error occurred: {e}')
        return jsonify({'message': 'An error occurred', 'error': str(e)}), 500

# route to user login
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    studentId = data.get('studentId')
    password = data.get('password')
    # Find the user in the database
    user = get_mongodb_user_data(studentId)

    if user and bcrypt.checkpw(password.encode('utf-8'), user['password']):

        # Generate a JWT token
        token = jwt.encode({'studentId': studentId}, str(os.getenv('secret-auth-key')), algorithm='HS256')

        # Return the token to the client
        return jsonify({'token': token}), 200
    else:
        return jsonify({'message': 'Invalid ID or password'}), 401

def DEBUG(message):
    print(f"--------------------------------------------------------------------")
    print(f"DEBUG: {message} ")
    print(f"--------------------------------------------------------------------")
