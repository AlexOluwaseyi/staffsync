#!/usr/bin/python3

import json
from datetime import timedelta

from flask import (Flask, abort, flash, redirect, render_template,
                   request, session, url_for)
from flask_bcrypt import Bcrypt
from flask_login import (LoginManager, current_user, login_required,
                         login_user, logout_user)
from flask_migrate import Migrate

import models
from web.creds import secretKey

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
bcrypt.init_app(app)


@app.template_filter('hasattr')
def hasattr_filter(obj, attr):
    return hasattr(obj, attr)


app.jinja_env.filters['hasattr'] = hasattr_filter


@login_manager.user_loader
def user_loader(id):
    """
    Given *staff_id*, return the associated User object.
    # :param unicode staff_id: user_id (email) user to retrieve
    """
    return models.storage.get(id)


@app.route('/', strict_slashes=False)
def index():
    """Index page"""
    title = "Welcome"
    if 'session_id' in session:  # Check if the user is signed in
        user = current_user
        return redirect(url_for('admin', user=user))
    return render_template('index.html', title=title)


@app.route('/login', methods=['GET', 'POST'], strict_slashes=False)
def login():
    """Login page for users
    """
    title = "Login"
    msg = request.args.get('msg', '')

    if request.method == 'POST':
        email = request.form['email'].lower()
        password_input = request.form['password']
        remember = 'remember-me' in request.form
        user = models.storage.get(email=email)
        if user:
            if user.status:
                password = user.password
                pw_check = bcrypt.check_password_hash(password,
                                                      password_input)
                if pw_check:
                    user.authenticated = True
                    models.storage.session.add(user)
                    models.storage.session.commit()
                    login_user(user, remember=remember)
                    # session_id = session['_id']
                    session_id = user.id
                    session['session_id'] = session_id
                    return redirect(url_for('admin', session_id=session_id))
                else:
                    msg = 'You have entered a wrong password.'
            else:
                msg = f'Account for {user.name} has been deactivated'

        else:
            msg = 'No user found with this email'

    return render_template('login.html', title=title, msg=msg)


@app.route('/dashboard/<session_id>', methods=['GET', 'POST'],
           strict_slashes=False)
@app.route('/dashboard', methods=['GET', 'POST'], strict_slashes=False)
@login_required
def dashboard(session_id=None):
    """Loads dashboard for current
    signed in user
    """
    title = "Dashboard"
    user = current_user
    if user.access_level >= 5:
        title = "Admin Dashboard"
    return render_template('dashboard.html', title=title, user=current_user)


@app.route('/admin/<session_id>', methods=['GET', 'POST'],
           strict_slashes=False)
@app.route('/admin', methods=['GET', 'POST'], strict_slashes=False)
@login_required
def admin(session_id=None):
    """Loads dashboard for current
    signed in user
    """
    title = "Dashboard"
    user = current_user
    if user.access_level >= 5:
        title = "Admin Dashboard"
    return render_template('admin.html', title=title, user=current_user)


@app.route('/profile/<session_id>', methods=['GET', 'POST'],
           strict_slashes=False)
@app.route('/profile', methods=['GET', 'POST'], strict_slashes=False)
@login_required
def profile(session_id=None):
    """ Profile page for current
    signed in user.
    """
    title = "Profile"
    return render_template('profile.html', title=title, user=current_user)


@app.route('/register', methods=['GET', 'POST'], strict_slashes=False)
@login_required
def register(session_id=None):
    """Add a new or existing employee record
    """
    import calendar
    from datetime import datetime

    from models.permission import access_level, sched_options
    from models.roles import roles_dict

    title = "Register"
    user = current_user
    if user.access_level <= 10:
        abort(403)

    month_int = datetime.now().month
    current_month = calendar.month_name[month_int]
    current_year = datetime.now().year
    all = models.storage.all()
    managers = ([obj for obj in all.values() if obj.access_level > 5
                 and obj.access_level < 12])

    if request.method == 'POST':
        option_selector = request.form.get('option_selector')
        if option_selector == 'new_entry':
            first_name = request.form.get('first_name')
            last_name = request.form.get('last_name')
            role = 'NH'
            model = roles_dict.get(role)
            manager = models.storage.get(designation='NH')
            reports_to = manager.staff_id
            entry = model(first_name=first_name, last_name=last_name,
                          reports_to=reports_to, role=role)
            print(entry.to_dict())
            models.storage.new(entry)
            entry.override_schedule(current_year, current_month, 'MTWTF')
            entry.save()

        elif option_selector == 'existing':
            first_name = request.form.get('first_name2')
            last_name = request.form.get('last_name2')
            staff_id = request.form.get('staff_id')
            email = request.form.get('email')
            role = request.form.get('role')
            manager_id = request.form.get('manager')
            manager = models.storage.get(manager_id)
            reports_to = manager.staff_id
            model = roles_dict.get(role)
            entry = model(first_name=first_name, last_name=last_name,
                          staff_id=staff_id, email=email,
                          reports_to=reports_to, role=role)
            print(entry.to_dict())
            models.storage.new(entry)
            if hasattr(entry, 'generate_schedule'):
                entry.generate_schedule(current_year, current_month)
            entry.save()
    return render_template('register.html', title=title, user=current_user,
                           access_level=access_level, roles_dict=roles_dict,
                           sched_options=sched_options, managers=managers)


@app.route('/deactivate', methods=['GET', 'POST'],
           strict_slashes=False)
@login_required
def deactivate():
    """Deactivate a selected employee account.add()
    """
    title = "Deactivate"
    msg = ''
    user = current_user
    if user.access_level <= 10:
        abort(403)

    if request.method == 'POST':
        if 'staff_id' in request.form:
            staff_id = request.form.get('staff_id')
            employee = models.storage.get(staff_id=staff_id)
        elif 'email' in request.form:
            email = request.form['email']
            employee = models.storage.get(email=email)
        if employee:
            employee.deactivate()
            employee.save()
            msg = f'Account for {employee.name} deactivated successful.'
            return redirect(url_for('admin'))
    return render_template('deactivate.html', title=title, msg=msg)


@app.route('/schedules/<session_id>', methods=['GET'], strict_slashes=False)
@app.route('/schedules', methods=['GET'], strict_slashes=False)
@login_required
def schedules(session_id=None):
    """Loads the current and previous schedules
    for employees.
    Loads the schedule (json) from database.
    """
    user = current_user
    title = "Schedules"
    schedules = json.loads(user.schedules)
    return render_template('schedules.html', title=title,
                           user=user, schedules=schedules)


@app.route('/generateschedule', methods=['GET', 'POST'],
           strict_slashes=False)
@login_required
def generateschedule():
    """Deactivate a selected employee account.add()
    """
    import calendar
    from datetime import datetime

    months = [calendar.month_name[i] for i in range(1, 13)]
    current_year = datetime.now().year
    title = "Generate Schedule"
    msg = ''
    user = current_user
    if user.access_level <= 5:
        abort(403)

    if request.method == 'POST':
        option_selector = request.form.get('option_selector')
        if option_selector == 'individual':
            staff_id = request.form.get('staff_id')
            month = request.form.get('month')
            year = request.form.get('year')
            employee = models.storage.get(staff_id)
            if employee:
                employee.generate_schedule(year, month)
                employee.save()
                msg = (f'Schedule for {employee.name} for {month.title()} '
                       f'{year} created successfully.')
            else:
                msg = f'No record found for Staff ID {staff_id}'
        elif option_selector == 'collective':
            month = request.form.get('month')
            year = request.form.get('year')
            all_employees = models.storage.all().values()
            filtered_employee = []
            for obj in all_employees:
                if obj.access_level == 4:  # in range(2, 5):
                    filtered_employee.append(obj)
            for employee in filtered_employee:
                employee.generate_schedule(year, month)
                employee.save()
            msg = f'Schedule for {month.title()} {year} created successfully.'
        # return redirect(url_for('admin'))

    return render_template('genschedule.html', title=title, msg=msg,
                           current_year=current_year, months=months)


@app.route('/resetpassword', methods=['GET', 'POST'], strict_slashes=False)
@login_required
def resetpassword():
    """Resets user password for the signed
    user and logs out user to login with new
    password
    """
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


@app.route('/resetbyadmin', methods=['GET', 'POST'], strict_slashes=False)
@login_required
def resetbyadmin():
    """ Resets employee account password to
    default based on E-mail or Staff ID of
    the employee with forgotten password.
    """
    user = current_user
    if user.access_level <= 10:
        abort(403)
    title = 'Reset by Admin'
    msg = ''
    referrer = request.referrer
    if request.method == 'POST':
        if 'staff_id' in request.form:
            staff_id = request.form['staff_id']
            employee = models.storage.get(staff_id=staff_id)
        elif 'email' in request.form:
            email = request.form['email']
            employee = models.storage.get(email=email)
        if employee:
            employee.reset_password()
            msg = f'Password reset for {employee.name} successful.'
            from time import sleep
            sleep(3)
            return redirect(referrer or url_for('admin'))
        else:
            msg = 'No user found with E-mail or Staff ID provided.'
    return render_template('resetbyadmin.html', title=title, msg=msg)


@app.route('/logout', methods=['GET', 'POST'], strict_slashes=False)
@login_required
def logout():
    """Log out current user
    and delete session.
    """
    title = "Logout"
    user = current_user
    user.authenticated = False
    models.storage.session.add(user)
    models.storage.session.commit()
    logout_user()
    msg = 'You have been logged out successfully.'
    flash('You have been logged out successfully.', 'success')
    return redirect(url_for('login', title=title, msg=msg))


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
