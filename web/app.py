#!/usr/bin/python3

import models
from flask import Flask, jsonify, render_template
from flask_cors import CORS
from flasgger import Swagger
from flasgger.utils import swag_from
from web.creds import secretKey
# from flask import (Flask, flash, render_template, session,
#                    redirect, url_for, request, abort, make_response,
#                    jsonify, json)
from flask_login import (LoginManager, current_user, login_user,
                         login_required, logout_user)
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import IntegrityError
import json


app = Flask(__name__)
app.config['SECRET_KEY'] = secretKey


@app.route('/', strict_slashes=False)
def index():
    title = "Welcome"
    return render_template('index.html', title=title)


@app.route('/dashboard', strict_slashes=False)
def dashboard():
    title = "Dashboard"
    return render_template('dashboard.html', title=title)


@app.route('/logout', strict_slashes=False)
def logout():
    title = "Dashboard"
    return render_template('index.html', title=title)


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
