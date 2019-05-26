# flask_web/oldapp.py

from flask import Flask
app = Flask(__name__)


@app.route('/')
def hello_world():
    return 'Nice to meet you!'


@app.route('/goaway')
def goaway():
    return 'GO AWAY!'


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
