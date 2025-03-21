from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Example data storage (simulating a database)
users = {}

# Define a request model
class User(BaseModel):
    name: str
    age: int

# Endpoint: Get user details
@app.get("/user/{user_id}")
def get_user(user_id: int):
    return users.get(user_id, {"error": "User not found"})

# Endpoint: Add a new user
@app.post("/user/{user_id}")
def add_user(user_id: int, user: User):
    users[user_id] = user.dict()
    return {"message": "User added successfully"}


@app.get("/greet/{name}")
def greet_name(name: str):
    return {"message": f"Hello, {name}!"}

# Run the server (if running manually)
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)