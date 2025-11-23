### This is a file which contains db pre-created dummy data for project demonstration.
### Those values will be imported to the project.

from data import items_db, users_db

def load_dummy_data():
    # Adding Users Dummy Data without any Items for now
    users_db["1"] = {"name": "Brandon Guidelines", "items": []}
    users_db["2"] = {"name": "Carnegie Mondover", "items": []}
    users_db["3"] = {"name": "John Doe", "items": []}
    users_db["4"] = {"name": "Abraham Pigeon", "items": []}
    users_db["5"] = {"name": "Miles Tone", "items": []}
    users_db["6"] = {"name": "Claire Voyant", "items": []}

    # Adding Items Dummy Data
    items_db["1"] = {
        "id": "1", "main_category": "Assets", "sub_category": "Laptop", 
        "manufacturer": "Dell", "model": "XPS", "price": 5000.0, 
        "quantity": 1, "status": "In Stock", "assigned_to": None
    }
    items_db["2"] = {
        "id": "2", "main_category": "Assets", "sub_category": "Laptop",
        "manufacturer": "Lenovo", "model": "X1 Carbon", "price": 8300.0,
        "quantity": 1, "status": "In Stock", "assigned_to": None
    }
    items_db["3"] = {
        "id": "3", "main_category": "Assets", "sub_category": "PC",
        "manufacturer": "Asus", "model": "Desktop Intel Core i9 14900KS",
        "price": 14900.0, "quantity": 1, "status": "Assigned", "assigned_to": "1"
    }
    items_db["4"] = {
        "id": "4", "main_category": "Accessories", "sub_category": "Docking Station",
        "manufacturer": "Dell", "model": "WD19TB", "price": 700.0,
        "quantity": 1, "status": "Assigned", "assigned_to": "1"
    }
    items_db["5"] = {
        "id": "5", "main_category": "Accessories", "sub_category": "Mouse",
        "manufacturer": "Logitech", "model": "MX Master 3", "price": 550.0,
        "quantity": 1, "status": "Assigned", "assigned_to": "3"
    }
    items_db["6"] = {
        "id": "6", "main_category": "Licenses", "sub_category": "Subscription",
        "manufacturer": "OpenAI", "model": "ChatGPT Pro", "price": 800.0,
        "quantity": 1, "status": "Assigned", "assigned_to": "5"
    }

    # Assign items to users
    users_db["1"]["items"].extend(["3", "4"])
    users_db["3"]["items"].append("5")
    users_db["5"]["items"].append("6")