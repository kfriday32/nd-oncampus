import os
import openai
import re
from mongodb import get_mongodb_gpt, get_mongodb_events

openai.api_key = os.getenv("OPENAI_API_KEY")

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
    footer = f"Return the IDs of the events that are most closely related to the following: ({interest_str})."

    # create the fully formatted prompt
    prompt = header + "\n" + event_body + '\n' + footer
    # create request
    try:
        response = openai.Completion.create(
            model="text-davinci-003",
            prompt=prompt,
            temperature=0.7,
            max_tokens=256,
            top_p=1,
            frequency_penalty=0,
            presence_penalty=0
        )

    except Exception as error:
        print("OpenAI Completion error!: ", error)
        return None

    # clean the returned ids from chatGPT
    id_list = re.split(', |,| ', response.choices[0].text)
    id_list = [id.strip() for id in id_list]

    # query the collections corresponding to the IDs
    data = get_mongodb_events(id_list) 
    
    return data

def main():
    # get user input
    interest = input("Primary interest: ")
    generate_prompt(interest)


if __name__ == '__main__':
    main()
