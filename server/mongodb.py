

def get_all_data():
    # dummy query
    data = [
        {"title": "Womens Basketball vs. Duke",
         "description": "",
         "location": "Purcelle Pavilion"
         },
        {"title": "Mens Baseball vs. Ohio State",
         "description": "senior game",
         "location": "Eck Field"
         },
        {"title": "Coed Inerhall Baseball Signups!",
         "description": "Must have 5 guys and girls for each baseball team",
         "location": "The Goog"
         },
        {"title": "Hockey Night in South Bend",
         "description": "final game for the seniors",
         "location": "Compton Family Arena"
         },
    ]
    return data


def get_partial_data():
    # called from openai.py library for the prompt construction
    data = get_all_data()

    # format the data to only include the titles and descriptions

    partial_data = [{"title": event["title"], "description": event["description"]}
                    for event in data]

    return partial_data

# get event from user and save it to MongoDB
# input: event => dict(k = string, v = string)


def post_event(event):
    pass


if __name__ == "__main__":
    get_partial_data()
