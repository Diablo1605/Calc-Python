from fastapi.testclient import TestClient
from main import app  # Replace 'main' with your app filename if different

client = TestClient(app)

def test_add():
    response = client.get("/add?a=5&b=3")
    assert response.status_code == 200
    assert response.json() == {"result": 8}

def test_subtract():
    response = client.get("/subtract?a=10&b=3")
    assert response.status_code == 200
    assert response.json() == {"result": 7}

def test_multiply():
    response = client.get("/multiply?a=4&b=5")
    assert response.status_code == 200
    assert response.json() == {"result": 20}

def test_divide():
    response = client.get("/divide?a=10&b=2")
    assert response.status_code == 200
    assert response.json() == {"result": 5.0}

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

def test_modulo_by_zero():
    response = client.get("/modulo?a=5&b=0")
    assert response.status_code == 200
    assert response.json() == {"error": "Cannot modulo by zero"}

def test_average():
    response = client.get("/average?a=5&b=7")
    assert response.status_code == 200
    assert response.json() == {"result": 6}
