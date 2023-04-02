import os
import openai
import re
from mongodb import get_mongodb_gpt, get_mongodb_events

openai.api_key = os.getenv("OPENAI_API_KEY")
TRIES = 8

# this function will take the users interests and return a new list of suggested interests 
def generate_interests(interests):
    if interests == []:
        return None
    header = 'Given the following interests: \n'

    # construct the body of the prompt
    body = '('
    for interest in interests:
        body += f'{interest} '
    body += ')\n'

    footer = 'Generate only three suggestions that you think the user would also like. (in a comma seperated list)'

    prompt = header + body + footer

    for i in range(TRIES):
        try:
        # create request
            response = openai.Completion.create(
            model="text-davinci-003",
            prompt=prompt,
            temperature=0.9,
            max_tokens=256,
            top_p=1,
            frequency_penalty=0,
            presence_penalty=0
            )

        except Exception as error:
            print("OpenAI Completion error!: ", error)
            continue
        # clean the data and return a list of suggested interests
        suggestions = list(map(str.strip, response.choices[0].text.split(',')))
        return suggestions

    return None



    
# get user input and send request to open ai
# input: interests => list(string)
def generate_prompt(interests):

    # query data from mongodb, pulling only the event titles and descriptions
    # returns a list of dictionaries: {"title": ~~~, "description": ~~~}
    events = get_mongodb_gpt()

    # create a header to the prompt
    header = f"Look at the Titles and Descriptions of the following events:"

    # create the list of events for the prompt
    event_body = ""
    for i, event in enumerate(events, 1):
        event_body += f"""
        {i}. Title: {event["title"]}
             Description: {event["description"]}
             ID: {event["id"]} 
        """

    # generate interest list in a string format
    # TODO should there be a case for when a user passes in no interests?
    interest_str = ""
    for i, interest in enumerate(interests):
        if i == 0:
            interest_str += f"{interest}"
            continue

        interest_str += f", {interest}"

    # create a footer to the prompt
    footer = f"Return the IDs of the events somewhat related to the following interests: ({interest_str})."

    # create the fully formatted prompt
    prompt = header + "\n" + event_body + '\n' + footer

    # attempt to get a valid response from chatGPT {TRIES} times
    for i in range(TRIES):
        try:
        # create request
            response = openai.Completion.create(
            model="text-davinci-003",
            prompt=prompt,
            temperature=0.2,
            max_tokens=256,
            top_p=1,
            frequency_penalty=0,
            presence_penalty=0
            )

        except Exception as error:
            print("OpenAI Completion error!: ", error)
            continue

        # clean the returned ids from chatGPT
        id_list = re.split(', |,| ', response.choices[0].text)
        id_list = [id.strip() for id in id_list]

        # query the collections corresponding to the IDs
        try:
            data = get_mongodb_events(id_list) 
        except Exception as error: 
            print("OpenAI Completion error!: ", error)
            continue
        # return data on a sucessful query of Events
        return data

    return None

def main():
    # get user input
    generate_interests(["Sports", "Programming, Baseball"])


if __name__ == '__main__':
    main()
