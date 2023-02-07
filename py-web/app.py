from flask import Flask, render_template
import os

app = Flask(__name__, static_folder='img')

@app.route("/")
def index():
    env_var = os.environ.get("SECRET_VARIABLE")
    return render_template("index.html", env_var=env_var)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True)