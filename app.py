#!/usr/bin/python3

from models import storage
from flask import Flask, jsonify, make_response
from flask_cors import CORS
from flasgger import Swagger
from flasgger.utils import swag_from
from creds import secretKey
from models import storage
from flask import (Flask, flash, render_template, session,
                   redirect, url_for, request, abort, make_response,
                   jsonify, json)
from flask_login import (LoginManager, current_user, login_user,
                         login_required, logout_user)
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import IntegrityError
import json


app = Flask(__name__)


if __name__ == '__main__':
    app.run(debug=True)