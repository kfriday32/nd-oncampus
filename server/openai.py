import os
import openai

openai.api_key = os.getenv("OPEN_AI_KEY")

# get user input and send request to open ai


def generate_prompt(interest):

    # generate prompt to send to api
    prompt = f"Find all events that have titles similarly related to {interest}"

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


def main():
    # get user input
    interest = input("Primary interest: ")
    generate_prompt(interest)


if __name__ == '__main__':
    main()
