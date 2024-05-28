# This script anonymises named entities in a text using SpaCy. The user can choose to anonymise named entities of a specific type (PERSON, ORG, DATE, TIME, GEOPOLITICAL) in the text and save the anonymised text to a file. The script also provides a sample text for demonstration purposes.

import spacy
nlp = spacy.load("en_core_web_sm")

sample_text = "On 20.01.2024, the World Economic Forum held its annual meeting in Davos, Switzerland. The event was attended by Greta Thunberg, the young Swedish climate activist, who spoke about the urgent need to address climate change. During her speech, she mentioned that the estimated costs of transitioning to a sustainable economy are huge but feasible. She also called out the International Monetary Fund for its lack of action on climate change. Thunberg’s speech was well-received by the audience, which included representatives from Microsoft, Apple, and Amazon. The CEOs of these companies, Satya Nadella, Tim Cook, and Jeff Bezos, respectively, were also present at the event. Nadella spoke about the importance of digital transformation in the current business landscape, while Cook discussed Apple’s latest product releases. Bezos, on the other hand, talked about his plans for Blue Origin, his space exploration company. Overall, the event was a success, with many attendees praising the quality of the discussions and the insights shared. Elon Musk was there as well but the CEO of Tesla did not speak."

# providing the option to enter text path

break_flag = False
while not break_flag:
    file_path = input("Provide the path for the file you want to censor or type 'SAMPLE' to use a sample file: ")
    if file_path == "SAMPLE":
        break_flag = True
        text = sample_text
    elif file_path:
        try:
            with open(file_path, "r") as r:
                text = r.read()
            break_flag = True
        except:
            print("Wrong input, enter the right path or type 'SAMPLE'.")

analysis_text = nlp(text)

# allowing the user to choose the named entity to be replaced and creating a censored copy of the text

label = ""
while label == "":
    ent_choice = input("Enter the number of the named entity to be censored in the text.\n1 - PERSON\n2 - ORG\n3 - DATE\n4 - TIME\n5 - GEOPOLITICAL\nYOUR CHOICE: ")
    if ent_choice == "1":
        label = "PERSON"
    elif ent_choice == "2":
        label = "ORG"
    elif ent_choice == "3":
        label = "DATE"
    elif ent_choice == "4":
        label = "TIME"
    elif ent_choice == "5":
        label = "GPE"
    else:
        print("Wrong input, choose one of the numbers.\n")

selected_entities = [ent.text for ent in analysis_text.ents if ent.label_ == label] 
censored_text = text
for ent_name in selected_entities:
    censored_text = censored_text.replace(ent_name, "######")


# printing the text

print(f"Here is your final text:\n {censored_text}")

# providing the option to overwrite the previous text

if file_path == "SAMPLE":
    print("This is the end of the demonstration.")
else:
    break_flag = False
    while not break_flag:
        overwrite_decision = input("Do you want to overwrite the previous text?\n Type 'YES' or 'NO': ")
        if overwrite_decision == "YES":
            with open(file_path, "w") as w:
                w.write(censored_text)
            print("Text saved with changes.")
            break_flag = True
        elif overwrite_decision == "NO":
            print("Changes not saved.")
            break_flag = True
        else:
            print("Wrong input.")