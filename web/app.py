#!/usr/bin/python3

import models
from flask_cors import CORS
from flasgger import Swagger
from flasgger.utils import swag_from
from web.creds import secretKey
from flask import (Flask, flash, render_template, session,
                   redirect, url_for, request, abort, make_response,
                   jsonify, json)
from flask_login import (LoginManager, current_user, login_user,
                         login_required, logout_user)
from flask_bcrypt import Bcrypt
from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import IntegrityError
import json


app = Flask(__name__)
app.config['SECRET_KEY'] = secretKey
login_manager = LoginManager()
login_manager.session_protection = "strong"
login_manager.login_view = "login"
login_manager.login_message_category = "info"

migrate = Migrate()
bcrypt = Bcrypt()

login_manager.init_app(app)
# models.storage.init_app(app)
# migrate.init_app(app, models.storage)
bcrypt.init_app(app)


@login_manager.user_loader
def user_loader(id):
    """Given *staff_id*, return the associated User object.
    # :param unicode staff_id: user_id (email) user to retrieve
    """
    return models.storage.get(id)


@app.route('/', strict_slashes=False)
def index():
    title = "Welcome"
    return render_template('index.html', title=title)


@app.route('/login', methods=['GET', 'POST'], strict_slashes=False)
def login():
    title = "Login"
    msg = request.args.get('msg', '')
    from models.advocate import SE

    if request.method == 'POST':
        email = request.form['email']
        password_input = request.form['password']
        print(f'email - {email}')
        print(f'password - {password_input}')
        users = models.storage.all()
        for user in users.values():
            if user and user.email == email:
                password = user.password
                # pw_check = bcrypt.check_password_hash(password,
                #                                       password_input)
                # if pw_check:
                if password_input == password:
                    print('pw check passed.')
                    user.authenticated = True
                    models.storage.session.add(user)
                    models.storage.session.commit()
                    login_user(user, remember=True)
                    return redirect(url_for('dashboard'))
                else:
                    print('pw check failed')
                    msg = 'You have entered a wrong password.'

            else:
                msg = 'No user found with this email'

    return render_template('login.html', title=title, msg=msg)


@app.route('/dashboard', methods=['GET', 'POST'], strict_slashes=False)
@login_required
def dashboard():
    title = "Dashboard"
    user = current_user
    return render_template('dashboard.html', title=title, user=current_user)


@app.route('/logout', methods=['GET', 'POST'], strict_slashes=False)
def logout():
    title = "Login"
    user = current_user
    user.authenticated = False
    models.storage.session.add(user)
    models.storage.session.commit()
    logout_user()
    msg = 'You have been logged out successfully.'
    return redirect(url_for('login', title=title, msg=msg))


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
