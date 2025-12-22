from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="FastAPI Template", version="1.0.0")

class HelloResponse(BaseModel):
    message: str

@app.get("/")
async def root():
    """Root endpoint"""
    return {"message": "Welcome to FastAPI Template"}

@app.get("/hello", response_model=HelloResponse)
async def hello(name: str = "World"):
    """Hello World endpoint with optional name parameter"""
    return HelloResponse(message=f"Hello {name} from FastAPI!")

@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
