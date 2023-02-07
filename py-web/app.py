from flask import Flask, render_template
import os

app = Flask(__name__, static_folder='img')

@app.route("/")
def index():
    env_var1 = os.environ.get("SECRET_VARIABLE")
    env_var2 = os.environ.get("VARIABLE_FROM_DATA")
    return render_template("index.html", env_var1=env_var1, env_var2=env_var2)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True)