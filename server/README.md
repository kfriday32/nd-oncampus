# SERVER

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

## Running the Server

Running the server should be as simple as `flask run`
