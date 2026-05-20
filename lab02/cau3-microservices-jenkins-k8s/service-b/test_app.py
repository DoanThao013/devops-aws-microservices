from app import app


def test_health():
    client = app.test_client()
    res = client.get("/health")
    assert res.status_code == 200
    assert res.get_json()["status"] == "ok"


def test_index():
    client = app.test_client()
    res = client.get("/")
    assert res.status_code == 200
    assert "Service B" in res.get_json()["message"]


def test_data():
    client = app.test_client()
    res = client.get("/data")
    assert res.status_code == 200
    assert len(res.get_json()["items"]) == 2
