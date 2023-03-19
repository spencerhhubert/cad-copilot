import requests
import os



out_path = "data/thingiverse"
token = os.environ.get("THINGIVERSE_TOKEN")
if token is None or token == "":
    raise Exception("No token found. Set the THINGIVERSE_TOKEN environment variable")
headers = {
        "Authorization": f"Bearer {token}",
}

things = []

for page in range(1, 20):
    term = "scad"
    url = f"https://api.thingiverse.com/search?q={term}&page={page}&type=things"
    response = requests.get(url, headers=headers)
    response = response.json()["hits"]
    response = list(map(lambda x: x["id"], response))
    things.extend(response)

#erase duplicates
things = list(set(things))
print(f"found all the things. {len(things)} things found")


for thing in things:
    thing = str(thing)
    if os.path.exists(os.path.join(out_path, thing)):
        print(f"already have thing {thing}")
        continue

    #get metadata 
    url = f"https://api.thingiverse.com/things/{thing}"
    response = requests.get(url, headers=headers)
    response = response.json()
    summary = response["description"]
    name = response["name"]
    creator = response["creator"]["name"]

    #get scad file if it has it
    url = f"https://api.thingiverse.com/things/{thing}/files"
    response = requests.get(url, headers=headers)
    response = response.json()
    response = list(filter(lambda x: x["name"].endswith(".scad"), response))
    if len(response) == 0:
        continue
    response = response[0]
    url = response["public_url"]
    filename = os.path.join(out_path, thing, f"{thing}_by_{creator}.scad")

    if not os.path.exists(os.path.dirname(filename)):
        os.makedirs(os.path.dirname(filename))

    print(f"Downloading {filename} from {url}")
    response = requests.get(url, headers=headers)
    with open(filename, "wb") as f:
        f.write(response.content)

    #append to top lines of scad file
    with open(filename, "r") as f:
        lines = f.readlines()

    new_lines = [name, "\n\n", summary, "\n\n"]
    lines = new_lines + lines
    with open(filename, "w") as f:
        f.writelines(lines)
