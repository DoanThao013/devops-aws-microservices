from flask import Flask, jsonify
import os

app = Flask(__name__)


@app.get("/health")
def health():
    return jsonify(status="ok", service="service-b")


@app.get("/")
def index():
    return jsonify(message="Hello from Service B (Python)")


@app.get("/data")
def data():
    return jsonify(items=[{"id": 1, "name": "alpha"}, {"id": 2, "name": "beta"}])


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
