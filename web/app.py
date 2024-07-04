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
from flask_session import Session
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import IntegrityError
import json
from uuid import uuid4
from datetime import timedelta


app = Flask(__name__)
app.config['SECRET_KEY'] = secretKey
login_manager = LoginManager()
login_manager.session_protection = "strong"
login_manager.login_view = "login"
login_manager.login_message_category = "info"
app.config['REMEMBER_COOKIE_DURATION'] = timedelta(minutes=15)


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
    # from models.advocate import SE

    if request.method == 'POST':
        # print(session['_flashes'])
        # print(request.cookies.to_dict())
        # print(dir(request))
        email = request.form['email'].lower()
        password_input = request.form['password']
        remember = 'remember-me' in request.form
        print(f'rememeber is {remember}')
        # print(f'email - {email}')
        # print(f'password - {password_input}')
        user = models.storage.get(email=email)
        if user:
            password = user.password
            pw_check = bcrypt.check_password_hash(password,
                                                  password_input)
            if pw_check:
                print('pw check passed.')
                user.authenticated = True
                models.storage.session.add(user)
                models.storage.session.commit()
                login_user(user, remember=remember)
                # session_id = str(uuid4())
                session_id = user.id
                session['session_id'] = session_id
                return redirect(url_for('admin', session_id=session_id))
            else:
                print('pw check failed')
                msg = 'You have entered a wrong password.'

        else:
            msg = 'No user found with this email'

    return render_template('login.html', title=title, msg=msg)


@app.route('/dashboard/<session_id>', methods=['GET', 'POST'],
           strict_slashes=False)
@app.route('/dashboard', methods=['GET', 'POST'], strict_slashes=False)
@login_required
def dashboard(session_id=None):
    title = "Dashboard"
    user = current_user
    return render_template('dashboard.html', title=title, user=current_user)


@app.route('/admin/<session_id>', methods=['GET', 'POST'], strict_slashes=False)
@app.route('/admin', methods=['GET', 'POST'], strict_slashes=False)
@login_required
def admin(session_id=None):
    title = "Admin"
    user = current_user
    return render_template('admin.html', title=title, user=current_user)


@app.route('/schedules/<session_id>', methods=['GET'], strict_slashes=False)
@app.route('/schedules', methods=['GET'], strict_slashes=False)
@login_required
def schedules(session_id=None):
    user = current_user
    title =  "Schedules"
    schedules = json.loads(user.schedules)
    # for year, months in schedules
    return render_template('schedules.html', title=title, user=user, schedules=schedules)


@app.route('/resetpassword', methods=['GET', 'POST'], strict_slashes=False)
@login_required
def resetpassword():
    title = "Reset Password"
    user = current_user
    msg = ''
    if request.method == 'POST':
        old_password = request.form['old_password']
        new_password = request.form['new_password']
        pw_check = bcrypt.check_password_hash(user.password, old_password)
        if pw_check:
            user.update_password(new_password)
            msg = 'Password changed successfully.'
            logout_user()
            return redirect(url_for('login', title='Login', msg=msg))
        else:
            msg = 'Old password is not correct.'
    return render_template('resetpassword.html', title=title, msg=msg)


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
