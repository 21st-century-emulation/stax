import json
import logging
import os
import requests
from flask import Flask, request

app = Flask(__name__)

WRITE_MEMORY_API=os.getenv("WRITE_MEMORY_API")

@app.route("/api/v1/execute", methods=["POST"])
def execute():
    cpu = request.json
    id = cpu["id"]
    cpu["state"]["cycles"] += 7

    value = cpu["state"]["a"]
    if cpu["opcode"] == 0x02: # STAX B
        address = (cpu["state"]["b"] << 8) | cpu["state"]["c"]
    elif cpu["opcode"] == 0x12: # STAX D
        address = (cpu["state"]["d"] << 8) | cpu["state"]["e"]

    requests.post(f"{WRITE_MEMORY_API}?id={id}&address={address}&value={value}")
    return json.dumps(cpu)

@app.route("/api/v1/debug/write_memory", methods=["POST"])
def write_memory():
    address = request.args.get("address")
    value = request.args.get("value")
    logging.warning(f"DEBUG write {address}={value}")
    return ""

@app.route("/status", methods=["GET"])
def healthcheck():
    return "Healthy"

app.run(host="0.0.0.0", port=8080)
