from fastapi.testclient import TestClient
from main import app  # Replace 'main' with your filename if different

client = TestClient(app)

def test_add():
    response = client.get("/add?a=5&b=3")
    assert response.status_code == 200
    assert response.json() == {"result": 8}

def test_subtract():
    response = client.get("/subtract?a=10&b=4")
    assert response.status_code == 200
    assert response.json() == {"result": 6}

def test_multiply():
    response = client.get("/multiply?a=6&b=7")
    assert response.status_code == 200
    assert response.json() == {"result": 42}

def test_divide():
    response = client.get("/divide?a=20&b=4")
    assert response.status_code == 200
    assert response.json() == {"result": 5}

def test_divide_by_zero():
    response = client.get("/divide?a=5&b=0")
    assert response.status_code == 200
    assert response.json() == {"error": "Cannot divide by zero"}

def test_power():
    response = client.get("/power?a=2&b=3")
    assert response.status_code == 200
    assert response.json() == {"result": 8}

def test_modulo():
    response = client.get("/modulo?a=10&b=3")
    assert response.status_code == 200
    assert response.json() == {"result": 1}

def test_modulo_zero():
    response = client.get("/modulo?a=10&b=0")
    assert response.status_code == 200
    assert response.json() == {"error": "Cannot modulo by zero"}

def test_average():
    response = client.get("/average?a=10&b=20")
    assert response.status_code == 200
    assert response.json() == {"result": 15}
