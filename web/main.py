from flask import Flask, Response

app = Flask(__name__)

with open("./web/.ps1", "r") as f:
    SHELL_SCRIPT_WIN = f.read()
with open("./web/.sh", "r") as f:
    SHELL_SCRIPT_UNIX = f.read()
    
@app.route("/", methods=["GET"])
def index():
    return Response("""Hi, I'm arpit""") 

@app.route("/win", methods=["GET"])
def windows():
    return Response(SHELL_SCRIPT_WIN, mimetype="text/plain")

@app.route("/unix", methods=["GET"])
def unix():
    return Response(SHELL_SCRIPT_UNIX, mimetype="text/plain")

if __name__ == "__main__":
    app.run()
