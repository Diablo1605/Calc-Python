# from fastapi import FastAPI

# app = FastAPI()

# @app.get("/add")
# def add(a: float, b: float):
#     return {"result": a + b}

# @app.get("/subtract")
# def subtract(a: float, b: float):
#     return {"result": a - b}

# @app.get("/multiply")
# def multiply(a: float, b: float):
#     return {"result": a * b}

# @app.get("/divide")
# def divide(a: float, b: float):
#     if b == 0:
#         return {"error": "Cannot divide by zero"}
#     return {"result": a / b}

# @app.get("/power")
# def power(a: float, b: float):
#     return {"result": a ** b}

# @app.get("/modulo")
# def modulo(a: float, b: float):
#     if b == 0:
#         return {"error": "Cannot modulo by zero"}
#     return {"result": a % b}

# @app.get("/average")
# def average(a: float, b: float):
#     return {"result": (a + b) / 2}
from fastapi import FastAPI, Request
import os
import json

app = FastAPI()

# ---------------------------
# SIMULATED VULNERABLE HELPERS
# ---------------------------

# Simulated command injection pattern (NOT actually dangerous in tests)
@app.get("/debug/run")
def simulated_command_injection(cmd: str):
    # Vulnerable pattern for scanners (be sure to mock during tests)
    output = os.popen(cmd).read()
    return {"command": cmd, "output": output}

# Simulated insecure deserialization
@app.post("/debug/load")
async def simulated_insecure_deserialization(request: Request):
    # Simulated vulnerability: loads user-supplied JSON into Python objects unsafely
    body = await request.body()
    try:
        # This mimics pickle.loads style unsafe decoding (but stays JSON for safety)
        return {"loaded": json.loads(body)}
    except Exception as e:
        return {"error": str(e)}

# Simulated path traversal
@app.get("/debug/readfile")
def simulated_path_traversal(filename: str):
    # Vulnerable pattern: `filename` is concatenated directly
    path = "./data/" + filename
    try:
        with open(path, "r") as f:
            return {"content": f.read()}
    except Exception as e:
        return {"error": str(e)}

# Hardcoded secret (simulated vulnerability)
SECRET_KEY = "FAKE-HARDCODED-SECRET-12345"


# ---------------------------
# ORIGINAL CALCULATOR ENDPOINTS
# ---------------------------

@app.get("/add")
def add(a: float, b: float):
    return {"result": a + b}

@app.get("/subtract")
def subtract(a: float, b: float):
    return {"result": a - b}

@app.get("/multiply")
def multiply(a: float, b: float):
    return {"result": a * b}

@app.get("/divide")
def divide(a: float, b: float):
    if b == 0:
        return {"error": "Cannot divide by zero"}
    return {"result": a / b}

@app.get("/power")
def power(a: float, b: float):
    return {"result": a ** b}

@app.get("/modulo")
def modulo(a: float, b: float):
    if b == 0:
        return {"error": "Cannot modulo by zero"}
    return {"result": a % b}

@app.get("/average")
def average(a: float, b: float):
    return {"result": (a + b) / 2}

