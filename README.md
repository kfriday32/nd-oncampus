# ND OnCampus
2023 Hesburgh Library Hackathon

### Team Members
- Kristen Friday
- Carlo Preciado
- Gavin Uhran

### Requirements
- Python version 3.9.10

# Running the Server

## Installing dependencies

If not done so already, create a new virtual environment within the `server` directory using `python3 -m venv venv`

Once created, run the virtual environment using `source venv/bin/activate`. You should see a (venv) display at the beginning of your terminal prompt

After the virtual environment is activated, install the requirements by running `pip install -r requirements.txt`

## Setting up Flask

To make sure Flask runs in `dev` mode, create a new file called `.env` and include the following lines:

```
FLASK_APP=app
FLASK_ENV=development
```

Running the server should be as simple as `flask run`

# Mongo Database

## Creating a user and generating a password 
In order to use the MongoDB database, developers will need to be added to the Atlas cluster and given the 
appropriate permissions to read & write to the database. 

Once the developer has been added to the database which is done on the `Security -> Database Access` page, 
click through `edit` ->  ` Edit Password` -> `generate new password` and save the password for the user. This 
will be used as an environment variable to authenticate the user for database access

## Saving the user credentials
Within the `server` directory, open the `.env` file that was created in the previous step. 
Include the following lines: 

```
MONGO_USERNAME=<username stored in Atlas>
MONGO_PASSWORD=<generated password>
```

### Note
This is how permissions are being granted to the database for now. A more streamlined solution 
should be researched and pursued in the future

# Flutter UI

Ensure that you have set up a mobile emulator prior to trying to deploy the application and that Flutter is installed locally (run `flutter doctor` to check that Flutter is up to date). 

Navigate to the `flutter_ui` directory. Inside the directory, run the command `flutter run`.
