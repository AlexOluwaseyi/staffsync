[33mcommit 133727bc7a3576ee4a6eb01b4007e7c30a4ba2e5[m[33m ([m[1;36mHEAD -> [m[1;32mmain[m[33m, [m[1;31morigin/main[m[33m)[m
Author: AlexOluwaseyi <akintolaoluwaseyi34@gmail.com>
Date:   Sun Jul 7 11:05:10 2024 +0100

    Done:
    Completed registration route (for new and existing employee)
    
    Doing:
    Still cleaning up and commenting code (OTG)
    
    To-Do:
    Deactivation page
    Schedule Generator page

[1mdiff --git a/models/__pycache__/advocate.cpython-312.pyc b/models/__pycache__/advocate.cpython-312.pyc[m
[1mindex c3a03f1..5f8ba0b 100644[m
Binary files a/models/__pycache__/advocate.cpython-312.pyc and b/models/__pycache__/advocate.cpython-312.pyc differ
[1mdiff --git a/models/__pycache__/bus_enablement.cpython-312.pyc b/models/__pycache__/bus_enablement.cpython-312.pyc[m
[1mindex 65e9cbc..674ad61 100644[m
Binary files a/models/__pycache__/bus_enablement.cpython-312.pyc and b/models/__pycache__/bus_enablement.cpython-312.pyc differ
[1mdiff --git a/models/__pycache__/employee.cpython-312.pyc b/models/__pycache__/employee.cpython-312.pyc[m
[1mindex bcaf1fe..0145956 100644[m
Binary files a/models/__pycache__/employee.cpython-312.pyc and b/models/__pycache__/employee.cpython-312.pyc differ
[1mdiff --git a/models/__pycache__/permission.cpython-312.pyc b/models/__pycache__/permission.cpython-312.pyc[m
[1mindex 6dcaadf..d5a862e 100644[m
Binary files a/models/__pycache__/permission.cpython-312.pyc and b/models/__pycache__/permission.cpython-312.pyc differ
[1mdiff --git a/models/__pycache__/roles.cpython-312.pyc b/models/__pycache__/roles.cpython-312.pyc[m
[1mindex 74255f1..555337a 100644[m
Binary files a/models/__pycache__/roles.cpython-312.pyc and b/models/__pycache__/roles.cpython-312.pyc differ
[1mdiff --git a/models/advocate.py b/models/advocate.py[m
[1mindex c9682dc..8fab758 100644[m
[1m--- a/models/advocate.py[m
[1m+++ b/models/advocate.py[m
[36m@@ -56,6 +56,22 @@[m [mclass SE(Employee, Base):[m
         manager = models.storage.get(manager_id)[m
         return manager[m
 [m
[32m+[m[32m    def override_schedule(self, year, month, schedule):[m
[32m+[m[32m        """Override the scheule for a given year and month"""[m
[32m+[m[32m        from datetime import datetime[m
[32m+[m[32m        try:[m
[32m+[m[32m            schedules_dict = json.loads(self.schedules)[m
[32m+[m[32m        except (TypeError, json.JSONDecodeError):[m
[32m+[m[32m            schedules_dict = {}[m
[32m+[m
[32m+[m[32m        year_str = str(year)[m
[32m+[m[32m        if year_str not in schedules_dict:[m
[32m+[m[32m            schedules_dict[year_str] = {calendar.month_name[i].upper():[m
[32m+[m[32m                                        None for i in range(1, 13)}[m
[32m+[m[32m        schedules_dict[year_str][month.upper()] = schedule[m
[32m+[m[32m        self.schedules = json.dumps(schedules_dict)[m
[32m+[m[32m        self.updated_at = datetime.now()[m
[32m+[m
     def generate_schedule(self, year, month):[m
         """Generate a new schedule for SE for a given year and month"""[m
         import random[m
[36m@@ -132,6 +148,16 @@[m [mclass SE(Employee, Base):[m
                 {schedules_dict[year_str][month_str]}'[m
 [m
 [m
[32m+[m[32mclass NH(SE):[m
[32m+[m[32m    def __init__(self, *args, **kwargs):[m
[32m+[m[32m        super().__init__(*args, **kwargs)[m
[32m+[m[32m        role = kwargs.get('role', 'NH')[m
[32m+[m[32m        if role not in access_level:[m
[32m+[m[32m            raise ValueError(f"Invalid role: {role}")[m
[32m+[m[32m        self.role = access_level[role].value[m
[32m+[m[32m        ...[m
[32m+[m
[32m+[m
 class T2(Employee, Base):[m
     __tablename__ = 'advocates'[m
     __table_args__ = {'extend_existing': True}[m
[1mdiff --git a/models/bus_enablement.py b/models/bus_enablement.py[m
[1mindex 033b37e..02e3b07 100644[m
[1m--- a/models/bus_enablement.py[m
[1m+++ b/models/bus_enablement.py[m
[36m@@ -8,7 +8,7 @@[m [mfrom sqlalchemy import Column, String, DateTime, Integer[m
 [m
 class BE(Employee, Base):[m
     """Class definition for Business Enablement"""[m
[31m-    __tablename__ = "managers"[m
[32m+[m[32m    __tablename__ = "biz_enable"[m
     __table_args__ = {'extend_existing': True}[m
     reports_to = Column(Integer, nullable=True)[m
     in_charge_of = Column(String(1024), nullable=True)[m
[1mdiff --git a/models/employee.py b/models/employee.py[m
[1mindex f7bccd3..7ba5acf 100644[m
[1m--- a/models/employee.py[m
[1m+++ b/models/employee.py[m
[36m@@ -8,6 +8,7 @@[m [mimport models[m
 from models.permission import access_level, roles_description[m
 from flask_login import UserMixin[m
 from flask_bcrypt import Bcrypt[m
[32m+[m[32mimport random[m
 [m
 [m
 time_format = "%Y-%m-%dT%H:%M:%S.%f"[m
[36m@@ -41,8 +42,8 @@[m [mclass Employee(UserMixin):[m
             setattr(self, key, value)[m
         self.id = kwargs.get('id', str(uuid4()))[m
         self.created_at = kwargs.get('created_at', datetime.now())[m
[31m-        self.first_name = kwargs.get('first_name', None)[m
[31m-        self.last_name = kwargs.get('last_name', None)[m
[32m+[m[32m        self.first_name = kwargs.get('first_name', None).strip().title()[m
[32m+[m[32m        self.last_name = kwargs.get('last_name', None).strip().title()[m
         self.staff_id = kwargs.get('staff_id')[m
         self.status = kwargs.get('status', True)[m
 [m
[36m@@ -52,16 +53,21 @@[m [mclass Employee(UserMixin):[m
             role = kwargs.get('role', 'SE')[m
         if role not in access_level:[m
             raise ValueError(f"Invalid role: {role}")[m
[31m-        if self.first_name is not None and self.last_name is not None:[m
[31m-            self.name = " ".join([self.first_name, self.last_name])[m
[31m-            email_id = '.'.join([self.first_name.lower(),[m
[31m-                                 self.last_name.lower()])[m
[31m-            self.email = f"{email_id}@{self.domain}"[m
[32m+[m[32m        if 'email' not in kwargs:[m
[32m+[m[32m            if self.first_name and self.last_name:[m
[32m+[m[32m                self.name = " ".join([self.first_name, self.last_name])[m
[32m+[m[32m                email = (f"{self.first_name.lower()}."[m
[32m+[m[32m                        f"{self.last_name.lower()}@{self.domain}")[m
[32m+[m[32m                while models.storage.get(email=email) is not None:[m
[32m+[m[32m                    random_digit = str(random.randint(0, 9))[m
[32m+[m[32m                    email = (f"{self.first_name.lower()}.{self.last_name.lower()}"[m
[32m+[m[32m                            f"{random_digit}@{self.domain}")[m
[32m+[m[32m                self.email = email[m
         self.role = role[m
         self.desc = roles_description[role][m
         self.access_level = access_level[role][m
         self.updated_at = kwargs.get('updated_at', datetime.now())[m
[31m-[m
[32m+[m[32m        self.set_name()[m
         self.password = bcrypt.generate_password_hash('default')[m
 [m
     def set_name(self):[m
[36m@@ -108,6 +114,7 @@[m [mclass Employee(UserMixin):[m
         dict_copy['updated_at'] = dict_copy['updated_at'].strftime(time_format)[m
         dict_copy['__class__'] = self.__class__.__name__[m
         del dict_copy['_sa_instance_state'][m
[32m+[m[32m        del dict_copy['password'][m
         return dict_copy[m
 [m
     def roles_descr(self):[m
[1mdiff --git a/models/permission.py b/models/permission.py[m
[1mindex eed486c..8217214 100644[m
[1m--- a/models/permission.py[m
[1m+++ b/models/permission.py[m
[36m@@ -5,7 +5,7 @@[m [mfrom enum import IntEnum[m
 [m
 class AccessLevel(IntEnum):[m
     SUPER_ADMIN = 12[m
[31m-    ADMIN = 11[m
[32m+[m[32m    MGMT = 11[m
     GM = 10[m
     OM = 9[m
     BE = 8[m
[36m@@ -16,13 +16,14 @@[m [mclass AccessLevel(IntEnum):[m
     T2 = 3[m
     SE = 2[m
     NH = 1[m
[31m-    VISITORS = 0[m
[32m+[m[32m    VIS = 0[m
 [m
 [m
 roles_description = {[m
     'Super Admin': "Super Admin",[m
     'MGMT': "Admin.",[m
     "BE": "Business Enablement",[m
[32m+[m[32m    "GM": "Global Manager",[m
     'TM': "Team Manager",[m
     'DM': "Duty Manager",[m
     'OM': "Operations Manager",[m
[36m@@ -37,8 +38,8 @@[m [mroles_description = {[m
 [m
 # Create a dictionary to map roles to access levels[m
 access_level = {[m
[31m-    "SUPER_ADMIN": AccessLevel.SUPER_ADMIN,[m
[31m-    "ADMIN": AccessLevel.ADMIN,[m
[32m+[m[32m    "SUPER ADMIN": AccessLevel.SUPER_ADMIN,[m
[32m+[m[32m    "MGMT": AccessLevel.MGMT,[m
     "GM": AccessLevel.GM,[m
     "TM": AccessLevel.TM,[m
     "OM": AccessLevel.OM,[m
[36m@@ -50,7 +51,7 @@[m [maccess_level = {[m
     "T2": AccessLevel.T2,[m
     "SE": AccessLevel.SE,[m
     "NH": AccessLevel.NH,[m
[31m-    "VISITORS": AccessLevel.VISITORS[m
[32m+[m[32m    "VIS": AccessLevel.VIS[m
 }[m
 [m
 [m
[1mdiff --git a/models/roles.py b/models/roles.py[m
[1mindex bbe57ce..558f5ec 100644[m
[1m--- a/models/roles.py[m
[1m+++ b/models/roles.py[m
[36m@@ -5,13 +5,14 @@[m [mavailable roles[m
 """[m
 [m
 from models.employee import Employee[m
[31m-from models.advocate import SE, T2, TL[m
[32m+[m[32mfrom models.advocate import SE, T2, TL, NH[m
 from models.manager import TM, DM, OM, GM[m
 from models.bus_enablement import BE[m
 [m
 [m
 roles_dict = {[m
     'Employee': Employee,[m
[32m+[m[32m    'NH': NH,[m
     'SE': SE,[m
     'T2': T2,[m
     'TL': TL,[m
[36m@@ -19,5 +20,5 @@[m [mroles_dict = {[m
     'DM': DM,[m
     'OM': OM,[m
     'GM': GM,[m
[31m-    'BE': BE[m
[32m+[m[32m    'BE': BE,[m
 }[m
[1mdiff --git a/staffsync.db b/staffsync.db[m
[1mindex 2c637a6..6a0c004 100644[m
Binary files a/staffsync.db and b/staffsync.db differ
[1mdiff --git a/web/__pycache__/app.cpython-312.pyc b/web/__pycache__/app.cpython-312.pyc[m
[1mindex 60ff716..59db94c 100644[m
Binary files a/web/__pycache__/app.cpython-312.pyc and b/web/__pycache__/app.cpython-312.pyc differ
[1mdiff --git a/web/app.py b/web/app.py[m
[1mindex 3d5e5ba..7270828 100644[m
[1m--- a/web/app.py[m
[1m+++ b/web/app.py[m
[36m@@ -106,32 +106,62 @@[m [mdef dashboard(session_id=None):[m
 @app.route('/register', methods=['GET', 'POST'], strict_slashes=False)[m
 # @login_required[m
 def register(session_id=None):[m
[31m-    """Loads dashboard for current[m
[31m-    signed in user[m
[32m+[m[32m    """Add a new or existing employee record[m
     """[m
     from models.permission import access_level, sched_options[m
     from models.roles import roles_dict[m
[32m+[m[32m    from datetime import datetime[m
[32m+[m[32m    import calendar[m
 [m
     title = "Register"[m
     user = current_user[m
     # access_level = access_level[m
     # if user.access_level <= 10:[m
     #     abort(403)[m
[31m-    print(request.form)[m
[32m+[m[32m    month_int = datetime.now().month[m
[32m+[m[32m    current_month = calendar.month_name[month_int][m
[32m+[m[32m    current_year = datetime.now().year[m
[32m+[m[32m    all_managers = {}[m
[32m+[m[32m    from models.manager import TM, DM, OM, GM[m
[32m+[m[32m    _class = [TM, DM, OM, GM][m
[32m+[m[32m    # for cls in _class:[m
[32m+[m[32m    all = models.storage.all()[m
[32m+[m[32m    managers = ([obj for obj in all.values() if obj.access_level > 5[m
[32m+[m[32m                 and obj.access_level < 12])[m
[32m+[m
     if request.method == 'POST':[m
         option_selector = request.form.get('option_selector')[m
         if option_selector == 'new_entry':[m
             first_name = request.form.get('first_name')[m
             last_name = request.form.get('last_name')[m
[31m-            role = roles_dict.get('NH')[m
[31m-            entry = role(first_name=first_name, last_name=last_name)[m
[32m+[m[32m            role = 'NH'[m
[32m+[m[32m            model = roles_dict.get(role)[m
[32m+[m[32m            manager = models.storage.get(designation='NH')[m
[32m+[m[32m            reports_to = manager.staff_id[m
[32m+[m[32m            entry = model(first_name=first_name, last_name=last_name,[m
[32m+[m[32m                         reports_to=reports_to, role=role)[m
[32m+[m[32m            entry.override_schedule(current_year, current_month, 'MTWTF')[m
             entry.save()[m
[32m+[m
         elif option_selector == 'existing':[m
[31m-            print("Existing")[m
[31m-        print("something is wrong")[m
[32m+[m[32m            first_name = request.form.get('first_name2')[m
[32m+[m[32m            last_name = request.form.get('last_name2')[m
[32m+[m[32m            print(f'{first_name} - {last_name}')[m
[32m+[m[32m            staff_id = request.form.get('staff_id')[m
[32m+[m[32m            email = request.form.get('email')[m
[32m+[m[32m            role = request.form.get('role')[m
[32m+[m[32m            manager_id = request.form.get('manager')[m
[32m+[m[32m            manager = models.storage.get(manager_id)[m
[32m+[m[32m            reports_to=manager.staff_id[m
[32m+[m[32m            model = roles_dict.get(role)[m
[32m+[m[32m            entry = model(first_name=first_name, last_name=last_name,[m
[32m+[m[32m                          staff_id=staff_id, email=email,[m
[32m+[m[32m                          reports_to=reports_to, role=role)[m
[32m+[m[32m            entry.generate_schedule(current_year, current_month)[m
[32m+[m[32m            # entry.save[m
     return render_template('register.html', title=title, user=current_user,[m
[31m-                           access_level=access_level,[m
[31m-                           sched_options=sched_options)[m
[32m+[m[32m                           access_level=access_level, roles_dict=roles_dict,[m
[32m+[m[32m                           sched_options=sched_options, managers=managers)[m
 [m
 [m
 @app.route('/admin/<session_id>', methods=['GET', 'POST'],[m
[36m@@ -247,5 +277,18 @@[m [mdef logout():[m
     return redirect(url_for('login'))[m
 [m
 [m
[32m+[m[32mdef clean(text):[m
[32m+[m[32m    # Remove leading and trailing whitespace, tabs, and newlines[m
[32m+[m[32m    text = text.strip()[m
[32m+[m
[32m+[m[32m    # Replace tabs and newlines within the string[m
[32m+[m[32m    text = text.replace('\t', '').replace('\n', '').replace('\r', '')[m
[32m+[m
[32m+[m[32m    # Remove all spaces within the string[m
[32m+[m[32m    text = text.replace(' ', '')[m
[32m+[m
[32m+[m[32m    return text[m
[32m+[m
[32m+[m
 if __name__ == '__main__':[m
     app.run(host="0.0.0.0", port=5000, debug=True)[m
[1mdiff --git a/web/static/fonts/iconic/css/material-design-iconic-font.min.css b/web/static/fonts/iconic/css/material-design-iconic-font.min.css[m
[1mindex e1a58fe..34d946e 100644[m
[1m--- a/web/static/fonts/iconic/css/material-design-iconic-font.min.css[m
[1m+++ b/web/static/fonts/iconic/css/material-design-iconic-font.min.css[m
[36m@@ -1 +1,6856 @@[m
[31m-@font-face{font-family:Material-Design-Iconic-Font;src:url(../fonts/Material-Design-Iconic-Font.woff2?v=2.2.0) format('woff2'),url(../fonts/Material-Design-Iconic-Font.woff?v=2.2.0) format('woff'),url(../fonts/Material-Design-Iconic-Font.ttf?v=2.2.0) format('truetype')}.zmdi{display:inline-block;font:normal normal normal 14px/1 'Material-Design-Iconic-Font';font-size:inherit;text-rendering:auto;-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale}.zmdi-hc-lg{font-size:1.33333333em;line-height:.75em;vertical-align:-15%}.zmdi-hc-2x{font-size:2em}.zmdi-hc-3x{font-size:3em}.zmdi-hc-4x{font-size:4em}.zmdi-hc-5x{font-size:5em}.zmdi-hc-fw{width:1.28571429em;text-align:center}.zmdi-hc-ul{padding-left:0;margin-left:2.14285714em;list-style-type:none}.zmdi-hc-ul>li{position:relative}.zmdi-hc-li{position:absolute;left:-2.14285714em;width:2.14285714em;top:.14285714em;text-align:center}.zmdi-hc-li.zmdi-hc-lg{left:-1.85714286em}.zmdi-hc-border{padding:.1em .25em;border:solid .1em #9e9e9e;border-radius:2px}.zmdi-hc-border-circle{padding:.1em .25em;border:solid .1em #9e9e9e;border-radius:50%}.zmdi.pull-left{float:left;margin-right:.15em}.zmdi.pull-right{float:right;margin-left:.15em}.zmdi-hc-spin{-webkit-animation:zmdi-spin 1.5s infinite linear;animation:zmdi-spin 1.5s infinite linear}.zmdi-hc-spin-reverse{-webkit-animation:zmdi-spin-reverse 1.5s infinite linear;animation:zmdi-spin-reverse 1.5s infinite linear}@-webkit-keyframes zmdi-spin{0%{-webkit-transform:rotate(0deg);transform:rotate(0deg)}100%{-webkit-transform:rotate(359deg);transform:rotate(359deg)}}@keyframes zmdi-spin{0%{-webkit-transform:rotate(0deg);transform:rotate(0deg)}100%{-webkit-transform:rotate(359deg);transform:rotate(359deg)}}@-webkit-keyframes zmdi-spin-reverse{0%{-webkit-transform:rotate(0deg);transform:rotate(0deg)}100%{-webkit-transform:rotate(-359deg);transform:rotate(-359deg)}}@keyframes zmdi-spin-reverse{0%{-webkit-transform:rotate(0deg);transform:rotate(0deg)}100%{-webkit-transform:rotate(-359deg);transform:rotate(-359deg)}}.zmdi-hc-rotate-90{-webkit-transform:rotate(90deg);-ms-transform:rotate(90deg);transform:rotate(90deg)}.zmdi-hc-rotate-180{-webkit-transform:rotate(180deg);-ms-transform:rotate(180deg);transform:rotate(180deg)}.zmdi-hc-rotate-270{-webkit-transform:rotate(270deg);-ms-transform:rotate(270deg);transform:rotate(270deg)}.zmdi-hc-flip-horizontal{-webkit-transform:scale(-1,1);-ms-transform:scale(-1,1);transform:scale(-1,1)}.zmdi-hc-flip-vertical{-webkit-transform:scale(1,-1);-ms-transform:scale(1,-1);transform:scale(1,-1)}.zmdi-hc-stack{position:relative;display:inline-block;width:2em;height:2em;line-height:2em;vertical-align:middle}.zmdi-hc-stack-1x,.zmdi-hc-stack-2x{position:absolute;left:0;width:100%;text-align:center}.zmdi-hc-stack-1x{line-height:inherit}.zmdi-hc-stack-2x{font-size:2em}.zmdi-hc-inverse{color:#fff}.zmdi-3d-rotation:before{content:'\f101'}.zmdi-airplane-off:before{content:'\f102'}.zmdi-airplane:before{content:'\f103'}.zmdi-album:before{content:'\f104'}.zmdi-archive:before{content:'\f105'}.zmdi-assignment-account:before{content:'\f106'}.zmdi-assignment-alert:before{content:'\f107'}.zmdi-assignment-check:before{content:'\f108'}.zmdi-assignment-o:before{content:'\f109'}.zmdi-assignment-return:before{content:'\f10a'}.zmdi-assignment-returned:before{content:'\f10b'}.zmdi-assignment:before{content:'\f10c'}.zmdi-attachment-alt:before{content:'\f10d'}.zmdi-attachment:before{content:'\f10e'}.zmdi-audio:before{content:'\f10f'}.zmdi-badge-check:before{content:'\f110'}.zmdi-balance-wallet:before{content:'\f111'}.zmdi-balance:before{content:'\f112'}.zmdi-battery-alert:before{content:'\f113'}.zmdi-battery-flash:before{content:'\f114'}.zmdi-battery-unknown:before{content:'\f115'}.zmdi-battery:before{content:'\f116'}.zmdi-bike:before{content:'\f117'}.zmdi-block-alt:before{content:'\f118'}.zmdi-block:before{content:'\f119'}.zmdi-boat:before{content:'\f11a'}.zmdi-book-image:before{content:'\f11b'}.zmdi-book:before{content:'\f11c'}.zmdi-bookmark-outline:before{content:'\f11d'}.zmdi-bookmark:before{content:'\f11e'}.zmdi-brush:before{content:'\f11f'}.zmdi-bug:before{content:'\f120'}.zmdi-bus:before{content:'\f121'}.zmdi-cake:before{content:'\f122'}.zmdi-car-taxi:before{content:'\f123'}.zmdi-car-wash:before{content:'\f124'}.zmdi-car:before{content:'\f125'}.zmdi-card-giftcard:before{content:'\f126'}.zmdi-card-membership:before{content:'\f127'}.zmdi-card-travel:before{content:'\f128'}.zmdi-card:before{content:'\f129'}.zmdi-case-check:before{content:'\f12a'}.zmdi-case-download:before{content:'\f12b'}.zmdi-case-play:before{content:'\f12c'}.zmdi-case:before{content:'\f12d'}.zmdi-cast-connected:before{content:'\f12e'}.zmdi-cast:before{content:'\f12f'}.zmdi-chart-donut:before{content:'\f130'}.zmdi-chart:before{content:'\f131'}.zmdi-city-alt:before{content:'\f132'}.zmdi-city:before{content:'\f133'}.zmdi-close-circle-o:before{content:'\f134'}.zmdi-close-circle:before{content:'\f135'}.zmdi-close:before{content:'\f136'}.zmdi-cocktail:before{content:'\f137'}.zmdi-code-setting:before{content:'\f138'}.zmdi-code-smartphone:before{content:'\f139'}.zmdi-code:before{content:'\f13a'}.zmdi-coffee:before{content:'\f13b'}.zmdi-collection-bookmark:before{content:'\f13c'}.zmdi-collection-case-play:before{content:'\f13d'}.zmdi-collection-folder-image:before{content:'\f13e'}.zmdi-collection-image-o:before{content:'\f13f'}.zmdi-collection-image:before{content:'\f140'}.zmdi-collection-item-1:before{content:'\f141'}.zmdi-collection-item-2:before{content:'\f142'}.zmdi-collection-item-3:before{content:'\f143'}.zmdi-collection-item-4:before{content:'\f144'}.zmdi-collection-item-5:before{content:'\f145'}.zmdi-collection-item-6:before{content:'\f146'}.zmdi-collection-item-7:before{content:'\f147'}.zmdi-collection-item-8:before{content:'\f148'}.zmdi-collection-item-9-plus:before{content:'\f149'}.zmdi-collection-item-9:before{content:'\f14a'}.zmdi-collection-item:before{content:'\f14b'}.zmdi-collection-music:before{content:'\f14c'}.zmdi-collection-pdf:before{content:'\f14d'}.zmdi-collection-plus:before{content:'\f14e'}.zmdi-collection-speaker:before{content:'\f14f'}.zmdi-collection-text:before{content:'\f150'}.zmdi-collection-video:before{content:'\f151'}.zmdi-compass:before{content:'\f152'}.zmdi-cutlery:before{content:'\f153'}.zmdi-delete:before{content:'\f154'}.zmdi-dialpad:before{content:'\f155'}.zmdi-dns:before{content:'\f156'}.zmdi-drink:before{content:'\f157'}.zmdi-edit:before{content:'\f158'}.zmdi-email-open:before{content:'\f159'}.zmdi-email:before{content:'\f15a'}.zmdi-eye-off:before{content:'\f15b'}.zmdi-eye:before{content:'\f15c'}.zmdi-eyedropper:before{content:'\f15d'}.zmdi-favorite-outline:before{content:'\f15e'}.zmdi-favorite:before{content:'\f15f'}.zmdi-filter-list:before{content:'\f160'}.zmdi-fire:before{content:'\f161'}.zmdi-flag:before{content:'\f162'}.zmdi-flare:before{content:'\f163'}.zmdi-flash-auto:before{content:'\f164'}.zmdi-flash-off:before{content:'\f165'}.zmdi-flash:before{content:'\f166'}.zmdi-flip:before{content:'\f167'}.zmdi-flower-alt:before{content:'\f168'}.zmdi-flower:before{content:'\f169'}.zmdi-font:before{content:'\f16a'}.zmdi-fullscreen-alt:before{content:'\f16b'}.zmdi-fullscreen-exit:before{content:'\f16c'}.zmdi-fullscreen:before{content:'\f16d'}.zmdi-functions:before{content:'\f16e'}.zmdi-gas-station:before{content:'\f16f'}.zmdi-gesture:before{content:'\f170'}.zmdi-globe-alt:before{content:'\f171'}.zmdi-globe-lock:before{content:'\f172'}.zmdi-globe:before{content:'\f173'}.zmdi-graduation-cap:before{content:'\f174'}.zmdi-home:before{content:'\f175'}.zmdi-hospital-alt:before{content:'\f176'}.zmdi-hospital:before{content:'\f177'}.zmdi-hotel:before{content:'\f178'}.zmdi-hourglass-alt:before{content:'\f179'}.zmdi-hourglass-outline:before{content:'\f17a'}.zmdi-hourglass:before{content:'\f17b'}.zmdi-http:before{content:'\f17c'}.zmdi-image-alt:before{content:'\f17d'}.zmdi-image-o:before{content:'\f17e'}.zmdi-image:before{content:'\f17f'}.zmdi-inbox:before{content:'\f180'}.zmdi-invert-colors-off:before{content:'\f181'}.zmdi-invert-colors:before{content:'\f182'}.zmdi-key:before{content:'\f183'}.zmdi-label-alt-outline:before{content:'\f184'}.zmdi-label-alt:before{content:'\f185'}.zmdi-label-heart:before{content:'\f186'}.zmdi-label:before{content:'\f187'}.zmdi-labels:before{content:'\f188'}.zmdi-lamp:before{content:'\f189'}.zmdi-landscape:before{content:'\f18a'}.zmdi-layers-off:before{content:'\f18b'}.zmdi-layers:before{content:'\f18c'}.zmdi-library:before{content:'\f18d'}.zmdi-link:before{content:'\f18e'}.zmdi-lock-open:before{content:'\f18f'}.zmdi-lock-outline:before{content:'\f190'}.zmdi-lock:before{content:'\f191'}.zmdi-mail-reply-all:before{content:'\f192'}.zmdi-mail-reply:before{content:'\f193'}.zmdi-mail-send:before{content:'\f194'}.zmdi-mall:before{content:'\f195'}.zmdi-map:before{content:'\f196'}.zmdi-menu:before{content:'\f197'}.zmdi-money-box:before{content:'\f198'}.zmdi-money-off:before{content:'\f199'}.zmdi-money:before{content:'\f19a'}.zmdi-more-vert:before{content:'\f19b'}.zmdi-more:before{content:'\f19c'}.zmdi-movie-alt:before{content:'\f19d'}.zmdi-movie:before{content:'\f19e'}.zmdi-nature-people:before{content:'\f19f'}.zmdi-nature:before{content:'\f1a0'}.zmdi-navigation:before{content:'\f1a1'}.zmdi-open-in-browser:before{content:'\f1a2'}.zmdi-open-in-new:before{content:'\f1a3'}.zmdi-palette:before{content:'\f1a4'}.zmdi-parking:before{content:'\f1a5'}.zmdi-pin-account:before{content:'\f1a6'}.zmdi-pin-assistant:before{content:'\f1a7'}.zmdi-pin-drop:before{content:'\f1a8'}.zmdi-pin-help:before{content:'\f1a9'}.zmdi-pin-off:before{content:'\f1aa'}.zmdi-pin:before{content:'\f1ab'}.zmdi-pizza:before{content:'\f1ac'}.zmdi-plaster:before{content:'\f1ad'}.zmdi-power-setting:before{content:'\f1ae'}.zmdi-power:before{content:'\f1af'}.zmdi-print:before{content:'\f1b0'}.zmdi-puzzle-piece:before{content:'\f1b1'}.zmdi-quote:before{content:'\f1b2'}.zmdi-railway:before{content:'\f1b3'}.zmdi-receipt:before{content:'\f1b4'}.zmdi-refresh-alt:before{content:'\f1b5'}.zmdi-refresh-sync-alert:before{content:'\f1b6'}.zmdi-refresh-sync-off:before{content:'\f1b7'}.zmdi-refresh-sync:before{content:'\f1b8'}.zmdi-refresh:before{content:'\f1b9'}.zmdi-roller:before{content:'\f1ba'}.zmdi-ruler:before{content:'\f1bb'}.zmdi-scissors:before{content:'\f1bc'}.zmdi-screen-rotation-lock:before{content:'\f1bd'}.zmdi-screen-rotation:before{content:'\f1be'}.zmdi-search-for:before{content:'\f1bf'}.zmdi-search-in-file:before{content:'\f1c0'}.zmdi-search-in-page:before{content:'\f1c1'}.zmdi-search-replace:before{content:'\f1c2'}.zmdi-search:before{content:'\f1c3'}.zmdi-seat:before{content:'\f1c4'}.zmdi-settings-square:before{content:'\f1c5'}.zmdi-settings:before{content:'\f1c6'}.zmdi-shield-check:before{content:'\f1c7'}.zmdi-shield-security:before{content:'\f1c8'}.zmdi-shopping-basket:before{content:'\f1c9'}.zmdi-shopping-cart-plus:before{content:'\f1ca'}.zmdi-shopping-cart:before{content:'\f1cb'}.zmdi-sign-in:before{content:'\f1cc'}.zmdi-sort-amount-asc:before{content:'\f1cd'}.zmdi-sort-amount-desc:before{content:'\f1ce'}.zmdi-sort-asc:before{content:'\f1cf'}.zmdi-sort-desc:before{content:'\f1d0'}.zmdi-spellcheck:before{content:'\f1d1'}.zmdi-storage:before{content:'\f1d2'}.zmdi-store-24:before{content:'\f1d3'}.zmdi-store:before{content:'\f1d4'}.zmdi-subway:before{content:'\f1d5'}.zmdi-sun:before{content:'\f1d6'}.zmdi-tab-unselected:before{content:'\f1d7'}.zmdi-tab:before{content:'\f1d8'}.zmdi-tag-close:before{content:'\f1d9'}.zmdi-tag-more:before{content:'\f1da'}.zmdi-tag:before{content:'\f1db'}.zmdi-thumb-down:before{content:'\f1dc'}.zmdi-thumb-up-down:before{content:'\f1dd'}.zmdi-thumb-up:before{content:'\f1de'}.zmdi-ticket-star:before{content:'\f1df'}.zmdi-toll:before{content:'\f1e0'}.zmdi-toys:before{content:'\f1e1'}.zmdi-traffic:before{content:'\f1e2'}.zmdi-translate:before{content:'\f1e3'}.zmdi-triangle-down:before{content:'\f1e4'}.zmdi-triangle-up:before{content:'\f1e5'}.zmdi-truck:before{content:'\f1e6'}.zmdi-turning-sign:before{content:'\f1e7'}.zmdi-wallpaper:before{content:'\f1e8'}.zmdi-washing-machine:before{content:'\f1e9'}.zmdi-window-maximize:before{content:'\f1ea'}.zmdi-window-minimize:before{content:'\f1eb'}.zmdi-window-restore:before{content:'\f1ec'}.zmdi-wrench:before{content:'\f1ed'}.zmdi-zoom-in:before{content:'\f1ee'}.zmdi-zoom-out:before{content:'\f1ef'}.zmdi-alert-circle-o:before{content:'\f1f0'}.zmdi-alert-circle:before{content:'\f1f1'}.zmdi-alert-octagon:before{content:'\f1f2'}.zmdi-alert-polygon:before{content:'\f1f3'}.zmdi-alert-triangle:before{content:'\f1f4'}.zmdi-help-outline:before{content:'\f1f5'}.zmdi-help:before{content:'\f1f6'}.zmdi-info-outline:before{content:'\f1f7'}.zmdi-info:before{content:'\f1f8'}.zmdi-notifications-active:before{content:'\f1f9'}.zmdi-notifications-add:before{content:'\f1fa'}.zmdi-notifications-none:before{content:'\f1fb'}.zmdi-notifications-off:before{content:'\f1fc'}.zmdi-notifications-paused:before{content:'\f1fd'}.zmdi-notifications:before{content:'\f1fe'}.zmdi-account-add:before{content:'\f1ff'}.zmdi-account-box-mail:before{content:'\f200'}.zmdi-account-box-o:before{content:'\f201'}.zmdi-account-box-phone:before{content:'\f202'}.zmdi-account-box:before{content:'\f203'}.zmdi-account-calendar:before{content:'\f204'}.zmdi-account-circle:before{content:'\f205'}.zmdi-account-o:before{content:'\f206'}.zmdi-account:before{content:'\f207'}.zmdi-accounts-add:before{content:'\f208'}.zmdi-accounts-alt:before{content:'\f209'}.zmdi-accounts-list-alt:before{content:'\f20a'}.zmdi-accounts-list:before{content:'\f20b'}.zmdi-accounts-outline:before{content:'\f20c'}.zmdi-accounts:before{content:'\f20d'}.zmdi-face:before{content:'\f20e'}.zmdi-female:before{content:'\f20f'}.zmdi-male-alt:before{content:'\f210'}.zmdi-male-female:before{content:'\f211'}.zmdi-male:before{content:'\f212'}.zmdi-mood-bad:before{content:'\f213'}.zmdi-mood:before{content:'\f214'}.zmdi-run:before{content:'\f215'}.zmdi-walk:before{content:'\f216'}.zmdi-cloud-box:before{content:'\f217'}.zmdi-cloud-circle:before{content:'\f218'}.zmdi-cloud-done:before{content:'\f219'}.zmdi-cloud-download:before{content:'\f21a'}.zmdi-cloud-off:before{content:'\f21b'}.zmdi-cloud-outline-alt:before{content:'\f21c'}.zmdi-cloud-outline:before{content:'\f21d'}.zmdi-cloud-upload:before{content:'\f21e'}.zmdi-cloud:before{content:'\f21f'}.zmdi-download:before{content:'\f220'}.zmdi-file-plus:before{content:'\f221'}.zmdi-file-text:before{content:'\f222'}.zmdi-file:before{content:'\f223'}.zmdi-folder-outline:before{content:'\f224'}.zmdi-folder-person:before{content:'\f225'}.zmdi-folder-star-alt:before{content:'\f226'}.zmdi-folder-star:before{content:'\f227'}.zmdi-folder:before{content:'\f228'}.zmdi-gif:before{content:'\f229'}.zmdi-upload:before{content:'\f22a'}.zmdi-border-all:before{content:'\f22b'}.zmdi-border-bottom:before{content:'\f22c'}.zmdi-border-clear:before{content:'\f22d'}.zmdi-border-color:before{content:'\f22e'}.zmdi-border-horizontal:before{content:'\f22f'}.zmdi-border-inner:before{content:'\f230'}.zmdi-border-left:before{content:'\f231'}.zmdi-border-outer:before{content:'\f232'}.zmdi-border-right:before{content:'\f233'}.zmdi-border-style:before{content:'\f234'}.zmdi-border-top:before{content:'\f235'}.zmdi-border-vertical:before{content:'\f236'}.zmdi-copy:before{content:'\f237'}.zmdi-crop:before{content:'\f238'}.zmdi-format-align-center:before{content:'\f239'}.zmdi-format-align-justify:before{content:'\f23a'}.zmdi-format-align-left:before{content:'\f23b'}.zmdi-format-align-right:before{content:'\f23c'}.zmdi-format-bold:before{content:'\f23d'}.zmdi-format-clear-all:before{content:'\f23e'}.zmdi-format-clear:before{content:'\f23f'}.zmdi-format-color-fill:before{content:'\f240'}.zmdi-format-color-reset:before{content:'\f241'}.zmdi-format-color-text:before{content:'\f242'}.zmdi-format-indent-decrease:before{content:'\f243'}.zmdi-format-indent-increase:before{content:'\f244'}.zmdi-format-italic:before{content:'\f245'}.zmdi-format-line-spacing:before{content:'\f246'}.zmdi-format-list-bulleted:before{content:'\f247'}.zmdi-format-list-numbered:before{content:'\f248'}.zmdi-format-ltr:before{content:'\f249'}.zmdi-format-rtl:before{content:'\f24a'}.zmdi-format-size:before{content:'\f24b'}.zmdi-format-strikethrough-s:before{content:'\f24c'}.zmdi-format-strikethrough:before{content:'\f24d'}.zmdi-format-subject:before{content:'\f24e'}.zmdi-format-underlined:before{content:'\f24f'}.zmdi-format-valign-bottom:before{content:'\f250'}.zmdi-format-valign-center:before{content:'\f251'}.zmdi-format-valign-top:before{content:'\f252'}.zmdi-redo:before{content:'\f253'}.zmdi-select-all:before{content:'\f254'}.zmdi-space-bar:before{content:'\f255'}.zmdi-text-format:before{content:'\f256'}.zmdi-transform:before{content:'\f257'}.zmdi-undo:before{content:'\f258'}.zmdi-wrap-text:before{content:'\f259'}.zmdi-comment-alert:before{content:'\f25a'}.zmdi-comment-alt-text:before{content:'\f25b'}.zmdi-comment-alt:before{content:'\f25c'}.zmdi-comment-edit:before{content:'\f25d'}.zmdi-comment-image:before{content:'\f25e'}.zmdi-comment-list:before{content:'\f25f'}.zmdi-comment-more:before{content:'\f260'}.zmdi-comment-outline:before{content:'\f261'}.zmdi-comment-text-alt:before{content:'\f262'}.zmdi-comment-text:before{content:'\f263'}.zmdi-comment-video:before{content:'\f264'}.zmdi-comment:before{content:'\f265'}.zmdi-comments:before{content:'\f266'}.zmdi-check-all:before{content:'\f267'}.zmdi-check-circle-u:before{content:'\f268'}.zmdi-check-circle:before{content:'\f269'}.zmdi-check-square:before{content:'\f26a'}.zmdi-check:before{content:'\f26b'}.zmdi-circle-o:before{content:'\f26c'}.zmdi-circle:before{content:'\f26d'}.zmdi-dot-circle-alt:before{content:'\f26e'}.zmdi-dot-circle:before{content:'\f26f'}.zmdi-minus-circle-outline:before{content:'\f270'}.zmdi-minus-circle:before{content:'\f271'}.zmdi-minus-square:before{content:'\f272'}.zmdi-minus:before{content:'\f273'}.zmdi-plus-circle-o-duplicate:before{content:'\f274'}.zmdi-plus-circle-o:before{content:'\f275'}.zmdi-plus-circle:before{content:'\f276'}.zmdi-plus-square:before{content:'\f277'}.zmdi-plus:before{content:'\f278'}.zmdi-square-o:before{content:'\f279'}.zmdi-star-circle:before{content:'\f27a'}.zmdi-star-half:before{content:'\f27b'}.zmdi-star-outline:before{content:'\f27c'}.zmdi-star:before{content:'\f27d'}.zmdi-bluetooth-connected:before{content:'\f27e'}.zmdi-bluetooth-off:before{content:'\f27f'}.zmdi-bluetooth-search:before{content:'\f280'}.zmdi-bluetooth-setting:before{content:'\f281'}.zmdi-bluetooth:before{content:'\f282'}.zmdi-camera-add:before{content:'\f283'}.zmdi-camera-alt:before{content:'\f284'}.zmdi-camera-bw:before{content:'\f285'}.zmdi-camera-front:before{content:'\f286'}.zmdi-camera-mic:before{content:'\f287'}.zmdi-camera-party-mode:before{content:'\f288'}.zmdi-camera-rear:before{content:'\f289'}.zmdi-camera-roll:before{content:'\f28a'}.zmdi-camera-switch:before{content:'\f28b'}.zmdi-camera:before{content:'\f28c'}.zmdi-card-alert:before{content:'\f28d'}.zmdi-card-off:before{content:'\f28e'}.zmdi-card-sd:before{content:'\f28f'}.zmdi-card-sim:before{content:'\f290'}.zmdi-desktop-mac:before{content:'\f291'}.zmdi-desktop-windows:before{content:'\f292'}.zmdi-device-hub:before{content:'\f293'}.zmdi-devices-off:before{content:'\f294'}.zmdi-devices:before{content:'\f295'}.zmdi-dock:before{content:'\f296'}.zmdi-floppy:before{content:'\f297'}.zmdi-gamepad:before{content:'\f298'}.zmdi-gps-dot:before{content:'\f299'}.zmdi-gps-off:before{content:'\f29a'}.zmdi-gps:before{content:'\f29b'}.zmdi-headset-mic:before{content:'\f29c'}.zmdi-headset:before{content:'\f29d'}.zmdi-input-antenna:before{content:'\f29e'}.zmdi-input-composite:before{content:'\f29f'}.zmdi-input-hdmi:before{content:'\f2a0'}.zmdi-input-power:before{content:'\f2a1'}.zmdi-input-svideo:before{content:'\f2a2'}.zmdi-keyboard-hide:before{content:'\f2a3'}.zmdi-keyboard:before{content:'\f2a4'}.zmdi-laptop-chromebook:before{content:'\f2a5'}.zmdi-laptop-mac:before{content:'\f2a6'}.zmdi-laptop:before{content:'\f2a7'}.zmdi-mic-off:before{content:'\f2a8'}.zmdi-mic-outline:before{content:'\f2a9'}.zmdi-mic-setting:before{content:'\f2aa'}.zmdi-mic:before{content:'\f2ab'}.zmdi-mouse:before{content:'\f2ac'}.zmdi-network-alert:before{content:'\f2ad'}.zmdi-network-locked:before{content:'\f2ae'}.zmdi-network-off:before{content:'\f2af'}.zmdi-network-outline:before{content:'\f2b0'}.zmdi-network-setting:before{content:'\f2b1'}.zmdi-network:before{content:'\f2b2'}.zmdi-phone-bluetooth:before{content:'\f2b3'}.zmdi-phone-end:before{content:'\f2b4'}.zmdi-phone-forwarded:before{content:'\f2b5'}.zmdi-phone-in-talk:before{content:'\f2b6'}.zmdi-phone-locked:before{content:'\f2b7'}.zmdi-phone-missed:before{content:'\f2b8'}.zmdi-phone-msg:before{content:'\f2b9'}.zmdi-phone-paused:before{content:'\f2ba'}.zmdi-phone-ring:before{content:'\f2bb'}.zmdi-phone-setting:before{content:'\f2bc'}.zmdi-phone-sip:before{content:'\f2bd'}.zmdi-phone:before{content:'\f2be'}.zmdi-portable-wifi-changes:before{content:'\f2bf'}.zmdi-portable-wifi-off:before{content:'\f2c0'}.zmdi-portable-wifi:before{content:'\f2c1'}.zmdi-radio:before{content:'\f2c2'}.zmdi-reader:before{content:'\f2c3'}.zmdi-remote-control-alt:before{content:'\f2c4'}.zmdi-remote-control:before{content:'\f2c5'}.zmdi-router:before{content:'\f2c6'}.zmdi-scanner:before{content:'\f2c7'}.zmdi-smartphone-android:before{content:'\f2c8'}.zmdi-smartphone-download:before{content:'\f2c9'}.zmdi-smartphone-erase:before{content:'\f2ca'}.zmdi-smartphone-info:before{content:'\f2cb'}.zmdi-smartphone-iphone:before{content:'\f2cc'}.zmdi-smartphone-landscape-lock:before{content:'\f2cd'}.zmdi-smartphone-landscape:before{content:'\f2ce'}.zmdi-smartphone-lock:before{content:'\f2cf'}.zmdi-smartphone-portrait-lock:before{content:'\f2d0'}.zmdi-smartphone-ring:before{content:'\f2d1'}.zmdi-smartphone-setting:before{content:'\f2d2'}.zmdi-smartphone-setup:before{content:'\f2d3'}.zmdi-smartphone:before{content:'\f2d4'}.zmdi-speaker:before{content:'\f2d5'}.zmdi-tablet-android:before{content:'\f2d6'}.zmdi-tablet-mac:before{content:'\f2d7'}.zmdi-tablet:before{content:'\f2d8'}.zmdi-tv-alt-play:before{content:'\f2d9'}.zmdi-tv-list:before{content:'\f2da'}.zmdi-tv-play:before{content:'\f2db'}.zmdi-tv:before{content:'\f2dc'}.zmdi-usb:before{content:'\f2dd'}.zmdi-videocam-off:before{content:'\f2de'}.zmdi-videocam-switch:before{content:'\f2df'}.zmdi-videocam:before{content:'\f2e0'}.zmdi-watch:before{content:'\f2e1'}.zmdi-wifi-alt-2:before{content:'\f2e2'}.zmdi-wifi-alt:before{content:'\f2e3'}.zmdi-wifi-info:before{content:'\f2e4'}.zmdi-wifi-lock:before{content:'\f2e5'}.zmdi-wifi-off:before{content:'\f2e6'}.zmdi-wifi-outline:before{content:'\f2e7'}.zmdi-wifi:before{content:'\f2e8'}.zmdi-arrow-left-bottom:before{content:'\f2e9'}.zmdi-arrow-left:before{content:'\f2ea'}.zmdi-arrow-merge:before{content:'\f2eb'}.zmdi-arrow-missed:before{content:'\f2ec'}.zmdi-arrow-right-top:before{content:'\f2ed'}.zmdi-arrow-right:before{content:'\f2ee'}.zmdi-arrow-split:before{content:'\f2ef'}.zmdi-arrows:before{content:'\f2f0'}.zmdi-caret-down-circle:before{content:'\f2f1'}.zmdi-caret-down:before{content:'\f2f2'}.zmdi-caret-left-circle:before{content:'\f2f3'}.zmdi-caret-left:before{content:'\f2f4'}.zmdi-caret-right-circle:before{content:'\f2f5'}.zmdi-caret-right:before{content:'\f2f6'}.zmdi-caret-up-circle:before{content:'\f2f7'}.zmdi-caret-up:before{content:'\f2f8'}.zmdi-chevron-down:before{content:'\f2f9'}.zmdi-chevron-left:before{content:'\f2fa'}.zmdi-chevron-right:before{content:'\f2fb'}.zmdi-chevron-up:before{content:'\f2fc'}.zmdi-forward:before{content:'\f2fd'}.zmdi-long-arrow-down:before{content:'\f2fe'}.zmdi-long-arrow-left:before{content:'\f2ff'}.zmdi-long-arrow-return:before{content:'\f300'}.zmdi-long-arrow-right:before{content:'\f301'}.zmdi-long-arrow-tab:before{content:'\f302'}.zmdi-long-arrow-up:before{content:'\f303'}.zmdi-rotate-ccw:before{content:'\f304'}.zmdi-rotate-cw:before{content:'\f305'}.zmdi-rotate-left:before{content:'\f306'}.zmdi-rotate-right:before{content:'\f307'}.zmdi-square-down:before{content:'\f308'}.zmdi-square-right:before{content:'\f309'}.zmdi-swap-alt:before{content:'\f30a'}.zmdi-swap-vertical-circle:before{content:'\f30b'}.zmdi-swap-vertical:before{content:'\f30c'}.zmdi-swap:before{content:'\f30d'}.zmdi-trending-down:before{content:'\f30e'}.zmdi-trending-flat:before{content:'\f30f'}.zmdi-trending-up:before{content:'\f310'}.zmdi-unfold-less:before{content:'\f311'}.zmdi-unfold-more:before{content:'\f312'}.zmdi-apps:before{content:'\f313'}.zmdi-grid-off:before{content:'\f314'}.zmdi-grid:before{content:'\f315'}.zmdi-view-agenda:before{content:'\f316'}.zmdi-view-array:before{content:'\f317'}.zmdi-view-carousel:before{content:'\f318'}.zmdi-view-column:before{content:'\f319'}.zmdi-view-comfy:before{content:'\f31a'}.zmdi-view-compact:before{content:'\f31b'}.zmdi-view-dashboard:before{content:'\f31c'}.zmdi-view-day:before{content:'\f31d'}.zmdi-view-headline:before{content:'\f31e'}.zmdi-view-list-alt:before{content:'\f31f'}.zmdi-view-list:before{content:'\f320'}.zmdi-view-module:before{content:'\f321'}.zmdi-view-quilt:before{content:'\f322'}.zmdi-view-stream:before{content:'\f323'}.zmdi-view-subtitles:before{content:'\f324'}.zmdi-view-toc:before{content:'\f325'}.zmdi-view-web:before{content:'\f326'}.zmdi-view-week:before{content:'\f327'}.zmdi-widgets:before{content:'\f328'}.zmdi-alarm-check:before{content:'\f329'}.zmdi-alarm-off:before{content:'\f32a'}.zmdi-alarm-plus:before{content:'\f32b'}.zmdi-alarm-snooze:before{content:'\f32c'}.zmdi-alarm:before{content:'\f32d'}.zmdi-calendar-alt:before{content:'\f32e'}.zmdi-calendar-check:before{content:'\f32f'}.zmdi-calendar-close:before{content:'\f330'}.zmdi-calendar-note:before{content:'\f331'}.zmdi-calendar:before{content:'\f332'}.zmdi-time-countdown:before{content:'\f333'}.zmdi-time-interval:before{content:'\f334'}.zmdi-time-restore-setting:before{content:'\f335'}.zmdi-time-restore:before{content:'\f336'}.zmdi-time:before{content:'\f337'}.zmdi-timer-off:before{content:'\f338'}.zmdi-timer:before{content:'\f339'}.zmdi-android-alt:before{content:'\f33a'}.zmdi-android:before{content:'\f33b'}.zmdi-apple:before{content:'\f33c'}.zmdi-behance:before{content:'\f33d'}.zmdi-codepen:before{content:'\f33e'}.zmdi-dribbble:before{content:'\f33f'}.zmdi-dropbox:before{content:'\f340'}.zmdi-evernote:before{content:'\f341'}.zmdi-facebook-box:before{content:'\f342'}.zmdi-facebook:before{content:'\f343'}.zmdi-github-box:before{content:'\f344'}.zmdi-github:before{content:'\f345'}.zmdi-google-drive:before{content:'\f346'}.zmdi-google-earth:before{content:'\f347'}.zmdi-google-glass:before{content:'\f348'}.zmdi-google-maps:before{content:'\f349'}.zmdi-google-pages:before{content:'\f34a'}.zmdi-google-play:before{content:'\f34b'}.zmdi-google-plus-box:before{content:'\f34c'}.zmdi-google-plus:before{content:'\f34d'}.zmdi-google:before{content:'\f34e'}.zmdi-instagram:before{content:'\f34f'}.zmdi-language-css3:before{content:'\f350'}.zmdi-language-html5:before{content:'\f351'}.zmdi-language-javascript:before{content:'\f352'}.zmdi-language-python-alt:before{content:'\f353'}.zmdi-language-python:before{content:'\f354'}.zmdi-lastfm:before{content:'\f355'}.zmdi-linkedin-box:before{content:'\f356'}.zmdi-paypal:before{content:'\f357'}.zmdi-pinterest-box:before{content:'\f358'}.zmdi-pocket:before{content:'\f359'}.zmdi-polymer:before{content:'\f35a'}.zmdi-share:before{content:'\f35b'}.zmdi-stackoverflow:before{content:'\f35c'}.zmdi-steam-square:before{content:'\f35d'}.zmdi-steam:before{content:'\f35e'}.zmdi-twitter-box:before{content:'\f35f'}.zmdi-twitter:before{content:'\f360'}.zmdi-vk:before{content:'\f361'}.zmdi-wikipedia:before{content:'\f362'}.zmdi-windows:before{content:'\f363'}.zmdi-aspect-ratio-alt:before{content:'\f364'}.zmdi-aspect-ratio:before{content:'\f365'}.zmdi-blur-circular:before{content:'\f366'}.zmdi-blur-linear:before{content:'\f367'}.zmdi-blur-off:before{content:'\f368'}.zmdi-blur:before{content:'\f369'}.zmdi-brightness-2:before{content:'\f36a'}.zmdi-brightness-3:before{content:'\f36b'}.zmdi-brightness-4:before{content:'\f36c'}.zmdi-brightness-5:before{content:'\f36d'}.zmdi-brightness-6:before{content:'\f36e'}.zmdi-brightness-7:before{content:'\f36f'}.zmdi-brightness-auto:before{content:'\f370'}.zmdi-brightness-setting:before{content:'\f371'}.zmdi-broken-image:before{content:'\f372'}.zmdi-center-focus-strong:before{content:'\f373'}.zmdi-center-focus-weak:before{content:'\f374'}.zmdi-compare:before{content:'\f375'}.zmdi-crop-16-9:before{content:'\f376'}.zmdi-crop-3-2:before{content:'\f377'}.zmdi-crop-5-4:before{content:'\f378'}.zmdi-crop-7-5:before{content:'\f379'}.zmdi-crop-din:before{content:'\f37a'}.zmdi-crop-free:before{content:'\f37b'}.zmdi-crop-landscape:before{content:'\f37c'}.zmdi-crop-portrait:before{content:'\f37d'}.zmdi-crop-square:before{content:'\f37e'}.zmdi-exposure-alt:before{content:'\f37f'}.zmdi-exposure:before{content:'\f380'}.zmdi-filter-b-and-w:before{content:'\f381'}.zmdi-filter-center-focus:before{content:'\f382'}.zmdi-filter-frames:before{content:'\f383'}.zmdi-filter-tilt-shift:before{content:'\f384'}.zmdi-gradient:before{content:'\f385'}.zmdi-grain:before{content:'\f386'}.zmdi-graphic-eq:before{content:'\f387'}.zmdi-hdr-off:before{content:'\f388'}.zmdi-hdr-strong:before{content:'\f389'}.zmdi-hdr-weak:before{content:'\f38a'}.zmdi-hdr:before{content:'\f38b'}.zmdi-iridescent:before{content:'\f38c'}.zmdi-leak-off:before{content:'\f38d'}.zmdi-leak:before{content:'\f38e'}.zmdi-looks:before{content:'\f38f'}.zmdi-loupe:before{content:'\f390'}.zmdi-panorama-horizontal:before{content:'\f391'}.zmdi-panorama-vertical:before{content:'\f392'}.zmdi-panorama-wide-angle:before{content:'\f393'}.zmdi-photo-size-select-large:before{content:'\f394'}.zmdi-photo-size-select-small:before{content:'\f395'}.zmdi-picture-in-picture:before{content:'\f396'}.zmdi-slideshow:before{content:'\f397'}.zmdi-texture:before{content:'\f398'}.zmdi-tonality:before{content:'\f399'}.zmdi-vignette:before{content:'\f39a'}.zmdi-wb-auto:before{content:'\f39b'}.zmdi-eject-alt:before{content:'\f39c'}.zmdi-eject:before{content:'\f39d'}.zmdi-equalizer:before{content:'\f39e'}.zmdi-fast-forward:before{content:'\f39f'}.zmdi-fast-rewind:before{content:'\f3a0'}.zmdi-forward-10:before{content:'\f3a1'}.zmdi-forward-30:before{content:'\f3a2'}.zmdi-forward-5:before{content:'\f3a3'}.zmdi-hearing:before{content:'\f3a4'}.zmdi-pause-circle-outline:before{content:'\f3a5'}.zmdi-pause-circle:before{content:'\f3a6'}.zmdi-pause:before{content:'\f3a7'}.zmdi-play-circle-outline:before{content:'\f3a8'}.zmdi-play-circle:before{content:'\f3a9'}.zmdi-play:before{content:'\f3aa'}.zmdi-playlist-audio:before{content:'\f3ab'}.zmdi-playlist-plus:before{content:'\f3ac'}.zmdi-repeat-one:before{content:'\f3ad'}.zmdi-repeat:before{content:'\f3ae'}.zmdi-replay-10:before{content:'\f3af'}.zmdi-replay-30:before{content:'\f3b0'}.zmdi-replay-5:before{content:'\f3b1'}.zmdi-replay:before{content:'\f3b2'}.zmdi-shuffle:before{content:'\f3b3'}.zmdi-skip-next:before{content:'\f3b4'}.zmdi-skip-previous:before{content:'\f3b5'}.zmdi-stop:before{content:'\f3b6'}.zmdi-surround-sound:before{content:'\f3b7'}.zmdi-tune:before{content:'\f3b8'}.zmdi-volume-down:before{content:'\f3b9'}.zmdi-volume-mute:before{content:'\f3ba'}.zmdi-volume-off:before{content:'\f3bb'}.zmdi-volume-up:before{content:'\f3bc'}.zmdi-n-1-square:before{content:'\f3bd'}.zmdi-n-2-square:before{content:'\f3be'}.zmdi-n-3-square:before{content:'\f3bf'}.zmdi-n-4-square:before{content:'\f3c0'}.zmdi-n-5-square:before{content:'\f3c1'}.zmdi-n-6-square:before{content:'\f3c2'}.zmdi-neg-1:before{content:'\f3c3'}.zmdi-neg-2:before{content:'\f3c4'}.zmdi-plus-1:before{content:'\f3c5'}.zmdi-plus-2:before{content:'\f3c6'}.zmdi-sec-10:before{content:'\f3c7'}.zmdi-sec-3:before{content:'\f3c8'}.zmdi-zero:before{content:'\f3c9'}.zmdi-airline-seat-flat-angled:before{content:'\f3ca'}.zmdi-airline-seat-flat:before{content:'\f3cb'}.zmdi-airline-seat-individual-suite:before{content:'\f3cc'}.zmdi-airline-seat-legroom-extra:before{content:'\f3cd'}.zmdi-airline-seat-legroom-normal:before{content:'\f3ce'}.zmdi-airline-seat-legroom-reduced:before{content:'\f3cf'}.zmdi-airline-seat-recline-extra:before{content:'\f3d0'}.zmdi-airline-seat-recline-normal:before{content:'\f3d1'}.zmdi-airplay:before{content:'\f3d2'}.zmdi-closed-caption:before{content:'\f3d3'}.zmdi-confirmation-number:before{content:'\f3d4'}.zmdi-developer-board:before{content:'\f3d5'}.zmdi-disc-full:before{content:'\f3d6'}.zmdi-explicit:before{content:'\f3d7'}.zmdi-flight-land:before{content:'\f3d8'}.zmdi-flight-takeoff:before{content:'\f3d9'}.zmdi-flip-to-back:before{content:'\f3da'}.zmdi-flip-to-front:before{content:'\f3db'}.zmdi-group-work:before{content:'\f3dc'}.zmdi-hd:before{content:'\f3dd'}.zmdi-hq:before{content:'\f3de'}.zmdi-markunread-mailbox:before{content:'\f3df'}.zmdi-memory:before{content:'\f3e0'}.zmdi-nfc:before{content:'\f3e1'}.zmdi-play-for-work:before{content:'\f3e2'}.zmdi-power-input:before{content:'\f3e3'}.zmdi-present-to-all:before{content:'\f3e4'}.zmdi-satellite:before{content:'\f3e5'}.zmdi-tap-and-play:before{content:'\f3e6'}.zmdi-vibration:before{content:'\f3e7'}.zmdi-voicemail:before{content:'\f3e8'}.zmdi-group:before{content:'\f3e9'}.zmdi-rss:before{content:'\f3ea'}.zmdi-shape:before{content:'\f3eb'}.zmdi-spinner:before{content:'\f3ec'}.zmdi-ungroup:before{content:'\f3ed'}.zmdi-500px:before{content:'\f3ee'}.zmdi-8tracks:before{content:'\f3ef'}.zmdi-amazon:before{content:'\f3f0'}.zmdi-blogger:before{content:'\f3f1'}.zmdi-delicious:before{content:'\f3f2'}.zmdi-disqus:before{content:'\f3f3'}.zmdi-flattr:before{content:'\f3f4'}.zmdi-flickr:before{content:'\f3f5'}.zmdi-github-alt:before{content:'\f3f6'}.zmdi-google-old:before{content:'\f3f7'}.zmdi-linkedin:before{content:'\f3f8'}.zmdi-odnoklassniki:before{content:'\f3f9'}.zmdi-outlook:before{content:'\f3fa'}.zmdi-paypal-alt:before{content:'\f3fb'}.zmdi-pinterest:before{content:'\f3fc'}.zmdi-playstation:before{content:'\f3fd'}.zmdi-reddit:before{content:'\f3fe'}.zmdi-skype:before{content:'\f3ff'}.zmdi-slideshare:before{content:'\f400'}.zmdi-soundcloud:before{content:'\f401'}.zmdi-tumblr:before{content:'\f402'}.zmdi-twitch:before{content:'\f403'}.zmdi-vimeo:before{content:'\f404'}.zmdi-whatsapp:before{content:'\f405'}.zmdi-xbox:before{content:'\f406'}.zmdi-yahoo:before{content:'\f407'}.zmdi-youtube-play:before{content:'\f408'}.zmdi-youtube:before{content:'\f409'}.zmdi-3d-rotation:before{content:'\f101'}.zmdi-airplane-off:before{content:'\f102'}.zmdi-airplane:before{content:'\f103'}.zmdi-album:before{content:'\f104'}.zmdi-archive:before{content:'\f105'}.zmdi-assignment-account:before{content:'\f106'}.zmdi-assignment-alert:before{content:'\f107'}.zmdi-assignment-check:before{content:'\f108'}.zmdi-assignment-o:before{content:'\f109'}.zmdi-assignment-return:before{content:'\f10a'}.zmdi-assignment-returned:before{content:'\f10b'}.zmdi-assignment:before{content:'\f10c'}.zmdi-attachment-alt:before{content:'\f10d'}.zmdi-attachment:before{content:'\f10e'}.zmdi-audio:before{content:'\f10f'}.zmdi-badge-check:before{content:'\f110'}.zmdi-balance-wallet:before{content:'\f111'}.zmdi-balance:before{content:'\f112'}.zmdi-battery-alert:before{content:'\f113'}.zmdi-battery-flash:before{content:'\f114'}.zmdi-battery-unknown:before{content:'\f115'}.zmdi-battery:before{content:'\f116'}.zmdi-bike:before{content:'\f117'}.zmdi-block-alt:before{content:'\f118'}.zmdi-block:before{content:'\f119'}.zmdi-boat:before{content:'\f11a'}.zmdi-book-image:before{content:'\f11b'}.zmdi-book:before{content:'\f11c'}.zmdi-bookmark-outline:before{content:'\f11d'}.zmdi-bookmark:before{content:'\f11e'}.zmdi-brush:before{content:'\f11f'}.zmdi-bug:before{content:'\f120'}.zmdi-bus:before{content:'\f121'}.zmdi-cake:before{content:'\f122'}.zmdi-car-taxi:before{content:'\f123'}.zmdi-car-wash:before{content:'\f124'}.zmdi-car:before{content:'\f125'}.zmdi-card-giftcard:before{content:'\f126'}.zmdi-card-membership:before{content:'\f127'}.zmdi-card-travel:before{content:'\f128'}.zmdi-card:before{content:'\f129'}.zmdi-case-check:before{content:'\f12a'}.zmdi-case-download:before{content:'\f12b'}.zmdi-case-play:before{content:'\f12c'}.zmdi-case:before{content:'\f12d'}.zmdi-cast-connected:before{content:'\f12e'}.zmdi-cast:before{content:'\f12f'}.zmdi-chart-donut:before{content:'\f130'}.zmdi-chart:before{content:'\f131'}.zmdi-city-alt:before{content:'\f132'}.zmdi-city:before{content:'\f133'}.zmdi-close-circle-o:before{content:'\f134'}.zmdi-close-circle:before{content:'\f135'}.zmdi-close:before{content:'\f136'}.zmdi-cocktail:before{content:'\f137'}.zmdi-code-setting:before{content:'\f138'}.zmdi-code-smartphone:before{content:'\f139'}.zmdi-code:before{content:'\f13a'}.zmdi-coffee:before{content:'\f13b'}.zmdi-collection-bookmark:before{content:'\f13c'}.zmdi-collection-case-play:before{content:'\f13d'}.zmdi-collection-folder-image:before{content:'\f13e'}.zmdi-collection-image-o:before{content:'\f13f'}.zmdi-collection-image:before{content:'\f140'}.zmdi-collection-item-1:before{content:'\f141'}.zmdi-collection-item-2:before{content:'\f142'}.zmdi-collection-item-3:before{content:'\f143'}.zmdi-collection-item-4:before{content:'\f144'}.zmdi-collection-item-5:before{content:'\f145'}.zmdi-collection-item-6:before{content:'\f146'}.zmdi-collection-item-7:before{content:'\f147'}.zmdi-collection-item-8:before{content:'\f148'}.zmdi-collection-item-9-plus:before{content:'\f149'}.zmdi-collection-item-9:before{content:'\f14a'}.zmdi-collection-item:before{content:'\f14b'}.zmdi-collection-music:before{content:'\f14c'}.zmdi-collection-pdf:before{content:'\f14d'}.zmdi-collection-plus:before{content:'\f14e'}.zmdi-collection-speaker:before{content:'\f14f'}.zmdi-collection-text:before{content:'\f150'}.zmdi-collection-video:before{content:'\f151'}.zmdi-compass:before{content:'\f152'}.zmdi-cutlery:before{content:'\f153'}.zmdi-delete:before{content:'\f154'}.zmdi-dialpad:before{content:'\f155'}.zmdi-dns:before{content:'\f156'}.zmdi-drink:before{content:'\f157'}.zmdi-edit:before{content:'\f158'}.zmdi-email-open:before{content:'\f159'}.zmdi-email:before{content:'\f15a'}.zmdi-eye-off:before{content:'\f15b'}.zmdi-eye:before{content:'\f15c'}.zmdi-eyedropper:before{content:'\f15d'}.zmdi-favorite-outline:before{content:'\f15e'}.zmdi-favorite:before{content:'\f15f'}.zmdi-filter-list:before{content:'\f160'}.zmdi-fire:before{content:'\f161'}.zmdi-flag:before{content:'\f162'}.zmdi-flare:before{content:'\f163'}.zmdi-flash-auto:before{content:'\f164'}.zmdi-flash-off:before{content:'\f165'}.zmdi-flash:before{content:'\f166'}.zmdi-flip:before{content:'\f167'}.zmdi-flower-alt:before{content:'\f168'}.zmdi-flower:before{content:'\f169'}.zmdi-font:before{content:'\f16a'}.zmdi-fullscreen-alt:before{content:'\f16b'}.zmdi-fullscreen-exit:before{content:'\f16c'}.zmdi-fullscreen:before{content:'\f16d'}.zmdi-functions:before{content:'\f16e'}.zmdi-gas-station:before{content:'\f16f'}.zmdi-gesture:before{content:'\f170'}.zmdi-globe-alt:before{content:'\f171'}.zmdi-globe-lock:before{content:'\f172'}.zmdi-globe:before{content:'\f173'}.zmdi-graduation-cap:before{content:'\f174'}.zmdi-home:before{content:'\f175'}.zmdi-hospital-alt:before{content:'\f176'}.zmdi-hospital:before{content:'\f177'}.zmdi-hotel:before{content:'\f178'}.zmdi-hourglass-alt:before{content:'\f179'}.zmdi-hourglass-outline:before{content:'\f17a'}.zmdi-hourglass:before{content:'\f17b'}.zmdi-http:before{content:'\f17c'}.zmdi-image-alt:before{content:'\f17d'}.zmdi-image-o:before{content:'\f17e'}.zmdi-image:before{content:'\f17f'}.zmdi-inbox:before{content:'\f180'}.zmdi-invert-colors-off:before{content:'\f181'}.zmdi-invert-colors:before{content:'\f182'}.zmdi-key:before{content:'\f183'}.zmdi-label-alt-outline:before{content:'\f184'}.zmdi-label-alt:before{content:'\f185'}.zmdi-label-heart:before{content:'\f186'}.zmdi-label:before{content:'\f187'}.zmdi-labels:before{content:'\f188'}.zmdi-lamp:before{content:'\f189'}.zmdi-landscape:before{content:'\f18a'}.zmdi-layers-off:before{content:'\f18b'}.zmdi-layers:before{content:'\f18c'}.zmdi-library:before{content:'\f18d'}.zmdi-link:before{content:'\f18e'}.zmdi-lock-open:before{content:'\f18f'}.zmdi-lock-outline:before{content:'\f190'}.zmdi-lock:before{content:'\f191'}.zmdi-mail-reply-all:before{content:'\f192'}.zmdi-mail-reply:before{content:'\f193'}.zmdi-mail-send:before{content:'\f194'}.zmdi-mall:before{content:'\f195'}.zmdi-map:before{content:'\f196'}.zmdi-menu:before{content:'\f197'}.zmdi-money-box:before{content:'\f198'}.zmdi-money-off:before{content:'\f199'}.zmdi-money:before{content:'\f19a'}.zmdi-more-vert:before{content:'\f19b'}.zmdi-more:before{content:'\f19c'}.zmdi-movie-alt:before{content:'\f19d'}.zmdi-movie:before{content:'\f19e'}.zmdi-nature-people:before{content:'\f19f'}.zmdi-nature:before{content:'\f1a0'}.zmdi-navigation:before{content:'\f1a1'}.zmdi-open-in-browser:before{content:'\f1a2'}.zmdi-open-in-new:before{content:'\f1a3'}.zmdi-palette:before{content:'\f1a4'}.zmdi-parking:before{content:'\f1a5'}.zmdi-pin-account:before{content:'\f1a6'}.zmdi-pin-assistant:before{content:'\f1a7'}.zmdi-pin-drop:before{content:'\f1a8'}.zmdi-pin-help:before{content:'\f1a9'}.zmdi-pin-off:before{content:'\f1aa'}.zmdi-pin:before{content:'\f1ab'}.zmdi-pizza:before{content:'\f1ac'}.zmdi-plaster:before{content:'\f1ad'}.zmdi-power-setting:before{content:'\f1ae'}.zmdi-power:before{content:'\f1af'}.zmdi-print:before{content:'\f1b0'}.zmdi-puzzle-piece:before{content:'\f1b1'}.zmdi-quote:before{content:'\f1b2'}.zmdi-railway:before{content:'\f1b3'}.zmdi-receipt:before{content:'\f1b4'}.zmdi-refresh-alt:before{content:'\f1b5'}.zmdi-refresh-sync-alert:before{content:'\f1b6'}.zmdi-refresh-sync-off:before{content:'\f1b7'}.zmdi-refresh-sync:before{content:'\f1b8'}.zmdi-refresh:before{content:'\f1b9'}.zmdi-roller:before{content:'\f1ba'}.zmdi-ruler:before{content:'\f1bb'}.zmdi-scissors:before{content:'\f1bc'}.zmdi-screen-rotation-lock:before{content:'\f1bd'}.zmdi-screen-rotation:before{content:'\f1be'}.zmdi-search-for:before{content:'\f1bf'}.zmdi-search-in-file:before{content:'\f1c0'}.zmdi-search-in-page:before{content:'\f1c1'}.zmdi-search-replace:before{content:'\f1c2'}.zmdi-search:before{content:'\f1c3'}.zmdi-seat:before{content:'\f1c4'}.zmdi-settings-square:before{content:'\f1c5'}.zmdi-settings:before{content:'\f1c6'}.zmdi-shield-check:before{content:'\f1c7'}.zmdi-shield-security:before{content:'\f1c8'}.zmdi-shopping-basket:before{content:'\f1c9'}.zmdi-shopping-cart-plus:before{content:'\f1ca'}.zmdi-shopping-cart:before{content:'\f1cb'}.zmdi-sign-in:before{content:'\f1cc'}.zmdi-sort-amount-asc:before{content:'\f1cd'}.zmdi-sort-amount-desc:before{content:'\f1ce'}.zmdi-sort-asc:before{content:'\f1cf'}.zmdi-sort-desc:before{content:'\f1d0'}.zmdi-spellcheck:before{content:'\f1d1'}.zmdi-storage:before{content:'\f1d2'}.zmdi-store-24:before{content:'\f1d3'}.zmdi-store:before{content:'\f1d4'}.zmdi-subway:before{content:'\f1d5'}.zmdi-sun:before{content:'\f1d6'}.zmdi-tab-unselected:before{content:'\f1d7'}.zmdi-tab:before{content:'\f1d8'}.zmdi-tag-close:before{content:'\f1d9'}.zmdi-tag-more:before{content:'\f1da'}.zmdi-tag:before{content:'\f1db'}.zmdi-thumb-down:before{content:'\f1dc'}.zmdi-thumb-up-down:before{content:'\f1dd'}.zmdi-thumb-up:before{content:'\f1de'}.zmdi-ticket-star:before{content:'\f1df'}.zmdi-toll:before{content:'\f1e0'}.zmdi-toys:before{content:'\f1e1'}.zmdi-traffic:before{content:'\f1e2'}.zmdi-translate:before{content:'\f1e3'}.zmdi-triangle-down:before{content:'\f1e4'}.zmdi-triangle-up:before{content:'\f1e5'}.zmdi-truck:before{content:'\f1e6'}.zmdi-turning-sign:before{content:'\f1e7'}.zmdi-wallpaper:before{content:'\f1e8'}.zmdi-washing-machine:before{content:'\f1e9'}.zmdi-window-maximize:before{content:'\f1ea'}.zmdi-window-minimize:before{content:'\f1eb'}.zmdi-window-restore:before{content:'\f1ec'}.zmdi-wrench:before{content:'\f1ed'}.zmdi-zoom-in:before{content:'\f1ee'}.zmdi-zoom-out:before{content:'\f1ef'}.zmdi-alert-circle-o:before{content:'\f1f0'}.zmdi-alert-circle:before{content:'\f1f1'}.zmdi-alert-octagon:before{content:'\f1f2'}.zmdi-alert-polygon:before{content:'\f1f3'}.zmdi-alert-triangle:before{content:'\f1f4'}.zmdi-help-outline:before{content:'\f1f5'}.zmdi-help:before{content:'\f1f6'}.zmdi-info-outline:before{content:'\f1f7'}.zmdi-info:before{content:'\f1f8'}.zmdi-notifications-active:before{content:'\f1f9'}.zmdi-notifications-add:before{content:'\f1fa'}.zmdi-notifications-none:before{content:'\f1fb'}.zmdi-notifications-off:before{content:'\f1fc'}.zmdi-notifications-paused:before{content:'\f1fd'}.zmdi-notifications:before{content:'\f1fe'}.zmdi-account-add:before{content:'\f1ff'}.zmdi-account-box-mail:before{content:'\f200'}.zmdi-account-box-o:before{content:'\f201'}.zmdi-account-box-phone:before{content:'\f202'}.zmdi-account-box:before{content:'\f203'}.zmdi-account-calendar:before{content:'\f204'}.zmdi-account-circle:before{content:'\f205'}.zmdi-account-o:before{content:'\f206'}.zmdi-account:before{content:'\f207'}.zmdi-accounts-add:before{content:'\f208'}.zmdi-accounts-alt:before{content:'\f209'}.zmdi-accounts-list-alt:before{content:'\f20a'}.zmdi-accounts-list:before{content:'\f20b'}.zmdi-accounts-outline:before{content:'\f20c'}.zmdi-accounts:before{content:'\f20d'}.zmdi-face:before{content:'\f20e'}.zmdi-female:before{content:'\f20f'}.zmdi-male-alt:before{content:'\f210'}.zmdi-male-female:before{content:'\f211'}.zmdi-male:before{content:'\f212'}.zmdi-mood-bad:before{content:'\f213'}.zmdi-mood:before{content:'\f214'}.zmdi-run:before{content:'\f215'}.zmdi-walk:before{content:'\f216'}.zmdi-cloud-box:before{content:'\f217'}.zmdi-cloud-circle:before{content:'\f218'}.zmdi-cloud-done:before{content:'\f219'}.zmdi-cloud-download:before{content:'\f21a'}.zmdi-cloud-off:before{content:'\f21b'}.zmdi-cloud-outline-alt:before{content:'\f21c'}.zmdi-cloud-outline:before{content:'\f21d'}.zmdi-cloud-upload:before{content:'\f21e'}.zmdi-cloud:before{content:'\f21f'}.zmdi-download:before{content:'\f220'}.zmdi-file-plus:before{content:'\f221'}.zmdi-file-text:before{content:'\f222'}.zmdi-file:before{content:'\f223'}.zmdi-folder-outline:before{content:'\f224'}.zmdi-folder-person:before{content:'\f225'}.zmdi-folder-star-alt:before{content:'\f226'}.zmdi-folder-star:before{content:'\f227'}.zmdi-folder:before{content:'\f228'}.zmdi-gif:before{content:'\f229'}.zmdi-upload:before{content:'\f22a'}.zmdi-border-all:before{content:'\f22b'}.zmdi-border-bottom:before{content:'\f22c'}.zmdi-border-clear:before{content:'\f22d'}.zmdi-border-color:before{content:'\f22e'}.zmdi-border-horizontal:before{content:'\f22f'}.zmdi-border-inner:before{content:'\f230'}.zmdi-border-left:before{content:'\f231'}.zmdi-border-outer:before{content:'\f232'}.zmdi-border-right:before{content:'\f233'}.zmdi-border-style:before{content:'\f234'}.zmdi-border-top:before{content:'\f235'}.zmdi-border-vertical:before{content:'\f236'}.zmdi-copy:before{content:'\f237'}.zmdi-crop:before{content:'\f238'}.zmdi-format-align-center:before{content:'\f239'}.zmdi-format-align-justify:before{content:'\f23a'}.zmdi-format-align-left:before{content:'\f23b'}.zmdi-format-align-right:before{content:'\f23c'}.zmdi-format-bold:before{content:'\f23d'}.zmdi-format-clear-all:before{content:'\f23e'}.zmdi-format-clear:before{content:'\f23f'}.zmdi-format-color-fill:before{content:'\f240'}.zmdi-format-color-reset:before{content:'\f241'}.zmdi-format-color-text:before{content:'\f242'}.zmdi-format-indent-decrease:before{content:'\f243'}.zmdi-format-indent-increase:before{content:'\f244'}.zmdi-format-italic:before{content:'\f245'}.zmdi-format-line-spacing:before{content:'\f246'}.zmdi-format-list-bulleted:before{content:'\f247'}.zmdi-format-list-numbered:before{content:'\f248'}.zmdi-format-ltr:before{content:'\f249'}.zmdi-format-rtl:before{content:'\f24a'}.zmdi-format-size:before{content:'\f24b'}.zmdi-format-strikethrough-s:before{content:'\f24c'}.zmdi-format-strikethrough:before{content:'\f24d'}.zmdi-format-subject:before{content:'\f24e'}.zmdi-format-underlined:before{content:'\f24f'}.zmdi-format-valign-bottom:before{content:'\f250'}.zmdi-format-valign-center:before{content:'\f251'}.zmdi-format-valign-top:before{content:'\f252'}.zmdi-redo:before{content:'\f253'}.zmdi-select-all:before{content:'\f254'}.zmdi-space-bar:before{content:'\f255'}.zmdi-text-format:before{content:'\f256'}.zmdi-transform:before{content:'\f257'}.zmdi-undo:before{content:'\f258'}.zmdi-wrap-text:before{content:'\f259'}.zmdi-comment-alert:before{content:'\f25a'}.zmdi-comment-alt-text:before{content:'\f25b'}.zmdi-comment-alt:before{content:'\f25c'}.zmdi-comment-edit:before{content:'\f25d'}.zmdi-comment-image:before{content:'\f25e'}.zmdi-comment-list:before{content:'\f25f'}.zmdi-comment-more:before{content:'\f260'}.zmdi-comment-outline:before{content:'\f261'}.zmdi-comment-text-alt:before{content:'\f262'}.zmdi-comment-text:before{content:'\f263'}.zmdi-comment-video:before{content:'\f264'}.zmdi-comment:before{content:'\f265'}.zmdi-comments:before{content:'\f266'}.zmdi-check-all:before{content:'\f267'}.zmdi-check-circle-u:before{content:'\f268'}.zmdi-check-circle:before{content:'\f269'}.zmdi-check-square:before{content:'\f26a'}.zmdi-check:before{content:'\f26b'}.zmdi-circle-o:before{content:'\f26c'}.zmdi-circle:before{content:'\f26d'}.zmdi-dot-circle-alt:before{content:'\f26e'}.zmdi-dot-circle:before{content:'\f26f'}.zmdi-minus-circle-outline:before{content:'\f270'}.zmdi-minus-circle:before{content:'\f271'}.zmdi-minus-square:before{content:'\f272'}.zmdi-minus:before{content:'\f273'}.zmdi-plus-circle-o-duplicate:before{content:'\f274'}.zmdi-plus-circle-o:before{content:'\f275'}.zmdi-plus-circle:before{content:'\f276'}.zmdi-plus-square:before{content:'\f277'}.zmdi-plus:before{content:'\f278'}.zmdi-square-o:before{content:'\f279'}.zmdi-star-circle:before{content:'\f27a'}.zmdi-star-half:before{content:'\f27b'}.zmdi-star-outline:before{content:'\f27c'}.zmdi-star:before{content:'\f27d'}.zmdi-bluetooth-connected:before{content:'\f27e'}.zmdi-bluetooth-off:before{content:'\f27f'}.zmdi-bluetooth-search:before{content:'\f280'}.zmdi-bluetooth-setting:before{content:'\f281'}.zmdi-bluetooth:before{content:'\f282'}.zmdi-camera-add:before{content:'\f283'}.zmdi-camera-alt:before{content:'\f284'}.zmdi-camera-bw:before{content:'\f285'}.zmdi-camera-front:before{content:'\f286'}.zmdi-camera-mic:before{content:'\f287'}.zmdi-camera-party-mode:before{content:'\f288'}.zmdi-camera-rear:before{content:'\f289'}.zmdi-camera-roll:before{content:'\f28a'}.zmdi-camera-switch:before{content:'\f28b'}.zmdi-camera:before{content:'\f28c'}.zmdi-card-alert:before{content:'\f28d'}.zmdi-card-off:before{content:'\f28e'}.zmdi-card-sd:before{content:'\f28f'}.zmdi-card-sim:before{content:'\f290'}.zmdi-desktop-mac:before{content:'\f291'}.zmdi-desktop-windows:before{content:'\f292'}.zmdi-device-hub:before{content:'\f293'}.zmdi-devices-off:before{content:'\f294'}.zmdi-devices:before{content:'\f295'}.zmdi-dock:before{content:'\f296'}.zmdi-floppy:before{content:'\f297'}.zmdi-gamepad:before{content:'\f298'}.zmdi-gps-dot:before{content:'\f299'}.zmdi-gps-off:before{content:'\f29a'}.zmdi-gps:before{content:'\f29b'}.zmdi-headset-mic:before{content:'\f29c'}.zmdi-headset:before{content:'\f29d'}.zmdi-input-antenna:before{content:'\f29e'}.zmdi-input-composite:before{content:'\f29f'}.zmdi-input-hdmi:before{content:'\f2a0'}.zmdi-input-power:before{content:'\f2a1'}.zmdi-input-svideo:before{content:'\f2a2'}.zmdi-keyboard-hide:before{content:'\f2a3'}.zmdi-keyboard:before{content:'\f2a4'}.zmdi-laptop-chromebook:before{content:'\f2a5'}.zmdi-laptop-mac:before{content:'\f2a6'}.zmdi-laptop:before{content:'\f2a7'}.zmdi-mic-off:before{content:'\f2a8'}.zmdi-mic-outline:before{content:'\f2a9'}.zmdi-mic-setting:before{content:'\f2aa'}.zmdi-mic:before{content:'\f2ab'}.zmdi-mouse:before{content:'\f2ac'}.zmdi-network-alert:before{content:'\f2ad'}.zmdi-network-locked:before{content:'\f2ae'}.zmdi-network-off:before{content:'\f2af'}.zmdi-network-outline:before{content:'\f2b0'}.zmdi-network-setting:before{content:'\f2b1'}.zmdi-network:before{content:'\f2b2'}.zmdi-phone-bluetooth:before{content:'\f2b3'}.zmdi-phone-end:before{content:'\f2b4'}.zmdi-phone-forwarded:before{content:'\f2b5'}.zmdi-phone-in-talk:before{content:'\f2b6'}.zmdi-phone-locked:before{content:'\f2b7'}.zmdi-phone-missed:before{content:'\f2b8'}.zmdi-phone-msg:before{content:'\f2b9'}.zmdi-phone-paused:before{content:'\f2ba'}.zmdi-phone-ring:before{content:'\f2bb'}.zmdi-phone-setting:before{content:'\f2bc'}.zmdi-phone-sip:before{content:'\f2bd'}.zmdi-phone:before{content:'\f2be'}.zmdi-portable-wifi-changes:before{content:'\f2bf'}.zmdi-portable-wifi-off:before{content:'\f2c0'}.zmdi-portable-wifi:before{content:'\f2c1'}.zmdi-radio:before{content:'\f2c2'}.zmdi-reader:before{content:'\f2c3'}.zmdi-remote-control-alt:before{content:'\f2c4'}.zmdi-remote-control:before{content:'\f2c5'}.zmdi-router:before{content:'\f2c6'}.zmdi-scanner:before{content:'\f2c7'}.zmdi-smartphone-android:before{content:'\f2c8'}.zmdi-smartphone-download:before{content:'\f2c9'}.zmdi-smartphone-erase:before{content:'\f2ca'}.zmdi-smartphone-info:before{content:'\f2cb'}.zmdi-smartphone-iphone:before{content:'\f2cc'}.zmdi-smartphone-landscape-lock:before{content:'\f2cd'}.zmdi-smartphone-landscape:before{content:'\f2ce'}.zmdi-smartphone-lock:before{content:'\f2cf'}.zmdi-smartphone-portrait-lock:before{content:'\f2d0'}.zmdi-smartphone-ring:before{content:'\f2d1'}.zmdi-smartphone-setting:before{content:'\f2d2'}.zmdi-smartphone-setup:before{content:'\f2d3'}.zmdi-smartphone:before{content:'\f2d4'}.zmdi-speaker:before{content:'\f2d5'}.zmdi-tablet-android:before{content:'\f2d6'}.zmdi-tablet-mac:before{content:'\f2d7'}.zmdi-tablet:before{content:'\f2d8'}.zmdi-tv-alt-play:before{content:'\f2d9'}.zmdi-tv-list:before{content:'\f2da'}.zmdi-tv-play:before{content:'\f2db'}.zmdi-tv:before{content:'\f2dc'}.zmdi-usb:before{content:'\f2dd'}.zmdi-videocam-off:before{content:'\f2de'}.zmdi-videocam-switch:before{content:'\f2df'}.zmdi-videocam:before{content:'\f2e0'}.zmdi-watch:before{content:'\f2e1'}.zmdi-wifi-alt-2:before{content:'\f2e2'}.zmdi-wifi-alt:before{content:'\f2e3'}.zmdi-wifi-info:before{content:'\f2e4'}.zmdi-wifi-lock:before{content:'\f2e5'}.zmdi-wifi-off:before{content:'\f2e6'}.zmdi-wifi-outline:before{content:'\f2e7'}.zmdi-wifi:before{content:'\f2e8'}.zmdi-arrow-left-bottom:before{content:'\f2e9'}.zmdi-arrow-left:before{content:'\f2ea'}.zmdi-arrow-merge:before{content:'\f2eb'}.zmdi-arrow-missed:before{content:'\f2ec'}.zmdi-arrow-right-top:before{content:'\f2ed'}.zmdi-arrow-right:before{content:'\f2ee'}.zmdi-arrow-split:before{content:'\f2ef'}.zmdi-arrows:before{content:'\f2f0'}.zmdi-caret-down-circle:before{content:'\f2f1'}.zmdi-caret-down:before{content:'\f2f2'}.zmdi-caret-left-circle:before{content:'\f2f3'}.zmdi-caret-left:before{content:'\f2f4'}.zmdi-caret-right-circle:before{content:'\f2f5'}.zmdi-caret-right:before{content:'\f2f6'}.zmdi-caret-up-circle:before{content:'\f2f7'}.zmdi-caret-up:before{content:'\f2f8'}.zmdi-chevron-down:before{content:'\f2f9'}.zmdi-chevron-left:before{content:'\f2fa'}.zmdi-chevron-right:before{content:'\f2fb'}.zmdi-chevron-up:before{content:'\f2fc'}.zmdi-forward:before{content:'\f2fd'}.zmdi-long-arrow-down:before{content:'\f2fe'}.zmdi-long-arrow-left:before{content:'\f2ff'}.zmdi-long-arrow-return:before{content:'\f300'}.zmdi-long-arrow-right:before{content:'\f301'}.zmdi-long-arrow-tab:before{content:'\f302'}.zmdi-long-arrow-up:before{content:'\f303'}.zmdi-rotate-ccw:before{content:'\f304'}.zmdi-rotate-cw:before{content:'\f305'}.zmdi-rotate-left:before{content:'\f306'}.zmdi-rotate-right:before{content:'\f307'}.zmdi-square-down:before{content:'\f308'}.zmdi-square-right:before{content:'\f309'}.zmdi-swap-alt:before{content:'\f30a'}.zmdi-swap-vertical-circle:before{content:'\f30b'}.zmdi-swap-vertical:before{content:'\f30c'}.zmdi-swap:before{content:'\f30d'}.zmdi-trending-down:before{content:'\f30e'}.zmdi-trending-flat:before{content:'\f30f'}.zmdi-trending-up:before{content:'\f310'}.zmdi-unfold-less:before{content:'\f311'}.zmdi-unfold-more:before{content:'\f312'}.zmdi-apps:before{content:'\f313'}.zmdi-grid-off:before{content:'\f314'}.zmdi-grid:before{content:'\f315'}.zmdi-view-agenda:before{content:'\f316'}.zmdi-view-array:before{content:'\f317'}.zmdi-view-carousel:before{content:'\f318'}.zmdi-view-column:before{content:'\f319'}.zmdi-view-comfy:before{content:'\f31a'}.zmdi-view-compact:before{content:'\f31b'}.zmdi-view-dashboard:before{content:'\f31c'}.zmdi-view-day:before{content:'\f31d'}.zmdi-view-headline:before{content:'\f31e'}.zmdi-view-list-alt:before{content:'\f31f'}.zmdi-view-list:before{content:'\f320'}.zmdi-view-module:before{content:'\f321'}.zmdi-view-quilt:before{content:'\f322'}.zmdi-view-stream:before{content:'\f323'}.zmdi-view-subtitles:before{content:'\f324'}.zmdi-view-toc:before{content:'\f325'}.zmdi-view-web:before{content:'\f326'}.zmdi-view-week:before{content:'\f327'}.zmdi-widgets:before{content:'\f328'}.zmdi-alarm-check:before{content:'\f329'}.zmdi-alarm-off:before{content:'\f32a'}.zmdi-alarm-plus:before{content:'\f32b'}.zmdi-alarm-snooze:before{content:'\f32c'}.zmdi-alarm:before{content:'\f32d'}.zmdi-calendar-alt:before{content:'\f32e'}.zmdi-calendar-check:before{content:'\f32f'}.zmdi-calendar-close:before{content:'\f330'}.zmdi-calendar-note:before{content:'\f331'}.zmdi-calendar:before{content:'\f332'}.zmdi-time-countdown:before{content:'\f333'}.zmdi-time-interval:before{content:'\f334'}.zmdi-time-restore-setting:before{content:'\f335'}.zmdi-time-restore:before{content:'\f336'}.zmdi-time:before{content:'\f337'}.zmdi-timer-off:before{content:'\f338'}.zmdi-timer:before{content:'\f339'}.zmdi-android-alt:before{content:'\f33a'}.zmdi-android:before{content:'\f33b'}.zmdi-apple:before{content:'\f33c'}.zmdi-behance:before{content:'\f33d'}.zmdi-codepen:before{content:'\f33e'}.zmdi-dribbble:before{content:'\f33f'}.zmdi-dropbox:before{content:'\f340'}.zmdi-evernote:before{content:'\f341'}.zmdi-facebook-box:before{content:'\f342'}.zmdi-facebook:before{content:'\f343'}.zmdi-github-box:before{content:'\f344'}.zmdi-github:before{content:'\f345'}.zmdi-google-drive:before{content:'\f346'}.zmdi-google-earth:before{content:'\f347'}.zmdi-google-glass:before{content:'\f348'}.zmdi-google-maps:before{content:'\f349'}.zmdi-google-pages:before{content:'\f34a'}.zmdi-google-play:before{content:'\f34b'}.zmdi-google-plus-box:before{content:'\f34c'}.zmdi-google-plus:before{content:'\f34d'}.zmdi-google:before{content:'\f34e'}.zmdi-instagram:before{content:'\f34f'}.zmdi-language-css3:before{content:'\f350'}.zmdi-language-html5:before{content:'\f351'}.zmdi-language-javascript:before{content:'\f352'}.zmdi-language-python-alt:before{content:'\f353'}.zmdi-language-python:before{content:'\f354'}.zmdi-lastfm:before{content:'\f355'}.zmdi-linkedin-box:before{content:'\f356'}.zmdi-paypal:before{content:'\f357'}.zmdi-pinterest-box:before{content:'\f358'}.zmdi-pocket:before{content:'\f359'}.zmdi-polymer:before{content:'\f35a'}.zmdi-share:before{content:'\f35b'}.zmdi-stackoverflow:before{content:'\f35c'}.zmdi-steam-square:before{content:'\f35d'}.zmdi-steam:before{content:'\f35e'}.zmdi-twitter-box:before{content:'\f35f'}.zmdi-twitter:before{content:'\f360'}.zmdi-vk:before{content:'\f361'}.zmdi-wikipedia:before{content:'\f362'}.zmdi-windows:before{content:'\f363'}.zmdi-aspect-ratio-alt:before{content:'\f364'}.zmdi-aspect-ratio:before{content:'\f365'}.zmdi-blur-circular:before{content:'\f366'}.zmdi-blur-linear:before{content:'\f367'}.zmdi-blur-off:before{content:'\f368'}.zmdi-blur:before{content:'\f369'}.zmdi-brightness-2:before{content:'\f36a'}.zmdi-brightness-3:before{content:'\f36b'}.zmdi-brightness-4:before{content:'\f36c'}.zmdi-brightness-5:before{content:'\f36d'}.zmdi-brightness-6:before{content:'\f36e'}.zmdi-brightness-7:before{content:'\f36f'}.zmdi-brightness-auto:before{content:'\f370'}.zmdi-brightness-setting:before{content:'\f371'}.zmdi-broken-image:before{content:'\f372'}.zmdi-center-focus-strong:before{content:'\f373'}.zmdi-center-focus-weak:before{content:'\f374'}.zmdi-compare:before{content:'\f375'}.zmdi-crop-16-9:before{content:'\f376'}.zmdi-crop-3-2:before{content:'\f377'}.zmdi-crop-5-4:before{content:'\f378'}.zmdi-crop-7-5:before{content:'\f379'}.zmdi-crop-din:before{content:'\f37a'}.zmdi-crop-free:before{content:'\f37b'}.zmdi-crop-landscape:before{content:'\f37c'}.zmdi-crop-portrait:before{content:'\f37d'}.zmdi-crop-square:before{content:'\f37e'}.zmdi-exposure-alt:before{content:'\f37f'}.zmdi-exposure:before{content:'\f380'}.zmdi-filter-b-and-w:before{content:'\f381'}.zmdi-filter-center-focus:before{content:'\f382'}.zmdi-filter-frames:before{content:'\f383'}.zmdi-filter-tilt-shift:before{content:'\f384'}.zmdi-gradient:before{content:'\f385'}.zmdi-grain:before{content:'\f386'}.zmdi-graphic-eq:before{content:'\f387'}.zmdi-hdr-off:before{content:'\f388'}.zmdi-hdr-strong:before{content:'\f389'}.zmdi-hdr-weak:before{content:'\f38a'}.zmdi-hdr:before{content:'\f38b'}.zmdi-iridescent:before{content:'\f38c'}.zmdi-leak-off:before{content:'\f38d'}.zmdi-leak:before{content:'\f38e'}.zmdi-looks:before{content:'\f38f'}.zmdi-loupe:before{content:'\f390'}.zmdi-panorama-horizontal:before{content:'\f391'}.zmdi-panorama-vertical:before{content:'\f392'}.zmdi-panorama-wide-angle:before{content:'\f393'}.zmdi-photo-size-select-large:before{content:'\f394'}.zmdi-photo-size-select-small:before{content:'\f395'}.zmdi-picture-in-picture:before{content:'\f396'}.zmdi-slideshow:before{content:'\f397'}.zmdi-texture:before{content:'\f398'}.zmdi-tonality:before{content:'\f399'}.zmdi-vignette:before{content:'\f39a'}.zmdi-wb-auto:before{content:'\f39b'}.zmdi-eject-alt:before{content:'\f39c'}.zmdi-eject:before{content:'\f39d'}.zmdi-equalizer:before{content:'\f39e'}.zmdi-fast-forward:before{content:'\f39f'}.zmdi-fast-rewind:before{content:'\f3a0'}.zmdi-forward-10:before{content:'\f3a1'}.zmdi-forward-30:before{content:'\f3a2'}.zmdi-forward-5:before{content:'\f3a3'}.zmdi-hearing:before{content:'\f3a4'}.zmdi-pause-circle-outline:before{content:'\f3a5'}.zmdi-pause-circle:before{content:'\f3a6'}.zmdi-pause:before{content:'\f3a7'}.zmdi-play-circle-outline:before{content:'\f3a8'}.zmdi-play-circle:before{content:'\f3a9'}.zmdi-play:before{content:'\f3aa'}.zmdi-playlist-audio:before{content:'\f3ab'}.zmdi-playlist-plus:before{content:'\f3ac'}.zmdi-repeat-one:before{content:'\f3ad'}.zmdi-repeat:before{content:'\f3ae'}.zmdi-replay-10:before{content:'\f3af'}.zmdi-replay-30:before{content:'\f3b0'}.zmdi-replay-5:before{content:'\f3b1'}.zmdi-replay:before{content:'\f3b2'}.zmdi-shuffle:before{content:'\f3b3'}.zmdi-skip-next:before{content:'\f3b4'}.zmdi-skip-previous:before{content:'\f3b5'}.zmdi-stop:before{content:'\f3b6'}.zmdi-surround-sound:before{content:'\f3b7'}.zmdi-tune:before{content:'\f3b8'}.zmdi-volume-down:before{content:'\f3b9'}.zmdi-volume-mute:before{content:'\f3ba'}.zmdi-volume-off:before{content:'\f3bb'}.zmdi-volume-up:before{content:'\f3bc'}.zmdi-n-1-square:before{content:'\f3bd'}.zmdi-n-2-square:before{content:'\f3be'}.zmdi-n-3-square:before{content:'\f3bf'}.zmdi-n-4-square:before{content:'\f3c0'}.zmdi-n-5-square:before{content:'\f3c1'}.zmdi-n-6-square:before{content:'\f3c2'}.zmdi-neg-1:before{content:'\f3c3'}.zmdi-neg-2:before{content:'\f3c4'}.zmdi-plus-1:before{content:'\f3c5'}.zmdi-plus-2:before{content:'\f3c6'}.zmdi-sec-10:before{content:'\f3c7'}.zmdi-sec-3:before{content:'\f3c8'}.zmdi-zero:before{content:'\f3c9'}.zmdi-airline-seat-flat-angled:before{content:'\f3ca'}.zmdi-airline-seat-flat:before{content:'\f3cb'}.zmdi-airline-seat-individual-suite:before{content:'\f3cc'}.zmdi-airline-seat-legroom-extra:before{content:'\f3cd'}.zmdi-airline-seat-legroom-normal:before{content:'\f3ce'}.zmdi-airline-seat-legroom-reduced:before{content:'\f3cf'}.zmdi-airline-seat-recline-extra:before{content:'\f3d0'}.zmdi-airline-seat-recline-normal:before{content:'\f3d1'}.zmdi-airplay:before{content:'\f3d2'}.zmdi-closed-caption:before{content:'\f3d3'}.zmdi-confirmation-number:before{content:'\f3d4'}.zmdi-developer-board:before{content:'\f3d5'}.zmdi-disc-full:before{content:'\f3d6'}.zmdi-explicit:before{content:'\f3d7'}.zmdi-flight-land:before{content:'\f3d8'}.zmdi-flight-takeoff:before{content:'\f3d9'}.zmdi-flip-to-back:before{content:'\f3da'}.zmdi-flip-to-front:before{content:'\f3db'}.zmdi-group-work:before{content:'\f3dc'}.zmdi-hd:before{content:'\f3dd'}.zmdi-hq:before{content:'\f3de'}.zmdi-markunread-mailbox:before{content:'\f3df'}.zmdi-memory:before{content:'\f3e0'}.zmdi-nfc:before{content:'\f3e1'}.zmdi-play-for-work:before{content:'\f3e2'}.zmdi-power-input:before{content:'\f3e3'}.zmdi-present-to-all:before{content:'\f3e4'}.zmdi-satellite:before{content:'\f3e5'}.zmdi-tap-and-play:before{content:'\f3e6'}.zmdi-vibration:before{content:'\f3e7'}.zmdi-voicemail:before{content:'\f3e8'}.zmdi-group:before{content:'\f3e9'}.zmdi-rss:before{content:'\f3ea'}.zmdi-shape:before{content:'\f3eb'}.zmdi-spinner:before{content:'\f3ec'}.zmdi-ungroup:before{content:'\f3ed'}.zmdi-500px:before{content:'\f3ee'}.zmdi-8tracks:before{content:'\f3ef'}.zmdi-amazon:before{content:'\f3f0'}.zmdi-blogger:before{content:'\f3f1'}.zmdi-delicious:before{content:'\f3f2'}.zmdi-disqus:before{content:'\f3f3'}.zmdi-flattr:before{content:'\f3f4'}.zmdi-flickr:before{content:'\f3f5'}.zmdi-github-alt:before{content:'\f3f6'}.zmdi-google-old:before{content:'\f3f7'}.zmdi-linkedin:before{content:'\f3f8'}.zmdi-odnoklassniki:before{content:'\f3f9'}.zmdi-outlook:before{content:'\f3fa'}.zmdi-paypal-alt:before{content:'\f3fb'}.zmdi-pinterest:before{content:'\f3fc'}.zmdi-playstation:before{content:'\f3fd'}.zmdi-reddit:before{content:'\f3fe'}.zmdi-skype:before{content:'\f3ff'}.zmdi-slideshare:before{content:'\f400'}.zmdi-soundcloud:before{content:'\f401'}.zmdi-tumblr:before{content:'\f402'}.zmdi-twitch:before{content:'\f403'}.zmdi-vimeo:before{content:'\f404'}.zmdi-whatsapp:before{content:'\f405'}.zmdi-xbox:before{content:'\f406'}.zmdi-yahoo:before{content:'\f407'}.zmdi-youtube-play:before{content:'\f408'}.zmdi-youtube:before{content:'\f409'}.zmdi-import-export:before{content:'\f30c'}.zmdi-swap-vertical-:before{content:'\f30c'}.zmdi-airplanemode-inactive:before{content:'\f102'}.zmdi-airplanemode-active:before{content:'\f103'}.zmdi-rate-review:before{content:'\f103'}.zmdi-comment-sign:before{content:'\f25a'}.zmdi-network-warning:before{content:'\f2ad'}.zmdi-shopping-cart-add:before{content:'\f1ca'}.zmdi-file-add:before{content:'\f221'}.zmdi-network-wifi-scan:before{content:'\f2e4'}.zmdi-collection-add:before{content:'\f14e'}.zmdi-format-playlist-add:before{content:'\f3ac'}.zmdi-format-queue-music:before{content:'\f3ab'}.zmdi-plus-box:before{content:'\f277'}.zmdi-tag-backspace:before{content:'\f1d9'}.zmdi-alarm-add:before{content:'\f32b'}.zmdi-battery-charging:before{content:'\f114'}.zmdi-daydream-setting:before{content:'\f217'}.zmdi-more-horiz:before{content:'\f19c'}.zmdi-book-photo:before{content:'\f11b'}.zmdi-incandescent:before{content:'\f189'}.zmdi-wb-iridescent:before{content:'\f38c'}.zmdi-calendar-remove:before{content:'\f330'}.zmdi-refresh-sync-disabled:before{content:'\f1b7'}.zmdi-refresh-sync-problem:before{content:'\f1b6'}.zmdi-crop-original:before{content:'\f17e'}.zmdi-power-off:before{content:'\f1af'}.zmdi-power-off-setting:before{content:'\f1ae'}.zmdi-leak-remove:before{content:'\f38d'}.zmdi-star-border:before{content:'\f27c'}.zmdi-brightness-low:before{content:'\f36d'}.zmdi-brightness-medium:before{content:'\f36e'}.zmdi-brightness-high:before{content:'\f36f'}.zmdi-smartphone-portrait:before{content:'\f2d4'}.zmdi-live-tv:before{content:'\f2d9'}.zmdi-format-textdirection-l-to-r:before{content:'\f249'}.zmdi-format-textdirection-r-to-l:before{content:'\f24a'}.zmdi-arrow-back:before{content:'\f2ea'}.zmdi-arrow-forward:before{content:'\f2ee'}.zmdi-arrow-in:before{content:'\f2e9'}.zmdi-arrow-out:before{content:'\f2ed'}.zmdi-rotate-90-degrees-ccw:before{content:'\f304'}.zmdi-adb:before{content:'\f33a'}.zmdi-network-wifi:before{content:'\f2e8'}.zmdi-network-wifi-alt:before{content:'\f2e3'}.zmdi-network-wifi-lock:before{content:'\f2e5'}.zmdi-network-wifi-off:before{content:'\f2e6'}.zmdi-network-wifi-outline:before{content:'\f2e7'}.zmdi-network-wifi-info:before{content:'\f2e4'}.zmdi-layers-clear:before{content:'\f18b'}.zmdi-colorize:before{content:'\f15d'}.zmdi-format-paint:before{content:'\f1ba'}.zmdi-format-quote:before{content:'\f1b2'}.zmdi-camera-monochrome-photos:before{content:'\f285'}.zmdi-sort-by-alpha:before{content:'\f1cf'}.zmdi-folder-shared:before{content:'\f225'}.zmdi-folder-special:before{content:'\f226'}.zmdi-comment-dots:before{content:'\f260'}.zmdi-reorder:before{content:'\f31e'}.zmdi-dehaze:before{content:'\f197'}.zmdi-sort:before{content:'\f1ce'}.zmdi-pages:before{content:'\f34a'}.zmdi-stack-overflow:before{content:'\f35c'}.zmdi-calendar-account:before{content:'\f204'}.zmdi-paste:before{content:'\f109'}.zmdi-cut:before{content:'\f1bc'}.zmdi-save:before{content:'\f297'}.zmdi-smartphone-code:before{content:'\f139'}.zmdi-directions-bike:before{content:'\f117'}.zmdi-directions-boat:before{content:'\f11a'}.zmdi-directions-bus:before{content:'\f121'}.zmdi-directions-car:before{content:'\f125'}.zmdi-directions-railway:before{content:'\f1b3'}.zmdi-directions-run:before{content:'\f215'}.zmdi-directions-subway:before{content:'\f1d5'}.zmdi-directions-walk:before{content:'\f216'}.zmdi-local-hotel:before{content:'\f178'}.zmdi-local-activity:before{content:'\f1df'}.zmdi-local-play:before{content:'\f1df'}.zmdi-local-airport:before{content:'\f103'}.zmdi-local-atm:before{content:'\f198'}.zmdi-local-bar:before{content:'\f137'}.zmdi-local-cafe:before{content:'\f13b'}.zmdi-local-car-wash:before{content:'\f124'}.zmdi-local-convenience-store:before{content:'\f1d3'}.zmdi-local-dining:before{content:'\f153'}.zmdi-local-drink:before{content:'\f157'}.zmdi-local-florist:before{content:'\f168'}.zmdi-local-gas-station:before{content:'\f16f'}.zmdi-local-grocery-store:before{content:'\f1cb'}.zmdi-local-hospital:before{content:'\f177'}.zmdi-local-laundry-service:before{content:'\f1e9'}.zmdi-local-library:before{content:'\f18d'}.zmdi-local-mall:before{content:'\f195'}.zmdi-local-movies:before{content:'\f19d'}.zmdi-local-offer:before{content:'\f187'}.zmdi-local-parking:before{content:'\f1a5'}.zmdi-local-parking:before{content:'\f1a5'}.zmdi-local-pharmacy:before{content:'\f176'}.zmdi-local-phone:before{content:'\f2be'}.zmdi-local-pizza:before{content:'\f1ac'}.zmdi-local-post-office:before{content:'\f15a'}.zmdi-local-printshop:before{content:'\f1b0'}.zmdi-local-see:before{content:'\f28c'}.zmdi-local-shipping:before{content:'\f1e6'}.zmdi-local-store:before{content:'\f1d4'}.zmdi-local-taxi:before{content:'\f123'}.zmdi-local-wc:before{content:'\f211'}.zmdi-my-location:before{content:'\f299'}.zmdi-directions:before{content:'\f1e7'}[m
\ No newline at end of file[m
[32m+[m[32m@font-face {[m
[32m+[m[32m    font-family: Material-Design-Iconic-Font;[m
[32m+[m[32m    src: url(../fonts/Material-Design-Iconic-Font.woff2?v=2.2.0) format('woff2'), url(../fonts/Material-Design-Iconic-Font.woff?v=2.2.0) format('woff'), url(../fonts/Material-Design-Iconic-Font.ttf?v=2.2.0) format('truetype')[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi {[m
[32m+[m[32m    display: inline-block;[m
[32m+[m[32m    font: normal normal normal 14px/1 'Material-Design-Iconic-Font';[m
[32m+[m[32m    font-size: inherit;[m
[32m+[m[32m    text-rendering: auto;[m
[32m+[m[32m    -webkit-font-smoothing: antialiased;[m
[32m+[m[32m    -moz-osx-font-smoothing: grayscale[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-lg {[m
[32m+[m[32m    font-size: 1.33333333em;[m
[32m+[m[32m    line-height: .75em;[m
[32m+[m[32m    vertical-align: -15%[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-2x {[m
[32m+[m[32m    font-size: 2em[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-3x {[m
[32m+[m[32m    font-size: 3em[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-4x {[m
[32m+[m[32m    font-size: 4em[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-5x {[m
[32m+[m[32m    font-size: 5em[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-fw {[m
[32m+[m[32m    width: 1.28571429em;[m
[32m+[m[32m    text-align: center[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-ul {[m
[32m+[m[32m    padding-left: 0;[m
[32m+[m[32m    margin-left: 2.14285714em;[m
[32m+[m[32m    list-style-type: none[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-ul>li {[m
[32m+[m[32m    position: relative[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-li {[m
[32m+[m[32m    position: absolute;[m
[32m+[m[32m    left: -2.14285714em;[m
[32m+[m[32m    width: 2.14285714em;[m
[32m+[m[32m    top: .14285714em;[m
[32m+[m[32m    text-align: center[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-li.zmdi-hc-lg {[m
[32m+[m[32m    left: -1.85714286em[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-border {[m
[32m+[m[32m    padding: .1em .25em;[m
[32m+[m[32m    border: solid .1em #9e9e9e;[m
[32m+[m[32m    border-radius: 2px[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-border-circle {[m
[32m+[m[32m    padding: .1em .25em;[m
[32m+[m[32m    border: solid .1em #9e9e9e;[m
[32m+[m[32m    border-radius: 50%[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi.pull-left {[m
[32m+[m[32m    float: left;[m
[32m+[m[32m    margin-right: .15em[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi.pull-right {[m
[32m+[m[32m    float: right;[m
[32m+[m[32m    margin-left: .15em[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-spin {[m
[32m+[m[32m    -webkit-animation: zmdi-spin 1.5s infinite linear;[m
[32m+[m[32m    animation: zmdi-spin 1.5s infinite linear[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-spin-reverse {[m
[32m+[m[32m    -webkit-animation: zmdi-spin-reverse 1.5s infinite linear;[m
[32m+[m[32m    animation: zmdi-spin-reverse 1.5s infinite linear[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m@-webkit-keyframes zmdi-spin {[m
[32m+[m[32m    0% {[m
[32m+[m[32m        -webkit-transform: rotate(0deg);[m
[32m+[m[32m        transform: rotate(0deg)[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    100% {[m
[32m+[m[32m        -webkit-transform: rotate(359deg);[m
[32m+[m[32m        transform: rotate(359deg)[m
[32m+[m[32m    }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m@keyframes zmdi-spin {[m
[32m+[m[32m    0% {[m
[32m+[m[32m        -webkit-transform: rotate(0deg);[m
[32m+[m[32m        transform: rotate(0deg)[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    100% {[m
[32m+[m[32m        -webkit-transform: rotate(359deg);[m
[32m+[m[32m        transform: rotate(359deg)[m
[32m+[m[32m    }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m@-webkit-keyframes zmdi-spin-reverse {[m
[32m+[m[32m    0% {[m
[32m+[m[32m        -webkit-transform: rotate(0deg);[m
[32m+[m[32m        transform: rotate(0deg)[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    100% {[m
[32m+[m[32m        -webkit-transform: rotate(-359deg);[m
[32m+[m[32m        transform: rotate(-359deg)[m
[32m+[m[32m    }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m@keyframes zmdi-spin-reverse {[m
[32m+[m[32m    0% {[m
[32m+[m[32m        -webkit-transform: rotate(0deg);[m
[32m+[m[32m        transform: rotate(0deg)[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    100% {[m
[32m+[m[32m        -webkit-transform: rotate(-359deg);[m
[32m+[m[32m        transform: rotate(-359deg)[m
[32m+[m[32m    }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-rotate-90 {[m
[32m+[m[32m    -webkit-transform: rotate(90deg);[m
[32m+[m[32m    -ms-transform: rotate(90deg);[m
[32m+[m[32m    transform: rotate(90deg)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-rotate-180 {[m
[32m+[m[32m    -webkit-transform: rotate(180deg);[m
[32m+[m[32m    -ms-transform: rotate(180deg);[m
[32m+[m[32m    transform: rotate(180deg)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-rotate-270 {[m
[32m+[m[32m    -webkit-transform: rotate(270deg);[m
[32m+[m[32m    -ms-transform: rotate(270deg);[m
[32m+[m[32m    transform: rotate(270deg)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-flip-horizontal {[m
[32m+[m[32m    -webkit-transform: scale(-1, 1);[m
[32m+[m[32m    -ms-transform: scale(-1, 1);[m
[32m+[m[32m    transform: scale(-1, 1)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-flip-vertical {[m
[32m+[m[32m    -webkit-transform: scale(1, -1);[m
[32m+[m[32m    -ms-transform: scale(1, -1);[m
[32m+[m[32m    transform: scale(1, -1)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-stack {[m
[32m+[m[32m    position: relative;[m
[32m+[m[32m    display: inline-block;[m
[32m+[m[32m    width: 2em;[m
[32m+[m[32m    height: 2em;[m
[32m+[m[32m    line-height: 2em;[m
[32m+[m[32m    vertical-align: middle[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-stack-1x, .zmdi-hc-stack-2x {[m
[32m+[m[32m    position: absolute;[m
[32m+[m[32m    left: 0;[m
[32m+[m[32m    width: 100%;[m
[32m+[m[32m    text-align: center[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-stack-1x {[m
[32m+[m[32m    line-height: inherit[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-stack-2x {[m
[32m+[m[32m    font-size: 2em[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hc-inverse {[m
[32m+[m[32m    color: #fff[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-3d-rotation:before {[m
[32m+[m[32m    content: '\f101'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airplane-off:before {[m
[32m+[m[32m    content: '\f102'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airplane:before {[m
[32m+[m[32m    content: '\f103'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-album:before {[m
[32m+[m[32m    content: '\f104'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-archive:before {[m
[32m+[m[32m    content: '\f105'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment-account:before {[m
[32m+[m[32m    content: '\f106'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment-alert:before {[m
[32m+[m[32m    content: '\f107'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment-check:before {[m
[32m+[m[32m    content: '\f108'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment-o:before {[m
[32m+[m[32m    content: '\f109'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment-return:before {[m
[32m+[m[32m    content: '\f10a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment-returned:before {[m
[32m+[m[32m    content: '\f10b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment:before {[m
[32m+[m[32m    content: '\f10c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-attachment-alt:before {[m
[32m+[m[32m    content: '\f10d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-attachment:before {[m
[32m+[m[32m    content: '\f10e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-audio:before {[m
[32m+[m[32m    content: '\f10f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-badge-check:before {[m
[32m+[m[32m    content: '\f110'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-balance-wallet:before {[m
[32m+[m[32m    content: '\f111'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-balance:before {[m
[32m+[m[32m    content: '\f112'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-battery-alert:before {[m
[32m+[m[32m    content: '\f113'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-battery-flash:before {[m
[32m+[m[32m    content: '\f114'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-battery-unknown:before {[m
[32m+[m[32m    content: '\f115'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-battery:before {[m
[32m+[m[32m    content: '\f116'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bike:before {[m
[32m+[m[32m    content: '\f117'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-block-alt:before {[m
[32m+[m[32m    content: '\f118'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-block:before {[m
[32m+[m[32m    content: '\f119'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-boat:before {[m
[32m+[m[32m    content: '\f11a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-book-image:before {[m
[32m+[m[32m    content: '\f11b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-book:before {[m
[32m+[m[32m    content: '\f11c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bookmark-outline:before {[m
[32m+[m[32m    content: '\f11d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bookmark:before {[m
[32m+[m[32m    content: '\f11e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brush:before {[m
[32m+[m[32m    content: '\f11f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bug:before {[m
[32m+[m[32m    content: '\f120'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bus:before {[m
[32m+[m[32m    content: '\f121'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cake:before {[m
[32m+[m[32m    content: '\f122'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-car-taxi:before {[m
[32m+[m[32m    content: '\f123'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-car-wash:before {[m
[32m+[m[32m    content: '\f124'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-car:before {[m
[32m+[m[32m    content: '\f125'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-giftcard:before {[m
[32m+[m[32m    content: '\f126'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-membership:before {[m
[32m+[m[32m    content: '\f127'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-travel:before {[m
[32m+[m[32m    content: '\f128'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card:before {[m
[32m+[m[32m    content: '\f129'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-case-check:before {[m
[32m+[m[32m    content: '\f12a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-case-download:before {[m
[32m+[m[32m    content: '\f12b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-case-play:before {[m
[32m+[m[32m    content: '\f12c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-case:before {[m
[32m+[m[32m    content: '\f12d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cast-connected:before {[m
[32m+[m[32m    content: '\f12e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cast:before {[m
[32m+[m[32m    content: '\f12f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-chart-donut:before {[m
[32m+[m[32m    content: '\f130'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-chart:before {[m
[32m+[m[32m    content: '\f131'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-city-alt:before {[m
[32m+[m[32m    content: '\f132'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-city:before {[m
[32m+[m[32m    content: '\f133'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-close-circle-o:before {[m
[32m+[m[32m    content: '\f134'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-close-circle:before {[m
[32m+[m[32m    content: '\f135'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-close:before {[m
[32m+[m[32m    content: '\f136'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cocktail:before {[m
[32m+[m[32m    content: '\f137'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-code-setting:before {[m
[32m+[m[32m    content: '\f138'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-code-smartphone:before {[m
[32m+[m[32m    content: '\f139'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-code:before {[m
[32m+[m[32m    content: '\f13a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-coffee:before {[m
[32m+[m[32m    content: '\f13b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-bookmark:before {[m
[32m+[m[32m    content: '\f13c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-case-play:before {[m
[32m+[m[32m    content: '\f13d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-folder-image:before {[m
[32m+[m[32m    content: '\f13e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-image-o:before {[m
[32m+[m[32m    content: '\f13f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-image:before {[m
[32m+[m[32m    content: '\f140'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-1:before {[m
[32m+[m[32m    content: '\f141'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-2:before {[m
[32m+[m[32m    content: '\f142'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-3:before {[m
[32m+[m[32m    content: '\f143'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-4:before {[m
[32m+[m[32m    content: '\f144'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-5:before {[m
[32m+[m[32m    content: '\f145'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-6:before {[m
[32m+[m[32m    content: '\f146'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-7:before {[m
[32m+[m[32m    content: '\f147'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-8:before {[m
[32m+[m[32m    content: '\f148'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-9-plus:before {[m
[32m+[m[32m    content: '\f149'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-9:before {[m
[32m+[m[32m    content: '\f14a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item:before {[m
[32m+[m[32m    content: '\f14b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-music:before {[m
[32m+[m[32m    content: '\f14c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-pdf:before {[m
[32m+[m[32m    content: '\f14d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-plus:before {[m
[32m+[m[32m    content: '\f14e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-speaker:before {[m
[32m+[m[32m    content: '\f14f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-text:before {[m
[32m+[m[32m    content: '\f150'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-video:before {[m
[32m+[m[32m    content: '\f151'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-compass:before {[m
[32m+[m[32m    content: '\f152'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cutlery:before {[m
[32m+[m[32m    content: '\f153'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-delete:before {[m
[32m+[m[32m    content: '\f154'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dialpad:before {[m
[32m+[m[32m    content: '\f155'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dns:before {[m
[32m+[m[32m    content: '\f156'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-drink:before {[m
[32m+[m[32m    content: '\f157'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-edit:before {[m
[32m+[m[32m    content: '\f158'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-email-open:before {[m
[32m+[m[32m    content: '\f159'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-email:before {[m
[32m+[m[32m    content: '\f15a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-eye-off:before {[m
[32m+[m[32m    content: '\f15b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-eye:before {[m
[32m+[m[32m    content: '\f15c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-eyedropper:before {[m
[32m+[m[32m    content: '\f15d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-favorite-outline:before {[m
[32m+[m[32m    content: '\f15e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-favorite:before {[m
[32m+[m[32m    content: '\f15f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-filter-list:before {[m
[32m+[m[32m    content: '\f160'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-fire:before {[m
[32m+[m[32m    content: '\f161'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flag:before {[m
[32m+[m[32m    content: '\f162'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flare:before {[m
[32m+[m[32m    content: '\f163'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flash-auto:before {[m
[32m+[m[32m    content: '\f164'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flash-off:before {[m
[32m+[m[32m    content: '\f165'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flash:before {[m
[32m+[m[32m    content: '\f166'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flip:before {[m
[32m+[m[32m    content: '\f167'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flower-alt:before {[m
[32m+[m[32m    content: '\f168'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flower:before {[m
[32m+[m[32m    content: '\f169'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-font:before {[m
[32m+[m[32m    content: '\f16a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-fullscreen-alt:before {[m
[32m+[m[32m    content: '\f16b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-fullscreen-exit:before {[m
[32m+[m[32m    content: '\f16c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-fullscreen:before {[m
[32m+[m[32m    content: '\f16d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-functions:before {[m
[32m+[m[32m    content: '\f16e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gas-station:before {[m
[32m+[m[32m    content: '\f16f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gesture:before {[m
[32m+[m[32m    content: '\f170'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-globe-alt:before {[m
[32m+[m[32m    content: '\f171'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-globe-lock:before {[m
[32m+[m[32m    content: '\f172'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-globe:before {[m
[32m+[m[32m    content: '\f173'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-graduation-cap:before {[m
[32m+[m[32m    content: '\f174'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-home:before {[m
[32m+[m[32m    content: '\f175'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hospital-alt:before {[m
[32m+[m[32m    content: '\f176'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hospital:before {[m
[32m+[m[32m    content: '\f177'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hotel:before {[m
[32m+[m[32m    content: '\f178'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hourglass-alt:before {[m
[32m+[m[32m    content: '\f179'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hourglass-outline:before {[m
[32m+[m[32m    content: '\f17a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hourglass:before {[m
[32m+[m[32m    content: '\f17b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-http:before {[m
[32m+[m[32m    content: '\f17c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-image-alt:before {[m
[32m+[m[32m    content: '\f17d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-image-o:before {[m
[32m+[m[32m    content: '\f17e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-image:before {[m
[32m+[m[32m    content: '\f17f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-inbox:before {[m
[32m+[m[32m    content: '\f180'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-invert-colors-off:before {[m
[32m+[m[32m    content: '\f181'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-invert-colors:before {[m
[32m+[m[32m    content: '\f182'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-key:before {[m
[32m+[m[32m    content: '\f183'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-label-alt-outline:before {[m
[32m+[m[32m    content: '\f184'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-label-alt:before {[m
[32m+[m[32m    content: '\f185'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-label-heart:before {[m
[32m+[m[32m    content: '\f186'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-label:before {[m
[32m+[m[32m    content: '\f187'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-labels:before {[m
[32m+[m[32m    content: '\f188'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-lamp:before {[m
[32m+[m[32m    content: '\f189'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-landscape:before {[m
[32m+[m[32m    content: '\f18a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-layers-off:before {[m
[32m+[m[32m    content: '\f18b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-layers:before {[m
[32m+[m[32m    content: '\f18c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-library:before {[m
[32m+[m[32m    content: '\f18d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-link:before {[m
[32m+[m[32m    content: '\f18e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-lock-open:before {[m
[32m+[m[32m    content: '\f18f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-lock-outline:before {[m
[32m+[m[32m    content: '\f190'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-lock:before {[m
[32m+[m[32m    content: '\f191'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mail-reply-all:before {[m
[32m+[m[32m    content: '\f192'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mail-reply:before {[m
[32m+[m[32m    content: '\f193'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mail-send:before {[m
[32m+[m[32m    content: '\f194'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mall:before {[m
[32m+[m[32m    content: '\f195'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-map:before {[m
[32m+[m[32m    content: '\f196'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-menu:before {[m
[32m+[m[32m    content: '\f197'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-money-box:before {[m
[32m+[m[32m    content: '\f198'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-money-off:before {[m
[32m+[m[32m    content: '\f199'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-money:before {[m
[32m+[m[32m    content: '\f19a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-more-vert:before {[m
[32m+[m[32m    content: '\f19b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-more:before {[m
[32m+[m[32m    content: '\f19c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-movie-alt:before {[m
[32m+[m[32m    content: '\f19d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-movie:before {[m
[32m+[m[32m    content: '\f19e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-nature-people:before {[m
[32m+[m[32m    content: '\f19f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-nature:before {[m
[32m+[m[32m    content: '\f1a0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-navigation:before {[m
[32m+[m[32m    content: '\f1a1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-open-in-browser:before {[m
[32m+[m[32m    content: '\f1a2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-open-in-new:before {[m
[32m+[m[32m    content: '\f1a3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-palette:before {[m
[32m+[m[32m    content: '\f1a4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-parking:before {[m
[32m+[m[32m    content: '\f1a5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pin-account:before {[m
[32m+[m[32m    content: '\f1a6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pin-assistant:before {[m
[32m+[m[32m    content: '\f1a7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pin-drop:before {[m
[32m+[m[32m    content: '\f1a8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pin-help:before {[m
[32m+[m[32m    content: '\f1a9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pin-off:before {[m
[32m+[m[32m    content: '\f1aa'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pin:before {[m
[32m+[m[32m    content: '\f1ab'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pizza:before {[m
[32m+[m[32m    content: '\f1ac'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plaster:before {[m
[32m+[m[32m    content: '\f1ad'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-power-setting:before {[m
[32m+[m[32m    content: '\f1ae'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-power:before {[m
[32m+[m[32m    content: '\f1af'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-print:before {[m
[32m+[m[32m    content: '\f1b0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-puzzle-piece:before {[m
[32m+[m[32m    content: '\f1b1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-quote:before {[m
[32m+[m[32m    content: '\f1b2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-railway:before {[m
[32m+[m[32m    content: '\f1b3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-receipt:before {[m
[32m+[m[32m    content: '\f1b4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-refresh-alt:before {[m
[32m+[m[32m    content: '\f1b5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-refresh-sync-alert:before {[m
[32m+[m[32m    content: '\f1b6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-refresh-sync-off:before {[m
[32m+[m[32m    content: '\f1b7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-refresh-sync:before {[m
[32m+[m[32m    content: '\f1b8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-refresh:before {[m
[32m+[m[32m    content: '\f1b9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-roller:before {[m
[32m+[m[32m    content: '\f1ba'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-ruler:before {[m
[32m+[m[32m    content: '\f1bb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-scissors:before {[m
[32m+[m[32m    content: '\f1bc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-screen-rotation-lock:before {[m
[32m+[m[32m    content: '\f1bd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-screen-rotation:before {[m
[32m+[m[32m    content: '\f1be'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-search-for:before {[m
[32m+[m[32m    content: '\f1bf'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-search-in-file:before {[m
[32m+[m[32m    content: '\f1c0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-search-in-page:before {[m
[32m+[m[32m    content: '\f1c1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-search-replace:before {[m
[32m+[m[32m    content: '\f1c2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-search:before {[m
[32m+[m[32m    content: '\f1c3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-seat:before {[m
[32m+[m[32m    content: '\f1c4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-settings-square:before {[m
[32m+[m[32m    content: '\f1c5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-settings:before {[m
[32m+[m[32m    content: '\f1c6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shield-check:before {[m
[32m+[m[32m    content: '\f1c7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shield-security:before {[m
[32m+[m[32m    content: '\f1c8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shopping-basket:before {[m
[32m+[m[32m    content: '\f1c9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shopping-cart-plus:before {[m
[32m+[m[32m    content: '\f1ca'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shopping-cart:before {[m
[32m+[m[32m    content: '\f1cb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sign-in:before {[m
[32m+[m[32m    content: '\f1cc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sort-amount-asc:before {[m
[32m+[m[32m    content: '\f1cd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sort-amount-desc:before {[m
[32m+[m[32m    content: '\f1ce'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sort-asc:before {[m
[32m+[m[32m    content: '\f1cf'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sort-desc:before {[m
[32m+[m[32m    content: '\f1d0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-spellcheck:before {[m
[32m+[m[32m    content: '\f1d1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-storage:before {[m
[32m+[m[32m    content: '\f1d2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-store-24:before {[m
[32m+[m[32m    content: '\f1d3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-store:before {[m
[32m+[m[32m    content: '\f1d4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-subway:before {[m
[32m+[m[32m    content: '\f1d5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sun:before {[m
[32m+[m[32m    content: '\f1d6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tab-unselected:before {[m
[32m+[m[32m    content: '\f1d7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tab:before {[m
[32m+[m[32m    content: '\f1d8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tag-close:before {[m
[32m+[m[32m    content: '\f1d9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tag-more:before {[m
[32m+[m[32m    content: '\f1da'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tag:before {[m
[32m+[m[32m    content: '\f1db'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-thumb-down:before {[m
[32m+[m[32m    content: '\f1dc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-thumb-up-down:before {[m
[32m+[m[32m    content: '\f1dd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-thumb-up:before {[m
[32m+[m[32m    content: '\f1de'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-ticket-star:before {[m
[32m+[m[32m    content: '\f1df'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-toll:before {[m
[32m+[m[32m    content: '\f1e0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-toys:before {[m
[32m+[m[32m    content: '\f1e1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-traffic:before {[m
[32m+[m[32m    content: '\f1e2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-translate:before {[m
[32m+[m[32m    content: '\f1e3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-triangle-down:before {[m
[32m+[m[32m    content: '\f1e4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-triangle-up:before {[m
[32m+[m[32m    content: '\f1e5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-truck:before {[m
[32m+[m[32m    content: '\f1e6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-turning-sign:before {[m
[32m+[m[32m    content: '\f1e7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wallpaper:before {[m
[32m+[m[32m    content: '\f1e8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-washing-machine:before {[m
[32m+[m[32m    content: '\f1e9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-window-maximize:before {[m
[32m+[m[32m    content: '\f1ea'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-window-minimize:before {[m
[32m+[m[32m    content: '\f1eb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-window-restore:before {[m
[32m+[m[32m    content: '\f1ec'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wrench:before {[m
[32m+[m[32m    content: '\f1ed'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-zoom-in:before {[m
[32m+[m[32m    content: '\f1ee'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-zoom-out:before {[m
[32m+[m[32m    content: '\f1ef'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alert-circle-o:before {[m
[32m+[m[32m    content: '\f1f0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alert-circle:before {[m
[32m+[m[32m    content: '\f1f1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alert-octagon:before {[m
[32m+[m[32m    content: '\f1f2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alert-polygon:before {[m
[32m+[m[32m    content: '\f1f3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alert-triangle:before {[m
[32m+[m[32m    content: '\f1f4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-help-outline:before {[m
[32m+[m[32m    content: '\f1f5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-help:before {[m
[32m+[m[32m    content: '\f1f6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-info-outline:before {[m
[32m+[m[32m    content: '\f1f7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-info:before {[m
[32m+[m[32m    content: '\f1f8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-notifications-active:before {[m
[32m+[m[32m    content: '\f1f9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-notifications-add:before {[m
[32m+[m[32m    content: '\f1fa'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-notifications-none:before {[m
[32m+[m[32m    content: '\f1fb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-notifications-off:before {[m
[32m+[m[32m    content: '\f1fc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-notifications-paused:before {[m
[32m+[m[32m    content: '\f1fd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-notifications:before {[m
[32m+[m[32m    content: '\f1fe'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-add:before {[m
[32m+[m[32m    content: '\f1ff'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-box-mail:before {[m
[32m+[m[32m    content: '\f200'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-box-o:before {[m
[32m+[m[32m    content: '\f201'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-box-phone:before {[m
[32m+[m[32m    content: '\f202'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-box:before {[m
[32m+[m[32m    content: '\f203'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-calendar:before {[m
[32m+[m[32m    content: '\f204'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-circle:before {[m
[32m+[m[32m    content: '\f205'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-o:before {[m
[32m+[m[32m    content: '\f206'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account:before {[m
[32m+[m[32m    content: '\f207'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-accounts-add:before {[m
[32m+[m[32m    content: '\f208'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-accounts-alt:before {[m
[32m+[m[32m    content: '\f209'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-accounts-list-alt:before {[m
[32m+[m[32m    content: '\f20a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-accounts-list:before {[m
[32m+[m[32m    content: '\f20b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-accounts-outline:before {[m
[32m+[m[32m    content: '\f20c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-accounts:before {[m
[32m+[m[32m    content: '\f20d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-face:before {[m
[32m+[m[32m    content: '\f20e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-female:before {[m
[32m+[m[32m    content: '\f20f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-male-alt:before {[m
[32m+[m[32m    content: '\f210'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-male-female:before {[m
[32m+[m[32m    content: '\f211'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-male:before {[m
[32m+[m[32m    content: '\f212'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mood-bad:before {[m
[32m+[m[32m    content: '\f213'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mood:before {[m
[32m+[m[32m    content: '\f214'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-run:before {[m
[32m+[m[32m    content: '\f215'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-walk:before {[m
[32m+[m[32m    content: '\f216'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-box:before {[m
[32m+[m[32m    content: '\f217'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-circle:before {[m
[32m+[m[32m    content: '\f218'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-done:before {[m
[32m+[m[32m    content: '\f219'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-download:before {[m
[32m+[m[32m    content: '\f21a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-off:before {[m
[32m+[m[32m    content: '\f21b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-outline-alt:before {[m
[32m+[m[32m    content: '\f21c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-outline:before {[m
[32m+[m[32m    content: '\f21d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-upload:before {[m
[32m+[m[32m    content: '\f21e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud:before {[m
[32m+[m[32m    content: '\f21f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-download:before {[m
[32m+[m[32m    content: '\f220'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-file-plus:before {[m
[32m+[m[32m    content: '\f221'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-file-text:before {[m
[32m+[m[32m    content: '\f222'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-file:before {[m
[32m+[m[32m    content: '\f223'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-folder-outline:before {[m
[32m+[m[32m    content: '\f224'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-folder-person:before {[m
[32m+[m[32m    content: '\f225'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-folder-star-alt:before {[m
[32m+[m[32m    content: '\f226'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-folder-star:before {[m
[32m+[m[32m    content: '\f227'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-folder:before {[m
[32m+[m[32m    content: '\f228'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gif:before {[m
[32m+[m[32m    content: '\f229'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-upload:before {[m
[32m+[m[32m    content: '\f22a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-all:before {[m
[32m+[m[32m    content: '\f22b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-bottom:before {[m
[32m+[m[32m    content: '\f22c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-clear:before {[m
[32m+[m[32m    content: '\f22d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-color:before {[m
[32m+[m[32m    content: '\f22e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-horizontal:before {[m
[32m+[m[32m    content: '\f22f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-inner:before {[m
[32m+[m[32m    content: '\f230'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-left:before {[m
[32m+[m[32m    content: '\f231'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-outer:before {[m
[32m+[m[32m    content: '\f232'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-right:before {[m
[32m+[m[32m    content: '\f233'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-style:before {[m
[32m+[m[32m    content: '\f234'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-top:before {[m
[32m+[m[32m    content: '\f235'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-vertical:before {[m
[32m+[m[32m    content: '\f236'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-copy:before {[m
[32m+[m[32m    content: '\f237'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop:before {[m
[32m+[m[32m    content: '\f238'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-align-center:before {[m
[32m+[m[32m    content: '\f239'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-align-justify:before {[m
[32m+[m[32m    content: '\f23a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-align-left:before {[m
[32m+[m[32m    content: '\f23b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-align-right:before {[m
[32m+[m[32m    content: '\f23c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-bold:before {[m
[32m+[m[32m    content: '\f23d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-clear-all:before {[m
[32m+[m[32m    content: '\f23e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-clear:before {[m
[32m+[m[32m    content: '\f23f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-color-fill:before {[m
[32m+[m[32m    content: '\f240'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-color-reset:before {[m
[32m+[m[32m    content: '\f241'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-color-text:before {[m
[32m+[m[32m    content: '\f242'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-indent-decrease:before {[m
[32m+[m[32m    content: '\f243'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-indent-increase:before {[m
[32m+[m[32m    content: '\f244'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-italic:before {[m
[32m+[m[32m    content: '\f245'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-line-spacing:before {[m
[32m+[m[32m    content: '\f246'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-list-bulleted:before {[m
[32m+[m[32m    content: '\f247'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-list-numbered:before {[m
[32m+[m[32m    content: '\f248'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-ltr:before {[m
[32m+[m[32m    content: '\f249'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-rtl:before {[m
[32m+[m[32m    content: '\f24a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-size:before {[m
[32m+[m[32m    content: '\f24b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-strikethrough-s:before {[m
[32m+[m[32m    content: '\f24c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-strikethrough:before {[m
[32m+[m[32m    content: '\f24d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-subject:before {[m
[32m+[m[32m    content: '\f24e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-underlined:before {[m
[32m+[m[32m    content: '\f24f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-valign-bottom:before {[m
[32m+[m[32m    content: '\f250'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-valign-center:before {[m
[32m+[m[32m    content: '\f251'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-valign-top:before {[m
[32m+[m[32m    content: '\f252'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-redo:before {[m
[32m+[m[32m    content: '\f253'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-select-all:before {[m
[32m+[m[32m    content: '\f254'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-space-bar:before {[m
[32m+[m[32m    content: '\f255'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-text-format:before {[m
[32m+[m[32m    content: '\f256'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-transform:before {[m
[32m+[m[32m    content: '\f257'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-undo:before {[m
[32m+[m[32m    content: '\f258'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wrap-text:before {[m
[32m+[m[32m    content: '\f259'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-alert:before {[m
[32m+[m[32m    content: '\f25a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-alt-text:before {[m
[32m+[m[32m    content: '\f25b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-alt:before {[m
[32m+[m[32m    content: '\f25c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-edit:before {[m
[32m+[m[32m    content: '\f25d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-image:before {[m
[32m+[m[32m    content: '\f25e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-list:before {[m
[32m+[m[32m    content: '\f25f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-more:before {[m
[32m+[m[32m    content: '\f260'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-outline:before {[m
[32m+[m[32m    content: '\f261'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-text-alt:before {[m
[32m+[m[32m    content: '\f262'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-text:before {[m
[32m+[m[32m    content: '\f263'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-video:before {[m
[32m+[m[32m    content: '\f264'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment:before {[m
[32m+[m[32m    content: '\f265'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comments:before {[m
[32m+[m[32m    content: '\f266'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-check-all:before {[m
[32m+[m[32m    content: '\f267'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-check-circle-u:before {[m
[32m+[m[32m    content: '\f268'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-check-circle:before {[m
[32m+[m[32m    content: '\f269'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-check-square:before {[m
[32m+[m[32m    content: '\f26a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-check:before {[m
[32m+[m[32m    content: '\f26b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-circle-o:before {[m
[32m+[m[32m    content: '\f26c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-circle:before {[m
[32m+[m[32m    content: '\f26d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dot-circle-alt:before {[m
[32m+[m[32m    content: '\f26e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dot-circle:before {[m
[32m+[m[32m    content: '\f26f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-minus-circle-outline:before {[m
[32m+[m[32m    content: '\f270'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-minus-circle:before {[m
[32m+[m[32m    content: '\f271'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-minus-square:before {[m
[32m+[m[32m    content: '\f272'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-minus:before {[m
[32m+[m[32m    content: '\f273'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus-circle-o-duplicate:before {[m
[32m+[m[32m    content: '\f274'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus-circle-o:before {[m
[32m+[m[32m    content: '\f275'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus-circle:before {[m
[32m+[m[32m    content: '\f276'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus-square:before {[m
[32m+[m[32m    content: '\f277'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus:before {[m
[32m+[m[32m    content: '\f278'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-square-o:before {[m
[32m+[m[32m    content: '\f279'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-star-circle:before {[m
[32m+[m[32m    content: '\f27a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-star-half:before {[m
[32m+[m[32m    content: '\f27b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-star-outline:before {[m
[32m+[m[32m    content: '\f27c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-star:before {[m
[32m+[m[32m    content: '\f27d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bluetooth-connected:before {[m
[32m+[m[32m    content: '\f27e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bluetooth-off:before {[m
[32m+[m[32m    content: '\f27f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bluetooth-search:before {[m
[32m+[m[32m    content: '\f280'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bluetooth-setting:before {[m
[32m+[m[32m    content: '\f281'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bluetooth:before {[m
[32m+[m[32m    content: '\f282'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-add:before {[m
[32m+[m[32m    content: '\f283'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-alt:before {[m
[32m+[m[32m    content: '\f284'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-bw:before {[m
[32m+[m[32m    content: '\f285'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-front:before {[m
[32m+[m[32m    content: '\f286'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-mic:before {[m
[32m+[m[32m    content: '\f287'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-party-mode:before {[m
[32m+[m[32m    content: '\f288'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-rear:before {[m
[32m+[m[32m    content: '\f289'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-roll:before {[m
[32m+[m[32m    content: '\f28a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-switch:before {[m
[32m+[m[32m    content: '\f28b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera:before {[m
[32m+[m[32m    content: '\f28c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-alert:before {[m
[32m+[m[32m    content: '\f28d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-off:before {[m
[32m+[m[32m    content: '\f28e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-sd:before {[m
[32m+[m[32m    content: '\f28f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-sim:before {[m
[32m+[m[32m    content: '\f290'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-desktop-mac:before {[m
[32m+[m[32m    content: '\f291'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-desktop-windows:before {[m
[32m+[m[32m    content: '\f292'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-device-hub:before {[m
[32m+[m[32m    content: '\f293'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-devices-off:before {[m
[32m+[m[32m    content: '\f294'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-devices:before {[m
[32m+[m[32m    content: '\f295'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dock:before {[m
[32m+[m[32m    content: '\f296'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-floppy:before {[m
[32m+[m[32m    content: '\f297'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gamepad:before {[m
[32m+[m[32m    content: '\f298'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gps-dot:before {[m
[32m+[m[32m    content: '\f299'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gps-off:before {[m
[32m+[m[32m    content: '\f29a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gps:before {[m
[32m+[m[32m    content: '\f29b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-headset-mic:before {[m
[32m+[m[32m    content: '\f29c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-headset:before {[m
[32m+[m[32m    content: '\f29d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-input-antenna:before {[m
[32m+[m[32m    content: '\f29e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-input-composite:before {[m
[32m+[m[32m    content: '\f29f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-input-hdmi:before {[m
[32m+[m[32m    content: '\f2a0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-input-power:before {[m
[32m+[m[32m    content: '\f2a1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-input-svideo:before {[m
[32m+[m[32m    content: '\f2a2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-keyboard-hide:before {[m
[32m+[m[32m    content: '\f2a3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-keyboard:before {[m
[32m+[m[32m    content: '\f2a4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-laptop-chromebook:before {[m
[32m+[m[32m    content: '\f2a5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-laptop-mac:before {[m
[32m+[m[32m    content: '\f2a6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-laptop:before {[m
[32m+[m[32m    content: '\f2a7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mic-off:before {[m
[32m+[m[32m    content: '\f2a8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mic-outline:before {[m
[32m+[m[32m    content: '\f2a9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mic-setting:before {[m
[32m+[m[32m    content: '\f2aa'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mic:before {[m
[32m+[m[32m    content: '\f2ab'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mouse:before {[m
[32m+[m[32m    content: '\f2ac'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-alert:before {[m
[32m+[m[32m    content: '\f2ad'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-locked:before {[m
[32m+[m[32m    content: '\f2ae'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-off:before {[m
[32m+[m[32m    content: '\f2af'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-outline:before {[m
[32m+[m[32m    content: '\f2b0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-setting:before {[m
[32m+[m[32m    content: '\f2b1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network:before {[m
[32m+[m[32m    content: '\f2b2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-bluetooth:before {[m
[32m+[m[32m    content: '\f2b3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-end:before {[m
[32m+[m[32m    content: '\f2b4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-forwarded:before {[m
[32m+[m[32m    content: '\f2b5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-in-talk:before {[m
[32m+[m[32m    content: '\f2b6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-locked:before {[m
[32m+[m[32m    content: '\f2b7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-missed:before {[m
[32m+[m[32m    content: '\f2b8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-msg:before {[m
[32m+[m[32m    content: '\f2b9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-paused:before {[m
[32m+[m[32m    content: '\f2ba'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-ring:before {[m
[32m+[m[32m    content: '\f2bb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-setting:before {[m
[32m+[m[32m    content: '\f2bc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-sip:before {[m
[32m+[m[32m    content: '\f2bd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone:before {[m
[32m+[m[32m    content: '\f2be'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-portable-wifi-changes:before {[m
[32m+[m[32m    content: '\f2bf'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-portable-wifi-off:before {[m
[32m+[m[32m    content: '\f2c0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-portable-wifi:before {[m
[32m+[m[32m    content: '\f2c1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-radio:before {[m
[32m+[m[32m    content: '\f2c2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-reader:before {[m
[32m+[m[32m    content: '\f2c3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-remote-control-alt:before {[m
[32m+[m[32m    content: '\f2c4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-remote-control:before {[m
[32m+[m[32m    content: '\f2c5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-router:before {[m
[32m+[m[32m    content: '\f2c6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-scanner:before {[m
[32m+[m[32m    content: '\f2c7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-android:before {[m
[32m+[m[32m    content: '\f2c8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-download:before {[m
[32m+[m[32m    content: '\f2c9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-erase:before {[m
[32m+[m[32m    content: '\f2ca'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-info:before {[m
[32m+[m[32m    content: '\f2cb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-iphone:before {[m
[32m+[m[32m    content: '\f2cc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-landscape-lock:before {[m
[32m+[m[32m    content: '\f2cd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-landscape:before {[m
[32m+[m[32m    content: '\f2ce'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-lock:before {[m
[32m+[m[32m    content: '\f2cf'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-portrait-lock:before {[m
[32m+[m[32m    content: '\f2d0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-ring:before {[m
[32m+[m[32m    content: '\f2d1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-setting:before {[m
[32m+[m[32m    content: '\f2d2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-setup:before {[m
[32m+[m[32m    content: '\f2d3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone:before {[m
[32m+[m[32m    content: '\f2d4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-speaker:before {[m
[32m+[m[32m    content: '\f2d5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tablet-android:before {[m
[32m+[m[32m    content: '\f2d6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tablet-mac:before {[m
[32m+[m[32m    content: '\f2d7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tablet:before {[m
[32m+[m[32m    content: '\f2d8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tv-alt-play:before {[m
[32m+[m[32m    content: '\f2d9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tv-list:before {[m
[32m+[m[32m    content: '\f2da'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tv-play:before {[m
[32m+[m[32m    content: '\f2db'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tv:before {[m
[32m+[m[32m    content: '\f2dc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-usb:before {[m
[32m+[m[32m    content: '\f2dd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-videocam-off:before {[m
[32m+[m[32m    content: '\f2de'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-videocam-switch:before {[m
[32m+[m[32m    content: '\f2df'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-videocam:before {[m
[32m+[m[32m    content: '\f2e0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-watch:before {[m
[32m+[m[32m    content: '\f2e1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi-alt-2:before {[m
[32m+[m[32m    content: '\f2e2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi-alt:before {[m
[32m+[m[32m    content: '\f2e3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi-info:before {[m
[32m+[m[32m    content: '\f2e4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi-lock:before {[m
[32m+[m[32m    content: '\f2e5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi-off:before {[m
[32m+[m[32m    content: '\f2e6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi-outline:before {[m
[32m+[m[32m    content: '\f2e7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi:before {[m
[32m+[m[32m    content: '\f2e8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-left-bottom:before {[m
[32m+[m[32m    content: '\f2e9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-left:before {[m
[32m+[m[32m    content: '\f2ea'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-merge:before {[m
[32m+[m[32m    content: '\f2eb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-missed:before {[m
[32m+[m[32m    content: '\f2ec'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-right-top:before {[m
[32m+[m[32m    content: '\f2ed'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-right:before {[m
[32m+[m[32m    content: '\f2ee'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-split:before {[m
[32m+[m[32m    content: '\f2ef'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrows:before {[m
[32m+[m[32m    content: '\f2f0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-down-circle:before {[m
[32m+[m[32m    content: '\f2f1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-down:before {[m
[32m+[m[32m    content: '\f2f2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-left-circle:before {[m
[32m+[m[32m    content: '\f2f3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-left:before {[m
[32m+[m[32m    content: '\f2f4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-right-circle:before {[m
[32m+[m[32m    content: '\f2f5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-right:before {[m
[32m+[m[32m    content: '\f2f6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-up-circle:before {[m
[32m+[m[32m    content: '\f2f7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-up:before {[m
[32m+[m[32m    content: '\f2f8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-chevron-down:before {[m
[32m+[m[32m    content: '\f2f9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-chevron-left:before {[m
[32m+[m[32m    content: '\f2fa'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-chevron-right:before {[m
[32m+[m[32m    content: '\f2fb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-chevron-up:before {[m
[32m+[m[32m    content: '\f2fc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-forward:before {[m
[32m+[m[32m    content: '\f2fd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-long-arrow-down:before {[m
[32m+[m[32m    content: '\f2fe'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-long-arrow-left:before {[m
[32m+[m[32m    content: '\f2ff'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-long-arrow-return:before {[m
[32m+[m[32m    content: '\f300'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-long-arrow-right:before {[m
[32m+[m[32m    content: '\f301'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-long-arrow-tab:before {[m
[32m+[m[32m    content: '\f302'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-long-arrow-up:before {[m
[32m+[m[32m    content: '\f303'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-rotate-ccw:before {[m
[32m+[m[32m    content: '\f304'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-rotate-cw:before {[m
[32m+[m[32m    content: '\f305'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-rotate-left:before {[m
[32m+[m[32m    content: '\f306'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-rotate-right:before {[m
[32m+[m[32m    content: '\f307'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-square-down:before {[m
[32m+[m[32m    content: '\f308'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-square-right:before {[m
[32m+[m[32m    content: '\f309'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-swap-alt:before {[m
[32m+[m[32m    content: '\f30a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-swap-vertical-circle:before {[m
[32m+[m[32m    content: '\f30b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-swap-vertical:before {[m
[32m+[m[32m    content: '\f30c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-swap:before {[m
[32m+[m[32m    content: '\f30d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-trending-down:before {[m
[32m+[m[32m    content: '\f30e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-trending-flat:before {[m
[32m+[m[32m    content: '\f30f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-trending-up:before {[m
[32m+[m[32m    content: '\f310'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-unfold-less:before {[m
[32m+[m[32m    content: '\f311'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-unfold-more:before {[m
[32m+[m[32m    content: '\f312'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-apps:before {[m
[32m+[m[32m    content: '\f313'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-grid-off:before {[m
[32m+[m[32m    content: '\f314'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-grid:before {[m
[32m+[m[32m    content: '\f315'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-agenda:before {[m
[32m+[m[32m    content: '\f316'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-array:before {[m
[32m+[m[32m    content: '\f317'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-carousel:before {[m
[32m+[m[32m    content: '\f318'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-column:before {[m
[32m+[m[32m    content: '\f319'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-comfy:before {[m
[32m+[m[32m    content: '\f31a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-compact:before {[m
[32m+[m[32m    content: '\f31b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-dashboard:before {[m
[32m+[m[32m    content: '\f31c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-day:before {[m
[32m+[m[32m    content: '\f31d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-headline:before {[m
[32m+[m[32m    content: '\f31e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-list-alt:before {[m
[32m+[m[32m    content: '\f31f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-list:before {[m
[32m+[m[32m    content: '\f320'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-module:before {[m
[32m+[m[32m    content: '\f321'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-quilt:before {[m
[32m+[m[32m    content: '\f322'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-stream:before {[m
[32m+[m[32m    content: '\f323'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-subtitles:before {[m
[32m+[m[32m    content: '\f324'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-toc:before {[m
[32m+[m[32m    content: '\f325'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-web:before {[m
[32m+[m[32m    content: '\f326'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-week:before {[m
[32m+[m[32m    content: '\f327'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-widgets:before {[m
[32m+[m[32m    content: '\f328'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alarm-check:before {[m
[32m+[m[32m    content: '\f329'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alarm-off:before {[m
[32m+[m[32m    content: '\f32a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alarm-plus:before {[m
[32m+[m[32m    content: '\f32b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alarm-snooze:before {[m
[32m+[m[32m    content: '\f32c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alarm:before {[m
[32m+[m[32m    content: '\f32d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-calendar-alt:before {[m
[32m+[m[32m    content: '\f32e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-calendar-check:before {[m
[32m+[m[32m    content: '\f32f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-calendar-close:before {[m
[32m+[m[32m    content: '\f330'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-calendar-note:before {[m
[32m+[m[32m    content: '\f331'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-calendar:before {[m
[32m+[m[32m    content: '\f332'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-time-countdown:before {[m
[32m+[m[32m    content: '\f333'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-time-interval:before {[m
[32m+[m[32m    content: '\f334'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-time-restore-setting:before {[m
[32m+[m[32m    content: '\f335'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-time-restore:before {[m
[32m+[m[32m    content: '\f336'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-time:before {[m
[32m+[m[32m    content: '\f337'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-timer-off:before {[m
[32m+[m[32m    content: '\f338'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-timer:before {[m
[32m+[m[32m    content: '\f339'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-android-alt:before {[m
[32m+[m[32m    content: '\f33a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-android:before {[m
[32m+[m[32m    content: '\f33b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-apple:before {[m
[32m+[m[32m    content: '\f33c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-behance:before {[m
[32m+[m[32m    content: '\f33d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-codepen:before {[m
[32m+[m[32m    content: '\f33e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dribbble:before {[m
[32m+[m[32m    content: '\f33f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dropbox:before {[m
[32m+[m[32m    content: '\f340'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-evernote:before {[m
[32m+[m[32m    content: '\f341'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-facebook-box:before {[m
[32m+[m[32m    content: '\f342'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-facebook:before {[m
[32m+[m[32m    content: '\f343'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-github-box:before {[m
[32m+[m[32m    content: '\f344'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-github:before {[m
[32m+[m[32m    content: '\f345'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-drive:before {[m
[32m+[m[32m    content: '\f346'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-earth:before {[m
[32m+[m[32m    content: '\f347'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-glass:before {[m
[32m+[m[32m    content: '\f348'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-maps:before {[m
[32m+[m[32m    content: '\f349'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-pages:before {[m
[32m+[m[32m    content: '\f34a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-play:before {[m
[32m+[m[32m    content: '\f34b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-plus-box:before {[m
[32m+[m[32m    content: '\f34c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-plus:before {[m
[32m+[m[32m    content: '\f34d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google:before {[m
[32m+[m[32m    content: '\f34e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-instagram:before {[m
[32m+[m[32m    content: '\f34f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-language-css3:before {[m
[32m+[m[32m    content: '\f350'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-language-html5:before {[m
[32m+[m[32m    content: '\f351'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-language-javascript:before {[m
[32m+[m[32m    content: '\f352'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-language-python-alt:before {[m
[32m+[m[32m    content: '\f353'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-language-python:before {[m
[32m+[m[32m    content: '\f354'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-lastfm:before {[m
[32m+[m[32m    content: '\f355'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-linkedin-box:before {[m
[32m+[m[32m    content: '\f356'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-paypal:before {[m
[32m+[m[32m    content: '\f357'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pinterest-box:before {[m
[32m+[m[32m    content: '\f358'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pocket:before {[m
[32m+[m[32m    content: '\f359'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-polymer:before {[m
[32m+[m[32m    content: '\f35a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-share:before {[m
[32m+[m[32m    content: '\f35b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-stackoverflow:before {[m
[32m+[m[32m    content: '\f35c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-steam-square:before {[m
[32m+[m[32m    content: '\f35d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-steam:before {[m
[32m+[m[32m    content: '\f35e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-twitter-box:before {[m
[32m+[m[32m    content: '\f35f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-twitter:before {[m
[32m+[m[32m    content: '\f360'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-vk:before {[m
[32m+[m[32m    content: '\f361'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wikipedia:before {[m
[32m+[m[32m    content: '\f362'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-windows:before {[m
[32m+[m[32m    content: '\f363'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-aspect-ratio-alt:before {[m
[32m+[m[32m    content: '\f364'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-aspect-ratio:before {[m
[32m+[m[32m    content: '\f365'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-blur-circular:before {[m
[32m+[m[32m    content: '\f366'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-blur-linear:before {[m
[32m+[m[32m    content: '\f367'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-blur-off:before {[m
[32m+[m[32m    content: '\f368'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-blur:before {[m
[32m+[m[32m    content: '\f369'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-2:before {[m
[32m+[m[32m    content: '\f36a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-3:before {[m
[32m+[m[32m    content: '\f36b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-4:before {[m
[32m+[m[32m    content: '\f36c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-5:before {[m
[32m+[m[32m    content: '\f36d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-6:before {[m
[32m+[m[32m    content: '\f36e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-7:before {[m
[32m+[m[32m    content: '\f36f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-auto:before {[m
[32m+[m[32m    content: '\f370'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-setting:before {[m
[32m+[m[32m    content: '\f371'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-broken-image:before {[m
[32m+[m[32m    content: '\f372'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-center-focus-strong:before {[m
[32m+[m[32m    content: '\f373'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-center-focus-weak:before {[m
[32m+[m[32m    content: '\f374'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-compare:before {[m
[32m+[m[32m    content: '\f375'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-16-9:before {[m
[32m+[m[32m    content: '\f376'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-3-2:before {[m
[32m+[m[32m    content: '\f377'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-5-4:before {[m
[32m+[m[32m    content: '\f378'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-7-5:before {[m
[32m+[m[32m    content: '\f379'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-din:before {[m
[32m+[m[32m    content: '\f37a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-free:before {[m
[32m+[m[32m    content: '\f37b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-landscape:before {[m
[32m+[m[32m    content: '\f37c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-portrait:before {[m
[32m+[m[32m    content: '\f37d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-square:before {[m
[32m+[m[32m    content: '\f37e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-exposure-alt:before {[m
[32m+[m[32m    content: '\f37f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-exposure:before {[m
[32m+[m[32m    content: '\f380'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-filter-b-and-w:before {[m
[32m+[m[32m    content: '\f381'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-filter-center-focus:before {[m
[32m+[m[32m    content: '\f382'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-filter-frames:before {[m
[32m+[m[32m    content: '\f383'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-filter-tilt-shift:before {[m
[32m+[m[32m    content: '\f384'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gradient:before {[m
[32m+[m[32m    content: '\f385'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-grain:before {[m
[32m+[m[32m    content: '\f386'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-graphic-eq:before {[m
[32m+[m[32m    content: '\f387'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hdr-off:before {[m
[32m+[m[32m    content: '\f388'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hdr-strong:before {[m
[32m+[m[32m    content: '\f389'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hdr-weak:before {[m
[32m+[m[32m    content: '\f38a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hdr:before {[m
[32m+[m[32m    content: '\f38b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-iridescent:before {[m
[32m+[m[32m    content: '\f38c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-leak-off:before {[m
[32m+[m[32m    content: '\f38d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-leak:before {[m
[32m+[m[32m    content: '\f38e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-looks:before {[m
[32m+[m[32m    content: '\f38f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-loupe:before {[m
[32m+[m[32m    content: '\f390'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-panorama-horizontal:before {[m
[32m+[m[32m    content: '\f391'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-panorama-vertical:before {[m
[32m+[m[32m    content: '\f392'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-panorama-wide-angle:before {[m
[32m+[m[32m    content: '\f393'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-photo-size-select-large:before {[m
[32m+[m[32m    content: '\f394'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-photo-size-select-small:before {[m
[32m+[m[32m    content: '\f395'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-picture-in-picture:before {[m
[32m+[m[32m    content: '\f396'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-slideshow:before {[m
[32m+[m[32m    content: '\f397'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-texture:before {[m
[32m+[m[32m    content: '\f398'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tonality:before {[m
[32m+[m[32m    content: '\f399'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-vignette:before {[m
[32m+[m[32m    content: '\f39a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wb-auto:before {[m
[32m+[m[32m    content: '\f39b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-eject-alt:before {[m
[32m+[m[32m    content: '\f39c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-eject:before {[m
[32m+[m[32m    content: '\f39d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-equalizer:before {[m
[32m+[m[32m    content: '\f39e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-fast-forward:before {[m
[32m+[m[32m    content: '\f39f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-fast-rewind:before {[m
[32m+[m[32m    content: '\f3a0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-forward-10:before {[m
[32m+[m[32m    content: '\f3a1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-forward-30:before {[m
[32m+[m[32m    content: '\f3a2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-forward-5:before {[m
[32m+[m[32m    content: '\f3a3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hearing:before {[m
[32m+[m[32m    content: '\f3a4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pause-circle-outline:before {[m
[32m+[m[32m    content: '\f3a5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pause-circle:before {[m
[32m+[m[32m    content: '\f3a6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pause:before {[m
[32m+[m[32m    content: '\f3a7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-play-circle-outline:before {[m
[32m+[m[32m    content: '\f3a8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-play-circle:before {[m
[32m+[m[32m    content: '\f3a9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-play:before {[m
[32m+[m[32m    content: '\f3aa'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-playlist-audio:before {[m
[32m+[m[32m    content: '\f3ab'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-playlist-plus:before {[m
[32m+[m[32m    content: '\f3ac'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-repeat-one:before {[m
[32m+[m[32m    content: '\f3ad'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-repeat:before {[m
[32m+[m[32m    content: '\f3ae'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-replay-10:before {[m
[32m+[m[32m    content: '\f3af'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-replay-30:before {[m
[32m+[m[32m    content: '\f3b0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-replay-5:before {[m
[32m+[m[32m    content: '\f3b1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-replay:before {[m
[32m+[m[32m    content: '\f3b2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shuffle:before {[m
[32m+[m[32m    content: '\f3b3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-skip-next:before {[m
[32m+[m[32m    content: '\f3b4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-skip-previous:before {[m
[32m+[m[32m    content: '\f3b5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-stop:before {[m
[32m+[m[32m    content: '\f3b6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-surround-sound:before {[m
[32m+[m[32m    content: '\f3b7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tune:before {[m
[32m+[m[32m    content: '\f3b8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-volume-down:before {[m
[32m+[m[32m    content: '\f3b9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-volume-mute:before {[m
[32m+[m[32m    content: '\f3ba'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-volume-off:before {[m
[32m+[m[32m    content: '\f3bb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-volume-up:before {[m
[32m+[m[32m    content: '\f3bc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-n-1-square:before {[m
[32m+[m[32m    content: '\f3bd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-n-2-square:before {[m
[32m+[m[32m    content: '\f3be'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-n-3-square:before {[m
[32m+[m[32m    content: '\f3bf'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-n-4-square:before {[m
[32m+[m[32m    content: '\f3c0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-n-5-square:before {[m
[32m+[m[32m    content: '\f3c1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-n-6-square:before {[m
[32m+[m[32m    content: '\f3c2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-neg-1:before {[m
[32m+[m[32m    content: '\f3c3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-neg-2:before {[m
[32m+[m[32m    content: '\f3c4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus-1:before {[m
[32m+[m[32m    content: '\f3c5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus-2:before {[m
[32m+[m[32m    content: '\f3c6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sec-10:before {[m
[32m+[m[32m    content: '\f3c7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sec-3:before {[m
[32m+[m[32m    content: '\f3c8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-zero:before {[m
[32m+[m[32m    content: '\f3c9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-flat-angled:before {[m
[32m+[m[32m    content: '\f3ca'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-flat:before {[m
[32m+[m[32m    content: '\f3cb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-individual-suite:before {[m
[32m+[m[32m    content: '\f3cc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-legroom-extra:before {[m
[32m+[m[32m    content: '\f3cd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-legroom-normal:before {[m
[32m+[m[32m    content: '\f3ce'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-legroom-reduced:before {[m
[32m+[m[32m    content: '\f3cf'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-recline-extra:before {[m
[32m+[m[32m    content: '\f3d0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-recline-normal:before {[m
[32m+[m[32m    content: '\f3d1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airplay:before {[m
[32m+[m[32m    content: '\f3d2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-closed-caption:before {[m
[32m+[m[32m    content: '\f3d3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-confirmation-number:before {[m
[32m+[m[32m    content: '\f3d4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-developer-board:before {[m
[32m+[m[32m    content: '\f3d5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-disc-full:before {[m
[32m+[m[32m    content: '\f3d6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-explicit:before {[m
[32m+[m[32m    content: '\f3d7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flight-land:before {[m
[32m+[m[32m    content: '\f3d8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flight-takeoff:before {[m
[32m+[m[32m    content: '\f3d9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flip-to-back:before {[m
[32m+[m[32m    content: '\f3da'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flip-to-front:before {[m
[32m+[m[32m    content: '\f3db'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-group-work:before {[m
[32m+[m[32m    content: '\f3dc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hd:before {[m
[32m+[m[32m    content: '\f3dd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hq:before {[m
[32m+[m[32m    content: '\f3de'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-markunread-mailbox:before {[m
[32m+[m[32m    content: '\f3df'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-memory:before {[m
[32m+[m[32m    content: '\f3e0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-nfc:before {[m
[32m+[m[32m    content: '\f3e1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-play-for-work:before {[m
[32m+[m[32m    content: '\f3e2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-power-input:before {[m
[32m+[m[32m    content: '\f3e3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-present-to-all:before {[m
[32m+[m[32m    content: '\f3e4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-satellite:before {[m
[32m+[m[32m    content: '\f3e5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tap-and-play:before {[m
[32m+[m[32m    content: '\f3e6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-vibration:before {[m
[32m+[m[32m    content: '\f3e7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-voicemail:before {[m
[32m+[m[32m    content: '\f3e8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-group:before {[m
[32m+[m[32m    content: '\f3e9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-rss:before {[m
[32m+[m[32m    content: '\f3ea'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shape:before {[m
[32m+[m[32m    content: '\f3eb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-spinner:before {[m
[32m+[m[32m    content: '\f3ec'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-ungroup:before {[m
[32m+[m[32m    content: '\f3ed'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-500px:before {[m
[32m+[m[32m    content: '\f3ee'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-8tracks:before {[m
[32m+[m[32m    content: '\f3ef'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-amazon:before {[m
[32m+[m[32m    content: '\f3f0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-blogger:before {[m
[32m+[m[32m    content: '\f3f1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-delicious:before {[m
[32m+[m[32m    content: '\f3f2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-disqus:before {[m
[32m+[m[32m    content: '\f3f3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flattr:before {[m
[32m+[m[32m    content: '\f3f4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flickr:before {[m
[32m+[m[32m    content: '\f3f5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-github-alt:before {[m
[32m+[m[32m    content: '\f3f6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-old:before {[m
[32m+[m[32m    content: '\f3f7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-linkedin:before {[m
[32m+[m[32m    content: '\f3f8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-odnoklassniki:before {[m
[32m+[m[32m    content: '\f3f9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-outlook:before {[m
[32m+[m[32m    content: '\f3fa'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-paypal-alt:before {[m
[32m+[m[32m    content: '\f3fb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pinterest:before {[m
[32m+[m[32m    content: '\f3fc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-playstation:before {[m
[32m+[m[32m    content: '\f3fd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-reddit:before {[m
[32m+[m[32m    content: '\f3fe'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-skype:before {[m
[32m+[m[32m    content: '\f3ff'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-slideshare:before {[m
[32m+[m[32m    content: '\f400'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-soundcloud:before {[m
[32m+[m[32m    content: '\f401'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tumblr:before {[m
[32m+[m[32m    content: '\f402'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-twitch:before {[m
[32m+[m[32m    content: '\f403'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-vimeo:before {[m
[32m+[m[32m    content: '\f404'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-whatsapp:before {[m
[32m+[m[32m    content: '\f405'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-xbox:before {[m
[32m+[m[32m    content: '\f406'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-yahoo:before {[m
[32m+[m[32m    content: '\f407'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-youtube-play:before {[m
[32m+[m[32m    content: '\f408'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-youtube:before {[m
[32m+[m[32m    content: '\f409'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-3d-rotation:before {[m
[32m+[m[32m    content: '\f101'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airplane-off:before {[m
[32m+[m[32m    content: '\f102'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airplane:before {[m
[32m+[m[32m    content: '\f103'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-album:before {[m
[32m+[m[32m    content: '\f104'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-archive:before {[m
[32m+[m[32m    content: '\f105'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment-account:before {[m
[32m+[m[32m    content: '\f106'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment-alert:before {[m
[32m+[m[32m    content: '\f107'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment-check:before {[m
[32m+[m[32m    content: '\f108'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment-o:before {[m
[32m+[m[32m    content: '\f109'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment-return:before {[m
[32m+[m[32m    content: '\f10a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment-returned:before {[m
[32m+[m[32m    content: '\f10b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-assignment:before {[m
[32m+[m[32m    content: '\f10c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-attachment-alt:before {[m
[32m+[m[32m    content: '\f10d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-attachment:before {[m
[32m+[m[32m    content: '\f10e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-audio:before {[m
[32m+[m[32m    content: '\f10f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-badge-check:before {[m
[32m+[m[32m    content: '\f110'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-balance-wallet:before {[m
[32m+[m[32m    content: '\f111'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-balance:before {[m
[32m+[m[32m    content: '\f112'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-battery-alert:before {[m
[32m+[m[32m    content: '\f113'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-battery-flash:before {[m
[32m+[m[32m    content: '\f114'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-battery-unknown:before {[m
[32m+[m[32m    content: '\f115'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-battery:before {[m
[32m+[m[32m    content: '\f116'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bike:before {[m
[32m+[m[32m    content: '\f117'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-block-alt:before {[m
[32m+[m[32m    content: '\f118'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-block:before {[m
[32m+[m[32m    content: '\f119'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-boat:before {[m
[32m+[m[32m    content: '\f11a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-book-image:before {[m
[32m+[m[32m    content: '\f11b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-book:before {[m
[32m+[m[32m    content: '\f11c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bookmark-outline:before {[m
[32m+[m[32m    content: '\f11d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bookmark:before {[m
[32m+[m[32m    content: '\f11e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brush:before {[m
[32m+[m[32m    content: '\f11f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bug:before {[m
[32m+[m[32m    content: '\f120'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bus:before {[m
[32m+[m[32m    content: '\f121'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cake:before {[m
[32m+[m[32m    content: '\f122'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-car-taxi:before {[m
[32m+[m[32m    content: '\f123'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-car-wash:before {[m
[32m+[m[32m    content: '\f124'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-car:before {[m
[32m+[m[32m    content: '\f125'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-giftcard:before {[m
[32m+[m[32m    content: '\f126'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-membership:before {[m
[32m+[m[32m    content: '\f127'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-travel:before {[m
[32m+[m[32m    content: '\f128'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card:before {[m
[32m+[m[32m    content: '\f129'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-case-check:before {[m
[32m+[m[32m    content: '\f12a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-case-download:before {[m
[32m+[m[32m    content: '\f12b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-case-play:before {[m
[32m+[m[32m    content: '\f12c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-case:before {[m
[32m+[m[32m    content: '\f12d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cast-connected:before {[m
[32m+[m[32m    content: '\f12e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cast:before {[m
[32m+[m[32m    content: '\f12f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-chart-donut:before {[m
[32m+[m[32m    content: '\f130'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-chart:before {[m
[32m+[m[32m    content: '\f131'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-city-alt:before {[m
[32m+[m[32m    content: '\f132'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-city:before {[m
[32m+[m[32m    content: '\f133'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-close-circle-o:before {[m
[32m+[m[32m    content: '\f134'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-close-circle:before {[m
[32m+[m[32m    content: '\f135'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-close:before {[m
[32m+[m[32m    content: '\f136'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cocktail:before {[m
[32m+[m[32m    content: '\f137'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-code-setting:before {[m
[32m+[m[32m    content: '\f138'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-code-smartphone:before {[m
[32m+[m[32m    content: '\f139'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-code:before {[m
[32m+[m[32m    content: '\f13a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-coffee:before {[m
[32m+[m[32m    content: '\f13b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-bookmark:before {[m
[32m+[m[32m    content: '\f13c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-case-play:before {[m
[32m+[m[32m    content: '\f13d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-folder-image:before {[m
[32m+[m[32m    content: '\f13e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-image-o:before {[m
[32m+[m[32m    content: '\f13f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-image:before {[m
[32m+[m[32m    content: '\f140'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-1:before {[m
[32m+[m[32m    content: '\f141'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-2:before {[m
[32m+[m[32m    content: '\f142'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-3:before {[m
[32m+[m[32m    content: '\f143'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-4:before {[m
[32m+[m[32m    content: '\f144'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-5:before {[m
[32m+[m[32m    content: '\f145'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-6:before {[m
[32m+[m[32m    content: '\f146'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-7:before {[m
[32m+[m[32m    content: '\f147'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-8:before {[m
[32m+[m[32m    content: '\f148'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-9-plus:before {[m
[32m+[m[32m    content: '\f149'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item-9:before {[m
[32m+[m[32m    content: '\f14a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-item:before {[m
[32m+[m[32m    content: '\f14b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-music:before {[m
[32m+[m[32m    content: '\f14c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-pdf:before {[m
[32m+[m[32m    content: '\f14d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-plus:before {[m
[32m+[m[32m    content: '\f14e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-speaker:before {[m
[32m+[m[32m    content: '\f14f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-text:before {[m
[32m+[m[32m    content: '\f150'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-video:before {[m
[32m+[m[32m    content: '\f151'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-compass:before {[m
[32m+[m[32m    content: '\f152'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cutlery:before {[m
[32m+[m[32m    content: '\f153'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-delete:before {[m
[32m+[m[32m    content: '\f154'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dialpad:before {[m
[32m+[m[32m    content: '\f155'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dns:before {[m
[32m+[m[32m    content: '\f156'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-drink:before {[m
[32m+[m[32m    content: '\f157'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-edit:before {[m
[32m+[m[32m    content: '\f158'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-email-open:before {[m
[32m+[m[32m    content: '\f159'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-email:before {[m
[32m+[m[32m    content: '\f15a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-eye-off:before {[m
[32m+[m[32m    content: '\f15b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-eye:before {[m
[32m+[m[32m    content: '\f15c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-eyedropper:before {[m
[32m+[m[32m    content: '\f15d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-favorite-outline:before {[m
[32m+[m[32m    content: '\f15e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-favorite:before {[m
[32m+[m[32m    content: '\f15f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-filter-list:before {[m
[32m+[m[32m    content: '\f160'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-fire:before {[m
[32m+[m[32m    content: '\f161'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flag:before {[m
[32m+[m[32m    content: '\f162'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flare:before {[m
[32m+[m[32m    content: '\f163'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flash-auto:before {[m
[32m+[m[32m    content: '\f164'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flash-off:before {[m
[32m+[m[32m    content: '\f165'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flash:before {[m
[32m+[m[32m    content: '\f166'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flip:before {[m
[32m+[m[32m    content: '\f167'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flower-alt:before {[m
[32m+[m[32m    content: '\f168'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flower:before {[m
[32m+[m[32m    content: '\f169'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-font:before {[m
[32m+[m[32m    content: '\f16a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-fullscreen-alt:before {[m
[32m+[m[32m    content: '\f16b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-fullscreen-exit:before {[m
[32m+[m[32m    content: '\f16c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-fullscreen:before {[m
[32m+[m[32m    content: '\f16d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-functions:before {[m
[32m+[m[32m    content: '\f16e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gas-station:before {[m
[32m+[m[32m    content: '\f16f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gesture:before {[m
[32m+[m[32m    content: '\f170'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-globe-alt:before {[m
[32m+[m[32m    content: '\f171'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-globe-lock:before {[m
[32m+[m[32m    content: '\f172'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-globe:before {[m
[32m+[m[32m    content: '\f173'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-graduation-cap:before {[m
[32m+[m[32m    content: '\f174'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-home:before {[m
[32m+[m[32m    content: '\f175'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hospital-alt:before {[m
[32m+[m[32m    content: '\f176'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hospital:before {[m
[32m+[m[32m    content: '\f177'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hotel:before {[m
[32m+[m[32m    content: '\f178'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hourglass-alt:before {[m
[32m+[m[32m    content: '\f179'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hourglass-outline:before {[m
[32m+[m[32m    content: '\f17a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hourglass:before {[m
[32m+[m[32m    content: '\f17b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-http:before {[m
[32m+[m[32m    content: '\f17c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-image-alt:before {[m
[32m+[m[32m    content: '\f17d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-image-o:before {[m
[32m+[m[32m    content: '\f17e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-image:before {[m
[32m+[m[32m    content: '\f17f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-inbox:before {[m
[32m+[m[32m    content: '\f180'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-invert-colors-off:before {[m
[32m+[m[32m    content: '\f181'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-invert-colors:before {[m
[32m+[m[32m    content: '\f182'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-key:before {[m
[32m+[m[32m    content: '\f183'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-label-alt-outline:before {[m
[32m+[m[32m    content: '\f184'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-label-alt:before {[m
[32m+[m[32m    content: '\f185'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-label-heart:before {[m
[32m+[m[32m    content: '\f186'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-label:before {[m
[32m+[m[32m    content: '\f187'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-labels:before {[m
[32m+[m[32m    content: '\f188'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-lamp:before {[m
[32m+[m[32m    content: '\f189'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-landscape:before {[m
[32m+[m[32m    content: '\f18a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-layers-off:before {[m
[32m+[m[32m    content: '\f18b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-layers:before {[m
[32m+[m[32m    content: '\f18c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-library:before {[m
[32m+[m[32m    content: '\f18d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-link:before {[m
[32m+[m[32m    content: '\f18e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-lock-open:before {[m
[32m+[m[32m    content: '\f18f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-lock-outline:before {[m
[32m+[m[32m    content: '\f190'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-lock:before {[m
[32m+[m[32m    content: '\f191'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mail-reply-all:before {[m
[32m+[m[32m    content: '\f192'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mail-reply:before {[m
[32m+[m[32m    content: '\f193'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mail-send:before {[m
[32m+[m[32m    content: '\f194'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mall:before {[m
[32m+[m[32m    content: '\f195'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-map:before {[m
[32m+[m[32m    content: '\f196'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-menu:before {[m
[32m+[m[32m    content: '\f197'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-money-box:before {[m
[32m+[m[32m    content: '\f198'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-money-off:before {[m
[32m+[m[32m    content: '\f199'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-money:before {[m
[32m+[m[32m    content: '\f19a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-more-vert:before {[m
[32m+[m[32m    content: '\f19b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-more:before {[m
[32m+[m[32m    content: '\f19c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-movie-alt:before {[m
[32m+[m[32m    content: '\f19d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-movie:before {[m
[32m+[m[32m    content: '\f19e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-nature-people:before {[m
[32m+[m[32m    content: '\f19f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-nature:before {[m
[32m+[m[32m    content: '\f1a0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-navigation:before {[m
[32m+[m[32m    content: '\f1a1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-open-in-browser:before {[m
[32m+[m[32m    content: '\f1a2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-open-in-new:before {[m
[32m+[m[32m    content: '\f1a3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-palette:before {[m
[32m+[m[32m    content: '\f1a4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-parking:before {[m
[32m+[m[32m    content: '\f1a5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pin-account:before {[m
[32m+[m[32m    content: '\f1a6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pin-assistant:before {[m
[32m+[m[32m    content: '\f1a7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pin-drop:before {[m
[32m+[m[32m    content: '\f1a8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pin-help:before {[m
[32m+[m[32m    content: '\f1a9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pin-off:before {[m
[32m+[m[32m    content: '\f1aa'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pin:before {[m
[32m+[m[32m    content: '\f1ab'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pizza:before {[m
[32m+[m[32m    content: '\f1ac'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plaster:before {[m
[32m+[m[32m    content: '\f1ad'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-power-setting:before {[m
[32m+[m[32m    content: '\f1ae'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-power:before {[m
[32m+[m[32m    content: '\f1af'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-print:before {[m
[32m+[m[32m    content: '\f1b0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-puzzle-piece:before {[m
[32m+[m[32m    content: '\f1b1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-quote:before {[m
[32m+[m[32m    content: '\f1b2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-railway:before {[m
[32m+[m[32m    content: '\f1b3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-receipt:before {[m
[32m+[m[32m    content: '\f1b4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-refresh-alt:before {[m
[32m+[m[32m    content: '\f1b5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-refresh-sync-alert:before {[m
[32m+[m[32m    content: '\f1b6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-refresh-sync-off:before {[m
[32m+[m[32m    content: '\f1b7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-refresh-sync:before {[m
[32m+[m[32m    content: '\f1b8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-refresh:before {[m
[32m+[m[32m    content: '\f1b9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-roller:before {[m
[32m+[m[32m    content: '\f1ba'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-ruler:before {[m
[32m+[m[32m    content: '\f1bb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-scissors:before {[m
[32m+[m[32m    content: '\f1bc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-screen-rotation-lock:before {[m
[32m+[m[32m    content: '\f1bd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-screen-rotation:before {[m
[32m+[m[32m    content: '\f1be'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-search-for:before {[m
[32m+[m[32m    content: '\f1bf'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-search-in-file:before {[m
[32m+[m[32m    content: '\f1c0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-search-in-page:before {[m
[32m+[m[32m    content: '\f1c1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-search-replace:before {[m
[32m+[m[32m    content: '\f1c2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-search:before {[m
[32m+[m[32m    content: '\f1c3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-seat:before {[m
[32m+[m[32m    content: '\f1c4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-settings-square:before {[m
[32m+[m[32m    content: '\f1c5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-settings:before {[m
[32m+[m[32m    content: '\f1c6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shield-check:before {[m
[32m+[m[32m    content: '\f1c7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shield-security:before {[m
[32m+[m[32m    content: '\f1c8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shopping-basket:before {[m
[32m+[m[32m    content: '\f1c9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shopping-cart-plus:before {[m
[32m+[m[32m    content: '\f1ca'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shopping-cart:before {[m
[32m+[m[32m    content: '\f1cb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sign-in:before {[m
[32m+[m[32m    content: '\f1cc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sort-amount-asc:before {[m
[32m+[m[32m    content: '\f1cd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sort-amount-desc:before {[m
[32m+[m[32m    content: '\f1ce'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sort-asc:before {[m
[32m+[m[32m    content: '\f1cf'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sort-desc:before {[m
[32m+[m[32m    content: '\f1d0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-spellcheck:before {[m
[32m+[m[32m    content: '\f1d1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-storage:before {[m
[32m+[m[32m    content: '\f1d2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-store-24:before {[m
[32m+[m[32m    content: '\f1d3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-store:before {[m
[32m+[m[32m    content: '\f1d4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-subway:before {[m
[32m+[m[32m    content: '\f1d5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sun:before {[m
[32m+[m[32m    content: '\f1d6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tab-unselected:before {[m
[32m+[m[32m    content: '\f1d7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tab:before {[m
[32m+[m[32m    content: '\f1d8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tag-close:before {[m
[32m+[m[32m    content: '\f1d9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tag-more:before {[m
[32m+[m[32m    content: '\f1da'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tag:before {[m
[32m+[m[32m    content: '\f1db'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-thumb-down:before {[m
[32m+[m[32m    content: '\f1dc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-thumb-up-down:before {[m
[32m+[m[32m    content: '\f1dd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-thumb-up:before {[m
[32m+[m[32m    content: '\f1de'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-ticket-star:before {[m
[32m+[m[32m    content: '\f1df'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-toll:before {[m
[32m+[m[32m    content: '\f1e0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-toys:before {[m
[32m+[m[32m    content: '\f1e1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-traffic:before {[m
[32m+[m[32m    content: '\f1e2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-translate:before {[m
[32m+[m[32m    content: '\f1e3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-triangle-down:before {[m
[32m+[m[32m    content: '\f1e4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-triangle-up:before {[m
[32m+[m[32m    content: '\f1e5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-truck:before {[m
[32m+[m[32m    content: '\f1e6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-turning-sign:before {[m
[32m+[m[32m    content: '\f1e7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wallpaper:before {[m
[32m+[m[32m    content: '\f1e8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-washing-machine:before {[m
[32m+[m[32m    content: '\f1e9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-window-maximize:before {[m
[32m+[m[32m    content: '\f1ea'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-window-minimize:before {[m
[32m+[m[32m    content: '\f1eb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-window-restore:before {[m
[32m+[m[32m    content: '\f1ec'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wrench:before {[m
[32m+[m[32m    content: '\f1ed'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-zoom-in:before {[m
[32m+[m[32m    content: '\f1ee'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-zoom-out:before {[m
[32m+[m[32m    content: '\f1ef'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alert-circle-o:before {[m
[32m+[m[32m    content: '\f1f0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alert-circle:before {[m
[32m+[m[32m    content: '\f1f1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alert-octagon:before {[m
[32m+[m[32m    content: '\f1f2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alert-polygon:before {[m
[32m+[m[32m    content: '\f1f3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alert-triangle:before {[m
[32m+[m[32m    content: '\f1f4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-help-outline:before {[m
[32m+[m[32m    content: '\f1f5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-help:before {[m
[32m+[m[32m    content: '\f1f6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-info-outline:before {[m
[32m+[m[32m    content: '\f1f7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-info:before {[m
[32m+[m[32m    content: '\f1f8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-notifications-active:before {[m
[32m+[m[32m    content: '\f1f9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-notifications-add:before {[m
[32m+[m[32m    content: '\f1fa'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-notifications-none:before {[m
[32m+[m[32m    content: '\f1fb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-notifications-off:before {[m
[32m+[m[32m    content: '\f1fc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-notifications-paused:before {[m
[32m+[m[32m    content: '\f1fd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-notifications:before {[m
[32m+[m[32m    content: '\f1fe'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-add:before {[m
[32m+[m[32m    content: '\f1ff'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-box-mail:before {[m
[32m+[m[32m    content: '\f200'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-box-o:before {[m
[32m+[m[32m    content: '\f201'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-box-phone:before {[m
[32m+[m[32m    content: '\f202'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-box:before {[m
[32m+[m[32m    content: '\f203'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-calendar:before {[m
[32m+[m[32m    content: '\f204'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-circle:before {[m
[32m+[m[32m    content: '\f205'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account-o:before {[m
[32m+[m[32m    content: '\f206'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-account:before {[m
[32m+[m[32m    content: '\f207'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-accounts-add:before {[m
[32m+[m[32m    content: '\f208'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-accounts-alt:before {[m
[32m+[m[32m    content: '\f209'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-accounts-list-alt:before {[m
[32m+[m[32m    content: '\f20a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-accounts-list:before {[m
[32m+[m[32m    content: '\f20b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-accounts-outline:before {[m
[32m+[m[32m    content: '\f20c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-accounts:before {[m
[32m+[m[32m    content: '\f20d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-face:before {[m
[32m+[m[32m    content: '\f20e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-female:before {[m
[32m+[m[32m    content: '\f20f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-male-alt:before {[m
[32m+[m[32m    content: '\f210'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-male-female:before {[m
[32m+[m[32m    content: '\f211'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-male:before {[m
[32m+[m[32m    content: '\f212'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mood-bad:before {[m
[32m+[m[32m    content: '\f213'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mood:before {[m
[32m+[m[32m    content: '\f214'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-run:before {[m
[32m+[m[32m    content: '\f215'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-walk:before {[m
[32m+[m[32m    content: '\f216'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-box:before {[m
[32m+[m[32m    content: '\f217'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-circle:before {[m
[32m+[m[32m    content: '\f218'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-done:before {[m
[32m+[m[32m    content: '\f219'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-download:before {[m
[32m+[m[32m    content: '\f21a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-off:before {[m
[32m+[m[32m    content: '\f21b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-outline-alt:before {[m
[32m+[m[32m    content: '\f21c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-outline:before {[m
[32m+[m[32m    content: '\f21d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud-upload:before {[m
[32m+[m[32m    content: '\f21e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cloud:before {[m
[32m+[m[32m    content: '\f21f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-download:before {[m
[32m+[m[32m    content: '\f220'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-file-plus:before {[m
[32m+[m[32m    content: '\f221'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-file-text:before {[m
[32m+[m[32m    content: '\f222'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-file:before {[m
[32m+[m[32m    content: '\f223'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-folder-outline:before {[m
[32m+[m[32m    content: '\f224'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-folder-person:before {[m
[32m+[m[32m    content: '\f225'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-folder-star-alt:before {[m
[32m+[m[32m    content: '\f226'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-folder-star:before {[m
[32m+[m[32m    content: '\f227'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-folder:before {[m
[32m+[m[32m    content: '\f228'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gif:before {[m
[32m+[m[32m    content: '\f229'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-upload:before {[m
[32m+[m[32m    content: '\f22a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-all:before {[m
[32m+[m[32m    content: '\f22b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-bottom:before {[m
[32m+[m[32m    content: '\f22c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-clear:before {[m
[32m+[m[32m    content: '\f22d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-color:before {[m
[32m+[m[32m    content: '\f22e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-horizontal:before {[m
[32m+[m[32m    content: '\f22f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-inner:before {[m
[32m+[m[32m    content: '\f230'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-left:before {[m
[32m+[m[32m    content: '\f231'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-outer:before {[m
[32m+[m[32m    content: '\f232'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-right:before {[m
[32m+[m[32m    content: '\f233'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-style:before {[m
[32m+[m[32m    content: '\f234'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-top:before {[m
[32m+[m[32m    content: '\f235'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-border-vertical:before {[m
[32m+[m[32m    content: '\f236'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-copy:before {[m
[32m+[m[32m    content: '\f237'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop:before {[m
[32m+[m[32m    content: '\f238'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-align-center:before {[m
[32m+[m[32m    content: '\f239'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-align-justify:before {[m
[32m+[m[32m    content: '\f23a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-align-left:before {[m
[32m+[m[32m    content: '\f23b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-align-right:before {[m
[32m+[m[32m    content: '\f23c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-bold:before {[m
[32m+[m[32m    content: '\f23d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-clear-all:before {[m
[32m+[m[32m    content: '\f23e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-clear:before {[m
[32m+[m[32m    content: '\f23f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-color-fill:before {[m
[32m+[m[32m    content: '\f240'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-color-reset:before {[m
[32m+[m[32m    content: '\f241'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-color-text:before {[m
[32m+[m[32m    content: '\f242'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-indent-decrease:before {[m
[32m+[m[32m    content: '\f243'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-indent-increase:before {[m
[32m+[m[32m    content: '\f244'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-italic:before {[m
[32m+[m[32m    content: '\f245'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-line-spacing:before {[m
[32m+[m[32m    content: '\f246'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-list-bulleted:before {[m
[32m+[m[32m    content: '\f247'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-list-numbered:before {[m
[32m+[m[32m    content: '\f248'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-ltr:before {[m
[32m+[m[32m    content: '\f249'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-rtl:before {[m
[32m+[m[32m    content: '\f24a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-size:before {[m
[32m+[m[32m    content: '\f24b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-strikethrough-s:before {[m
[32m+[m[32m    content: '\f24c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-strikethrough:before {[m
[32m+[m[32m    content: '\f24d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-subject:before {[m
[32m+[m[32m    content: '\f24e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-underlined:before {[m
[32m+[m[32m    content: '\f24f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-valign-bottom:before {[m
[32m+[m[32m    content: '\f250'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-valign-center:before {[m
[32m+[m[32m    content: '\f251'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-valign-top:before {[m
[32m+[m[32m    content: '\f252'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-redo:before {[m
[32m+[m[32m    content: '\f253'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-select-all:before {[m
[32m+[m[32m    content: '\f254'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-space-bar:before {[m
[32m+[m[32m    content: '\f255'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-text-format:before {[m
[32m+[m[32m    content: '\f256'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-transform:before {[m
[32m+[m[32m    content: '\f257'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-undo:before {[m
[32m+[m[32m    content: '\f258'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wrap-text:before {[m
[32m+[m[32m    content: '\f259'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-alert:before {[m
[32m+[m[32m    content: '\f25a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-alt-text:before {[m
[32m+[m[32m    content: '\f25b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-alt:before {[m
[32m+[m[32m    content: '\f25c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-edit:before {[m
[32m+[m[32m    content: '\f25d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-image:before {[m
[32m+[m[32m    content: '\f25e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-list:before {[m
[32m+[m[32m    content: '\f25f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-more:before {[m
[32m+[m[32m    content: '\f260'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-outline:before {[m
[32m+[m[32m    content: '\f261'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-text-alt:before {[m
[32m+[m[32m    content: '\f262'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-text:before {[m
[32m+[m[32m    content: '\f263'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-video:before {[m
[32m+[m[32m    content: '\f264'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment:before {[m
[32m+[m[32m    content: '\f265'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comments:before {[m
[32m+[m[32m    content: '\f266'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-check-all:before {[m
[32m+[m[32m    content: '\f267'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-check-circle-u:before {[m
[32m+[m[32m    content: '\f268'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-check-circle:before {[m
[32m+[m[32m    content: '\f269'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-check-square:before {[m
[32m+[m[32m    content: '\f26a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-check:before {[m
[32m+[m[32m    content: '\f26b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-circle-o:before {[m
[32m+[m[32m    content: '\f26c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-circle:before {[m
[32m+[m[32m    content: '\f26d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dot-circle-alt:before {[m
[32m+[m[32m    content: '\f26e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dot-circle:before {[m
[32m+[m[32m    content: '\f26f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-minus-circle-outline:before {[m
[32m+[m[32m    content: '\f270'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-minus-circle:before {[m
[32m+[m[32m    content: '\f271'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-minus-square:before {[m
[32m+[m[32m    content: '\f272'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-minus:before {[m
[32m+[m[32m    content: '\f273'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus-circle-o-duplicate:before {[m
[32m+[m[32m    content: '\f274'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus-circle-o:before {[m
[32m+[m[32m    content: '\f275'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus-circle:before {[m
[32m+[m[32m    content: '\f276'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus-square:before {[m
[32m+[m[32m    content: '\f277'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus:before {[m
[32m+[m[32m    content: '\f278'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-square-o:before {[m
[32m+[m[32m    content: '\f279'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-star-circle:before {[m
[32m+[m[32m    content: '\f27a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-star-half:before {[m
[32m+[m[32m    content: '\f27b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-star-outline:before {[m
[32m+[m[32m    content: '\f27c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-star:before {[m
[32m+[m[32m    content: '\f27d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bluetooth-connected:before {[m
[32m+[m[32m    content: '\f27e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bluetooth-off:before {[m
[32m+[m[32m    content: '\f27f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bluetooth-search:before {[m
[32m+[m[32m    content: '\f280'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bluetooth-setting:before {[m
[32m+[m[32m    content: '\f281'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-bluetooth:before {[m
[32m+[m[32m    content: '\f282'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-add:before {[m
[32m+[m[32m    content: '\f283'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-alt:before {[m
[32m+[m[32m    content: '\f284'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-bw:before {[m
[32m+[m[32m    content: '\f285'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-front:before {[m
[32m+[m[32m    content: '\f286'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-mic:before {[m
[32m+[m[32m    content: '\f287'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-party-mode:before {[m
[32m+[m[32m    content: '\f288'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-rear:before {[m
[32m+[m[32m    content: '\f289'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-roll:before {[m
[32m+[m[32m    content: '\f28a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-switch:before {[m
[32m+[m[32m    content: '\f28b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera:before {[m
[32m+[m[32m    content: '\f28c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-alert:before {[m
[32m+[m[32m    content: '\f28d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-off:before {[m
[32m+[m[32m    content: '\f28e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-sd:before {[m
[32m+[m[32m    content: '\f28f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-card-sim:before {[m
[32m+[m[32m    content: '\f290'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-desktop-mac:before {[m
[32m+[m[32m    content: '\f291'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-desktop-windows:before {[m
[32m+[m[32m    content: '\f292'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-device-hub:before {[m
[32m+[m[32m    content: '\f293'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-devices-off:before {[m
[32m+[m[32m    content: '\f294'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-devices:before {[m
[32m+[m[32m    content: '\f295'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dock:before {[m
[32m+[m[32m    content: '\f296'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-floppy:before {[m
[32m+[m[32m    content: '\f297'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gamepad:before {[m
[32m+[m[32m    content: '\f298'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gps-dot:before {[m
[32m+[m[32m    content: '\f299'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gps-off:before {[m
[32m+[m[32m    content: '\f29a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gps:before {[m
[32m+[m[32m    content: '\f29b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-headset-mic:before {[m
[32m+[m[32m    content: '\f29c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-headset:before {[m
[32m+[m[32m    content: '\f29d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-input-antenna:before {[m
[32m+[m[32m    content: '\f29e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-input-composite:before {[m
[32m+[m[32m    content: '\f29f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-input-hdmi:before {[m
[32m+[m[32m    content: '\f2a0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-input-power:before {[m
[32m+[m[32m    content: '\f2a1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-input-svideo:before {[m
[32m+[m[32m    content: '\f2a2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-keyboard-hide:before {[m
[32m+[m[32m    content: '\f2a3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-keyboard:before {[m
[32m+[m[32m    content: '\f2a4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-laptop-chromebook:before {[m
[32m+[m[32m    content: '\f2a5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-laptop-mac:before {[m
[32m+[m[32m    content: '\f2a6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-laptop:before {[m
[32m+[m[32m    content: '\f2a7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mic-off:before {[m
[32m+[m[32m    content: '\f2a8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mic-outline:before {[m
[32m+[m[32m    content: '\f2a9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mic-setting:before {[m
[32m+[m[32m    content: '\f2aa'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mic:before {[m
[32m+[m[32m    content: '\f2ab'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-mouse:before {[m
[32m+[m[32m    content: '\f2ac'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-alert:before {[m
[32m+[m[32m    content: '\f2ad'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-locked:before {[m
[32m+[m[32m    content: '\f2ae'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-off:before {[m
[32m+[m[32m    content: '\f2af'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-outline:before {[m
[32m+[m[32m    content: '\f2b0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-setting:before {[m
[32m+[m[32m    content: '\f2b1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network:before {[m
[32m+[m[32m    content: '\f2b2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-bluetooth:before {[m
[32m+[m[32m    content: '\f2b3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-end:before {[m
[32m+[m[32m    content: '\f2b4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-forwarded:before {[m
[32m+[m[32m    content: '\f2b5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-in-talk:before {[m
[32m+[m[32m    content: '\f2b6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-locked:before {[m
[32m+[m[32m    content: '\f2b7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-missed:before {[m
[32m+[m[32m    content: '\f2b8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-msg:before {[m
[32m+[m[32m    content: '\f2b9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-paused:before {[m
[32m+[m[32m    content: '\f2ba'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-ring:before {[m
[32m+[m[32m    content: '\f2bb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-setting:before {[m
[32m+[m[32m    content: '\f2bc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone-sip:before {[m
[32m+[m[32m    content: '\f2bd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-phone:before {[m
[32m+[m[32m    content: '\f2be'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-portable-wifi-changes:before {[m
[32m+[m[32m    content: '\f2bf'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-portable-wifi-off:before {[m
[32m+[m[32m    content: '\f2c0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-portable-wifi:before {[m
[32m+[m[32m    content: '\f2c1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-radio:before {[m
[32m+[m[32m    content: '\f2c2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-reader:before {[m
[32m+[m[32m    content: '\f2c3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-remote-control-alt:before {[m
[32m+[m[32m    content: '\f2c4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-remote-control:before {[m
[32m+[m[32m    content: '\f2c5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-router:before {[m
[32m+[m[32m    content: '\f2c6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-scanner:before {[m
[32m+[m[32m    content: '\f2c7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-android:before {[m
[32m+[m[32m    content: '\f2c8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-download:before {[m
[32m+[m[32m    content: '\f2c9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-erase:before {[m
[32m+[m[32m    content: '\f2ca'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-info:before {[m
[32m+[m[32m    content: '\f2cb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-iphone:before {[m
[32m+[m[32m    content: '\f2cc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-landscape-lock:before {[m
[32m+[m[32m    content: '\f2cd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-landscape:before {[m
[32m+[m[32m    content: '\f2ce'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-lock:before {[m
[32m+[m[32m    content: '\f2cf'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-portrait-lock:before {[m
[32m+[m[32m    content: '\f2d0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-ring:before {[m
[32m+[m[32m    content: '\f2d1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-setting:before {[m
[32m+[m[32m    content: '\f2d2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-setup:before {[m
[32m+[m[32m    content: '\f2d3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone:before {[m
[32m+[m[32m    content: '\f2d4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-speaker:before {[m
[32m+[m[32m    content: '\f2d5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tablet-android:before {[m
[32m+[m[32m    content: '\f2d6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tablet-mac:before {[m
[32m+[m[32m    content: '\f2d7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tablet:before {[m
[32m+[m[32m    content: '\f2d8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tv-alt-play:before {[m
[32m+[m[32m    content: '\f2d9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tv-list:before {[m
[32m+[m[32m    content: '\f2da'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tv-play:before {[m
[32m+[m[32m    content: '\f2db'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tv:before {[m
[32m+[m[32m    content: '\f2dc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-usb:before {[m
[32m+[m[32m    content: '\f2dd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-videocam-off:before {[m
[32m+[m[32m    content: '\f2de'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-videocam-switch:before {[m
[32m+[m[32m    content: '\f2df'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-videocam:before {[m
[32m+[m[32m    content: '\f2e0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-watch:before {[m
[32m+[m[32m    content: '\f2e1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi-alt-2:before {[m
[32m+[m[32m    content: '\f2e2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi-alt:before {[m
[32m+[m[32m    content: '\f2e3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi-info:before {[m
[32m+[m[32m    content: '\f2e4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi-lock:before {[m
[32m+[m[32m    content: '\f2e5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi-off:before {[m
[32m+[m[32m    content: '\f2e6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi-outline:before {[m
[32m+[m[32m    content: '\f2e7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wifi:before {[m
[32m+[m[32m    content: '\f2e8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-left-bottom:before {[m
[32m+[m[32m    content: '\f2e9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-left:before {[m
[32m+[m[32m    content: '\f2ea'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-merge:before {[m
[32m+[m[32m    content: '\f2eb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-missed:before {[m
[32m+[m[32m    content: '\f2ec'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-right-top:before {[m
[32m+[m[32m    content: '\f2ed'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-right:before {[m
[32m+[m[32m    content: '\f2ee'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-split:before {[m
[32m+[m[32m    content: '\f2ef'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrows:before {[m
[32m+[m[32m    content: '\f2f0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-down-circle:before {[m
[32m+[m[32m    content: '\f2f1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-down:before {[m
[32m+[m[32m    content: '\f2f2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-left-circle:before {[m
[32m+[m[32m    content: '\f2f3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-left:before {[m
[32m+[m[32m    content: '\f2f4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-right-circle:before {[m
[32m+[m[32m    content: '\f2f5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-right:before {[m
[32m+[m[32m    content: '\f2f6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-up-circle:before {[m
[32m+[m[32m    content: '\f2f7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-caret-up:before {[m
[32m+[m[32m    content: '\f2f8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-chevron-down:before {[m
[32m+[m[32m    content: '\f2f9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-chevron-left:before {[m
[32m+[m[32m    content: '\f2fa'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-chevron-right:before {[m
[32m+[m[32m    content: '\f2fb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-chevron-up:before {[m
[32m+[m[32m    content: '\f2fc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-forward:before {[m
[32m+[m[32m    content: '\f2fd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-long-arrow-down:before {[m
[32m+[m[32m    content: '\f2fe'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-long-arrow-left:before {[m
[32m+[m[32m    content: '\f2ff'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-long-arrow-return:before {[m
[32m+[m[32m    content: '\f300'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-long-arrow-right:before {[m
[32m+[m[32m    content: '\f301'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-long-arrow-tab:before {[m
[32m+[m[32m    content: '\f302'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-long-arrow-up:before {[m
[32m+[m[32m    content: '\f303'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-rotate-ccw:before {[m
[32m+[m[32m    content: '\f304'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-rotate-cw:before {[m
[32m+[m[32m    content: '\f305'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-rotate-left:before {[m
[32m+[m[32m    content: '\f306'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-rotate-right:before {[m
[32m+[m[32m    content: '\f307'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-square-down:before {[m
[32m+[m[32m    content: '\f308'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-square-right:before {[m
[32m+[m[32m    content: '\f309'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-swap-alt:before {[m
[32m+[m[32m    content: '\f30a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-swap-vertical-circle:before {[m
[32m+[m[32m    content: '\f30b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-swap-vertical:before {[m
[32m+[m[32m    content: '\f30c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-swap:before {[m
[32m+[m[32m    content: '\f30d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-trending-down:before {[m
[32m+[m[32m    content: '\f30e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-trending-flat:before {[m
[32m+[m[32m    content: '\f30f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-trending-up:before {[m
[32m+[m[32m    content: '\f310'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-unfold-less:before {[m
[32m+[m[32m    content: '\f311'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-unfold-more:before {[m
[32m+[m[32m    content: '\f312'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-apps:before {[m
[32m+[m[32m    content: '\f313'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-grid-off:before {[m
[32m+[m[32m    content: '\f314'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-grid:before {[m
[32m+[m[32m    content: '\f315'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-agenda:before {[m
[32m+[m[32m    content: '\f316'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-array:before {[m
[32m+[m[32m    content: '\f317'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-carousel:before {[m
[32m+[m[32m    content: '\f318'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-column:before {[m
[32m+[m[32m    content: '\f319'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-comfy:before {[m
[32m+[m[32m    content: '\f31a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-compact:before {[m
[32m+[m[32m    content: '\f31b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-dashboard:before {[m
[32m+[m[32m    content: '\f31c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-day:before {[m
[32m+[m[32m    content: '\f31d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-headline:before {[m
[32m+[m[32m    content: '\f31e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-list-alt:before {[m
[32m+[m[32m    content: '\f31f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-list:before {[m
[32m+[m[32m    content: '\f320'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-module:before {[m
[32m+[m[32m    content: '\f321'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-quilt:before {[m
[32m+[m[32m    content: '\f322'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-stream:before {[m
[32m+[m[32m    content: '\f323'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-subtitles:before {[m
[32m+[m[32m    content: '\f324'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-toc:before {[m
[32m+[m[32m    content: '\f325'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-web:before {[m
[32m+[m[32m    content: '\f326'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-view-week:before {[m
[32m+[m[32m    content: '\f327'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-widgets:before {[m
[32m+[m[32m    content: '\f328'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alarm-check:before {[m
[32m+[m[32m    content: '\f329'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alarm-off:before {[m
[32m+[m[32m    content: '\f32a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alarm-plus:before {[m
[32m+[m[32m    content: '\f32b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alarm-snooze:before {[m
[32m+[m[32m    content: '\f32c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alarm:before {[m
[32m+[m[32m    content: '\f32d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-calendar-alt:before {[m
[32m+[m[32m    content: '\f32e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-calendar-check:before {[m
[32m+[m[32m    content: '\f32f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-calendar-close:before {[m
[32m+[m[32m    content: '\f330'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-calendar-note:before {[m
[32m+[m[32m    content: '\f331'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-calendar:before {[m
[32m+[m[32m    content: '\f332'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-time-countdown:before {[m
[32m+[m[32m    content: '\f333'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-time-interval:before {[m
[32m+[m[32m    content: '\f334'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-time-restore-setting:before {[m
[32m+[m[32m    content: '\f335'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-time-restore:before {[m
[32m+[m[32m    content: '\f336'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-time:before {[m
[32m+[m[32m    content: '\f337'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-timer-off:before {[m
[32m+[m[32m    content: '\f338'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-timer:before {[m
[32m+[m[32m    content: '\f339'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-android-alt:before {[m
[32m+[m[32m    content: '\f33a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-android:before {[m
[32m+[m[32m    content: '\f33b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-apple:before {[m
[32m+[m[32m    content: '\f33c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-behance:before {[m
[32m+[m[32m    content: '\f33d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-codepen:before {[m
[32m+[m[32m    content: '\f33e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dribbble:before {[m
[32m+[m[32m    content: '\f33f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dropbox:before {[m
[32m+[m[32m    content: '\f340'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-evernote:before {[m
[32m+[m[32m    content: '\f341'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-facebook-box:before {[m
[32m+[m[32m    content: '\f342'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-facebook:before {[m
[32m+[m[32m    content: '\f343'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-github-box:before {[m
[32m+[m[32m    content: '\f344'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-github:before {[m
[32m+[m[32m    content: '\f345'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-drive:before {[m
[32m+[m[32m    content: '\f346'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-earth:before {[m
[32m+[m[32m    content: '\f347'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-glass:before {[m
[32m+[m[32m    content: '\f348'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-maps:before {[m
[32m+[m[32m    content: '\f349'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-pages:before {[m
[32m+[m[32m    content: '\f34a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-play:before {[m
[32m+[m[32m    content: '\f34b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-plus-box:before {[m
[32m+[m[32m    content: '\f34c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-plus:before {[m
[32m+[m[32m    content: '\f34d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google:before {[m
[32m+[m[32m    content: '\f34e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-instagram:before {[m
[32m+[m[32m    content: '\f34f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-language-css3:before {[m
[32m+[m[32m    content: '\f350'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-language-html5:before {[m
[32m+[m[32m    content: '\f351'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-language-javascript:before {[m
[32m+[m[32m    content: '\f352'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-language-python-alt:before {[m
[32m+[m[32m    content: '\f353'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-language-python:before {[m
[32m+[m[32m    content: '\f354'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-lastfm:before {[m
[32m+[m[32m    content: '\f355'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-linkedin-box:before {[m
[32m+[m[32m    content: '\f356'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-paypal:before {[m
[32m+[m[32m    content: '\f357'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pinterest-box:before {[m
[32m+[m[32m    content: '\f358'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pocket:before {[m
[32m+[m[32m    content: '\f359'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-polymer:before {[m
[32m+[m[32m    content: '\f35a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-share:before {[m
[32m+[m[32m    content: '\f35b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-stackoverflow:before {[m
[32m+[m[32m    content: '\f35c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-steam-square:before {[m
[32m+[m[32m    content: '\f35d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-steam:before {[m
[32m+[m[32m    content: '\f35e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-twitter-box:before {[m
[32m+[m[32m    content: '\f35f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-twitter:before {[m
[32m+[m[32m    content: '\f360'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-vk:before {[m
[32m+[m[32m    content: '\f361'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wikipedia:before {[m
[32m+[m[32m    content: '\f362'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-windows:before {[m
[32m+[m[32m    content: '\f363'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-aspect-ratio-alt:before {[m
[32m+[m[32m    content: '\f364'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-aspect-ratio:before {[m
[32m+[m[32m    content: '\f365'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-blur-circular:before {[m
[32m+[m[32m    content: '\f366'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-blur-linear:before {[m
[32m+[m[32m    content: '\f367'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-blur-off:before {[m
[32m+[m[32m    content: '\f368'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-blur:before {[m
[32m+[m[32m    content: '\f369'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-2:before {[m
[32m+[m[32m    content: '\f36a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-3:before {[m
[32m+[m[32m    content: '\f36b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-4:before {[m
[32m+[m[32m    content: '\f36c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-5:before {[m
[32m+[m[32m    content: '\f36d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-6:before {[m
[32m+[m[32m    content: '\f36e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-7:before {[m
[32m+[m[32m    content: '\f36f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-auto:before {[m
[32m+[m[32m    content: '\f370'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-setting:before {[m
[32m+[m[32m    content: '\f371'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-broken-image:before {[m
[32m+[m[32m    content: '\f372'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-center-focus-strong:before {[m
[32m+[m[32m    content: '\f373'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-center-focus-weak:before {[m
[32m+[m[32m    content: '\f374'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-compare:before {[m
[32m+[m[32m    content: '\f375'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-16-9:before {[m
[32m+[m[32m    content: '\f376'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-3-2:before {[m
[32m+[m[32m    content: '\f377'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-5-4:before {[m
[32m+[m[32m    content: '\f378'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-7-5:before {[m
[32m+[m[32m    content: '\f379'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-din:before {[m
[32m+[m[32m    content: '\f37a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-free:before {[m
[32m+[m[32m    content: '\f37b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-landscape:before {[m
[32m+[m[32m    content: '\f37c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-portrait:before {[m
[32m+[m[32m    content: '\f37d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-square:before {[m
[32m+[m[32m    content: '\f37e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-exposure-alt:before {[m
[32m+[m[32m    content: '\f37f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-exposure:before {[m
[32m+[m[32m    content: '\f380'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-filter-b-and-w:before {[m
[32m+[m[32m    content: '\f381'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-filter-center-focus:before {[m
[32m+[m[32m    content: '\f382'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-filter-frames:before {[m
[32m+[m[32m    content: '\f383'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-filter-tilt-shift:before {[m
[32m+[m[32m    content: '\f384'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-gradient:before {[m
[32m+[m[32m    content: '\f385'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-grain:before {[m
[32m+[m[32m    content: '\f386'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-graphic-eq:before {[m
[32m+[m[32m    content: '\f387'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hdr-off:before {[m
[32m+[m[32m    content: '\f388'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hdr-strong:before {[m
[32m+[m[32m    content: '\f389'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hdr-weak:before {[m
[32m+[m[32m    content: '\f38a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hdr:before {[m
[32m+[m[32m    content: '\f38b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-iridescent:before {[m
[32m+[m[32m    content: '\f38c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-leak-off:before {[m
[32m+[m[32m    content: '\f38d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-leak:before {[m
[32m+[m[32m    content: '\f38e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-looks:before {[m
[32m+[m[32m    content: '\f38f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-loupe:before {[m
[32m+[m[32m    content: '\f390'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-panorama-horizontal:before {[m
[32m+[m[32m    content: '\f391'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-panorama-vertical:before {[m
[32m+[m[32m    content: '\f392'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-panorama-wide-angle:before {[m
[32m+[m[32m    content: '\f393'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-photo-size-select-large:before {[m
[32m+[m[32m    content: '\f394'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-photo-size-select-small:before {[m
[32m+[m[32m    content: '\f395'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-picture-in-picture:before {[m
[32m+[m[32m    content: '\f396'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-slideshow:before {[m
[32m+[m[32m    content: '\f397'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-texture:before {[m
[32m+[m[32m    content: '\f398'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tonality:before {[m
[32m+[m[32m    content: '\f399'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-vignette:before {[m
[32m+[m[32m    content: '\f39a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wb-auto:before {[m
[32m+[m[32m    content: '\f39b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-eject-alt:before {[m
[32m+[m[32m    content: '\f39c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-eject:before {[m
[32m+[m[32m    content: '\f39d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-equalizer:before {[m
[32m+[m[32m    content: '\f39e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-fast-forward:before {[m
[32m+[m[32m    content: '\f39f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-fast-rewind:before {[m
[32m+[m[32m    content: '\f3a0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-forward-10:before {[m
[32m+[m[32m    content: '\f3a1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-forward-30:before {[m
[32m+[m[32m    content: '\f3a2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-forward-5:before {[m
[32m+[m[32m    content: '\f3a3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hearing:before {[m
[32m+[m[32m    content: '\f3a4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pause-circle-outline:before {[m
[32m+[m[32m    content: '\f3a5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pause-circle:before {[m
[32m+[m[32m    content: '\f3a6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pause:before {[m
[32m+[m[32m    content: '\f3a7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-play-circle-outline:before {[m
[32m+[m[32m    content: '\f3a8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-play-circle:before {[m
[32m+[m[32m    content: '\f3a9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-play:before {[m
[32m+[m[32m    content: '\f3aa'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-playlist-audio:before {[m
[32m+[m[32m    content: '\f3ab'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-playlist-plus:before {[m
[32m+[m[32m    content: '\f3ac'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-repeat-one:before {[m
[32m+[m[32m    content: '\f3ad'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-repeat:before {[m
[32m+[m[32m    content: '\f3ae'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-replay-10:before {[m
[32m+[m[32m    content: '\f3af'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-replay-30:before {[m
[32m+[m[32m    content: '\f3b0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-replay-5:before {[m
[32m+[m[32m    content: '\f3b1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-replay:before {[m
[32m+[m[32m    content: '\f3b2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shuffle:before {[m
[32m+[m[32m    content: '\f3b3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-skip-next:before {[m
[32m+[m[32m    content: '\f3b4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-skip-previous:before {[m
[32m+[m[32m    content: '\f3b5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-stop:before {[m
[32m+[m[32m    content: '\f3b6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-surround-sound:before {[m
[32m+[m[32m    content: '\f3b7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tune:before {[m
[32m+[m[32m    content: '\f3b8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-volume-down:before {[m
[32m+[m[32m    content: '\f3b9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-volume-mute:before {[m
[32m+[m[32m    content: '\f3ba'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-volume-off:before {[m
[32m+[m[32m    content: '\f3bb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-volume-up:before {[m
[32m+[m[32m    content: '\f3bc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-n-1-square:before {[m
[32m+[m[32m    content: '\f3bd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-n-2-square:before {[m
[32m+[m[32m    content: '\f3be'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-n-3-square:before {[m
[32m+[m[32m    content: '\f3bf'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-n-4-square:before {[m
[32m+[m[32m    content: '\f3c0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-n-5-square:before {[m
[32m+[m[32m    content: '\f3c1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-n-6-square:before {[m
[32m+[m[32m    content: '\f3c2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-neg-1:before {[m
[32m+[m[32m    content: '\f3c3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-neg-2:before {[m
[32m+[m[32m    content: '\f3c4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus-1:before {[m
[32m+[m[32m    content: '\f3c5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus-2:before {[m
[32m+[m[32m    content: '\f3c6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sec-10:before {[m
[32m+[m[32m    content: '\f3c7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sec-3:before {[m
[32m+[m[32m    content: '\f3c8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-zero:before {[m
[32m+[m[32m    content: '\f3c9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-flat-angled:before {[m
[32m+[m[32m    content: '\f3ca'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-flat:before {[m
[32m+[m[32m    content: '\f3cb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-individual-suite:before {[m
[32m+[m[32m    content: '\f3cc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-legroom-extra:before {[m
[32m+[m[32m    content: '\f3cd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-legroom-normal:before {[m
[32m+[m[32m    content: '\f3ce'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-legroom-reduced:before {[m
[32m+[m[32m    content: '\f3cf'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-recline-extra:before {[m
[32m+[m[32m    content: '\f3d0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airline-seat-recline-normal:before {[m
[32m+[m[32m    content: '\f3d1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airplay:before {[m
[32m+[m[32m    content: '\f3d2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-closed-caption:before {[m
[32m+[m[32m    content: '\f3d3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-confirmation-number:before {[m
[32m+[m[32m    content: '\f3d4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-developer-board:before {[m
[32m+[m[32m    content: '\f3d5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-disc-full:before {[m
[32m+[m[32m    content: '\f3d6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-explicit:before {[m
[32m+[m[32m    content: '\f3d7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flight-land:before {[m
[32m+[m[32m    content: '\f3d8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flight-takeoff:before {[m
[32m+[m[32m    content: '\f3d9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flip-to-back:before {[m
[32m+[m[32m    content: '\f3da'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flip-to-front:before {[m
[32m+[m[32m    content: '\f3db'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-group-work:before {[m
[32m+[m[32m    content: '\f3dc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hd:before {[m
[32m+[m[32m    content: '\f3dd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-hq:before {[m
[32m+[m[32m    content: '\f3de'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-markunread-mailbox:before {[m
[32m+[m[32m    content: '\f3df'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-memory:before {[m
[32m+[m[32m    content: '\f3e0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-nfc:before {[m
[32m+[m[32m    content: '\f3e1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-play-for-work:before {[m
[32m+[m[32m    content: '\f3e2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-power-input:before {[m
[32m+[m[32m    content: '\f3e3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-present-to-all:before {[m
[32m+[m[32m    content: '\f3e4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-satellite:before {[m
[32m+[m[32m    content: '\f3e5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tap-and-play:before {[m
[32m+[m[32m    content: '\f3e6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-vibration:before {[m
[32m+[m[32m    content: '\f3e7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-voicemail:before {[m
[32m+[m[32m    content: '\f3e8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-group:before {[m
[32m+[m[32m    content: '\f3e9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-rss:before {[m
[32m+[m[32m    content: '\f3ea'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shape:before {[m
[32m+[m[32m    content: '\f3eb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-spinner:before {[m
[32m+[m[32m    content: '\f3ec'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-ungroup:before {[m
[32m+[m[32m    content: '\f3ed'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-500px:before {[m
[32m+[m[32m    content: '\f3ee'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-8tracks:before {[m
[32m+[m[32m    content: '\f3ef'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-amazon:before {[m
[32m+[m[32m    content: '\f3f0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-blogger:before {[m
[32m+[m[32m    content: '\f3f1'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-delicious:before {[m
[32m+[m[32m    content: '\f3f2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-disqus:before {[m
[32m+[m[32m    content: '\f3f3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flattr:before {[m
[32m+[m[32m    content: '\f3f4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-flickr:before {[m
[32m+[m[32m    content: '\f3f5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-github-alt:before {[m
[32m+[m[32m    content: '\f3f6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-google-old:before {[m
[32m+[m[32m    content: '\f3f7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-linkedin:before {[m
[32m+[m[32m    content: '\f3f8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-odnoklassniki:before {[m
[32m+[m[32m    content: '\f3f9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-outlook:before {[m
[32m+[m[32m    content: '\f3fa'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-paypal-alt:before {[m
[32m+[m[32m    content: '\f3fb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pinterest:before {[m
[32m+[m[32m    content: '\f3fc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-playstation:before {[m
[32m+[m[32m    content: '\f3fd'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-reddit:before {[m
[32m+[m[32m    content: '\f3fe'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-skype:before {[m
[32m+[m[32m    content: '\f3ff'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-slideshare:before {[m
[32m+[m[32m    content: '\f400'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-soundcloud:before {[m
[32m+[m[32m    content: '\f401'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tumblr:before {[m
[32m+[m[32m    content: '\f402'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-twitch:before {[m
[32m+[m[32m    content: '\f403'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-vimeo:before {[m
[32m+[m[32m    content: '\f404'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-whatsapp:before {[m
[32m+[m[32m    content: '\f405'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-xbox:before {[m
[32m+[m[32m    content: '\f406'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-yahoo:before {[m
[32m+[m[32m    content: '\f407'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-youtube-play:before {[m
[32m+[m[32m    content: '\f408'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-youtube:before {[m
[32m+[m[32m    content: '\f409'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-import-export:before {[m
[32m+[m[32m    content: '\f30c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-swap-vertical-:before {[m
[32m+[m[32m    content: '\f30c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airplanemode-inactive:before {[m
[32m+[m[32m    content: '\f102'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-airplanemode-active:before {[m
[32m+[m[32m    content: '\f103'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-rate-review:before {[m
[32m+[m[32m    content: '\f103'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-sign:before {[m
[32m+[m[32m    content: '\f25a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-warning:before {[m
[32m+[m[32m    content: '\f2ad'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-shopping-cart-add:before {[m
[32m+[m[32m    content: '\f1ca'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-file-add:before {[m
[32m+[m[32m    content: '\f221'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-wifi-scan:before {[m
[32m+[m[32m    content: '\f2e4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-collection-add:before {[m
[32m+[m[32m    content: '\f14e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-playlist-add:before {[m
[32m+[m[32m    content: '\f3ac'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-queue-music:before {[m
[32m+[m[32m    content: '\f3ab'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-plus-box:before {[m
[32m+[m[32m    content: '\f277'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-tag-backspace:before {[m
[32m+[m[32m    content: '\f1d9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-alarm-add:before {[m
[32m+[m[32m    content: '\f32b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-battery-charging:before {[m
[32m+[m[32m    content: '\f114'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-daydream-setting:before {[m
[32m+[m[32m    content: '\f217'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-more-horiz:before {[m
[32m+[m[32m    content: '\f19c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-book-photo:before {[m
[32m+[m[32m    content: '\f11b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-incandescent:before {[m
[32m+[m[32m    content: '\f189'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-wb-iridescent:before {[m
[32m+[m[32m    content: '\f38c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-calendar-remove:before {[m
[32m+[m[32m    content: '\f330'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-refresh-sync-disabled:before {[m
[32m+[m[32m    content: '\f1b7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-refresh-sync-problem:before {[m
[32m+[m[32m    content: '\f1b6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-crop-original:before {[m
[32m+[m[32m    content: '\f17e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-power-off:before {[m
[32m+[m[32m    content: '\f1af'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-power-off-setting:before {[m
[32m+[m[32m    content: '\f1ae'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-leak-remove:before {[m
[32m+[m[32m    content: '\f38d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-star-border:before {[m
[32m+[m[32m    content: '\f27c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-low:before {[m
[32m+[m[32m    content: '\f36d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-medium:before {[m
[32m+[m[32m    content: '\f36e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-brightness-high:before {[m
[32m+[m[32m    content: '\f36f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-portrait:before {[m
[32m+[m[32m    content: '\f2d4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-live-tv:before {[m
[32m+[m[32m    content: '\f2d9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-textdirection-l-to-r:before {[m
[32m+[m[32m    content: '\f249'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-textdirection-r-to-l:before {[m
[32m+[m[32m    content: '\f24a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-back:before {[m
[32m+[m[32m    content: '\f2ea'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-forward:before {[m
[32m+[m[32m    content: '\f2ee'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-in:before {[m
[32m+[m[32m    content: '\f2e9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-arrow-out:before {[m
[32m+[m[32m    content: '\f2ed'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-rotate-90-degrees-ccw:before {[m
[32m+[m[32m    content: '\f304'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-adb:before {[m
[32m+[m[32m    content: '\f33a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-wifi:before {[m
[32m+[m[32m    content: '\f2e8'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-wifi-alt:before {[m
[32m+[m[32m    content: '\f2e3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-wifi-lock:before {[m
[32m+[m[32m    content: '\f2e5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-wifi-off:before {[m
[32m+[m[32m    content: '\f2e6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-wifi-outline:before {[m
[32m+[m[32m    content: '\f2e7'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-network-wifi-info:before {[m
[32m+[m[32m    content: '\f2e4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-layers-clear:before {[m
[32m+[m[32m    content: '\f18b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-colorize:before {[m
[32m+[m[32m    content: '\f15d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-paint:before {[m
[32m+[m[32m    content: '\f1ba'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-format-quote:before {[m
[32m+[m[32m    content: '\f1b2'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-camera-monochrome-photos:before {[m
[32m+[m[32m    content: '\f285'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sort-by-alpha:before {[m
[32m+[m[32m    content: '\f1cf'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-folder-shared:before {[m
[32m+[m[32m    content: '\f225'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-folder-special:before {[m
[32m+[m[32m    content: '\f226'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-comment-dots:before {[m
[32m+[m[32m    content: '\f260'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-reorder:before {[m
[32m+[m[32m    content: '\f31e'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-dehaze:before {[m
[32m+[m[32m    content: '\f197'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-sort:before {[m
[32m+[m[32m    content: '\f1ce'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-pages:before {[m
[32m+[m[32m    content: '\f34a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-stack-overflow:before {[m
[32m+[m[32m    content: '\f35c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-calendar-account:before {[m
[32m+[m[32m    content: '\f204'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-paste:before {[m
[32m+[m[32m    content: '\f109'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-cut:before {[m
[32m+[m[32m    content: '\f1bc'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-save:before {[m
[32m+[m[32m    content: '\f297'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-smartphone-code:before {[m
[32m+[m[32m    content: '\f139'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-directions-bike:before {[m
[32m+[m[32m    content: '\f117'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-directions-boat:before {[m
[32m+[m[32m    content: '\f11a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-directions-bus:before {[m
[32m+[m[32m    content: '\f121'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-directions-car:before {[m
[32m+[m[32m    content: '\f125'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-directions-railway:before {[m
[32m+[m[32m    content: '\f1b3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-directions-run:before {[m
[32m+[m[32m    content: '\f215'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-directions-subway:before {[m
[32m+[m[32m    content: '\f1d5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-directions-walk:before {[m
[32m+[m[32m    content: '\f216'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-hotel:before {[m
[32m+[m[32m    content: '\f178'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-activity:before {[m
[32m+[m[32m    content: '\f1df'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-play:before {[m
[32m+[m[32m    content: '\f1df'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-airport:before {[m
[32m+[m[32m    content: '\f103'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-atm:before {[m
[32m+[m[32m    content: '\f198'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-bar:before {[m
[32m+[m[32m    content: '\f137'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-cafe:before {[m
[32m+[m[32m    content: '\f13b'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-car-wash:before {[m
[32m+[m[32m    content: '\f124'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-convenience-store:before {[m
[32m+[m[32m    content: '\f1d3'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-dining:before {[m
[32m+[m[32m    content: '\f153'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-drink:before {[m
[32m+[m[32m    content: '\f157'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-florist:before {[m
[32m+[m[32m    content: '\f168'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-gas-station:before {[m
[32m+[m[32m    content: '\f16f'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-grocery-store:before {[m
[32m+[m[32m    content: '\f1cb'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-hospital:before {[m
[32m+[m[32m    content: '\f177'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-laundry-service:before {[m
[32m+[m[32m    content: '\f1e9'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-library:before {[m
[32m+[m[32m    content: '\f18d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-mall:before {[m
[32m+[m[32m    content: '\f195'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-movies:before {[m
[32m+[m[32m    content: '\f19d'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-offer:before {[m
[32m+[m[32m    content: '\f187'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-parking:before {[m
[32m+[m[32m    content: '\f1a5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-parking:before {[m
[32m+[m[32m    content: '\f1a5'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-pharmacy:before {[m
[32m+[m[32m    content: '\f176'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-phone:before {[m
[32m+[m[32m    content: '\f2be'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-pizza:before {[m
[32m+[m[32m    content: '\f1ac'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-post-office:before {[m
[32m+[m[32m    content: '\f15a'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-printshop:before {[m
[32m+[m[32m    content: '\f1b0'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-see:before {[m
[32m+[m[32m    content: '\f28c'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-shipping:before {[m
[32m+[m[32m    content: '\f1e6'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-store:before {[m
[32m+[m[32m    content: '\f1d4'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-taxi:before {[m
[32m+[m[32m    content: '\f123'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-local-wc:before {[m
[32m+[m[32m    content: '\f211'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-my-location:before {[m
[32m+[m[32m    content: '\f299'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.zmdi-directions:before {[m
[32m+[m[32m    content: '\f1e7'[m
[32m+[m[32m}[m
\ No newline at end of file[m
[1mdiff --git a/web/static/scripts/register.js b/web/static/scripts/register.js[m
[1mindex da06314..2ad272a 100644[m
[1m--- a/web/static/scripts/register.js[m
[1m+++ b/web/static/scripts/register.js[m
[36m@@ -26,10 +26,6 @@[m [mfunction confirmSubmission() {[m
 [m
 function cancelOperation() {[m
     document.getElementById('confirm-dialog').close();[m
[31m-    // document.getElementById('new_entry').value = '';[m
[31m-    // document.getElementById('existing').value = '';[m
     document.getElementById('option_selector').value = '';[m
     document.getElementById('confirm-dialog').style.display = 'none';[m
[31m-    // document.getElementById('email_input').style.display = 'none';[m
[31m-    // document.getElementById('staff_input').style.display = 'none';[m
 }[m
[1mdiff --git a/web/static/styles/sign-in.css b/web/static/styles/sign-in.css[m
[1mindex e17aaae..89ebb8e 100644[m
[1m--- a/web/static/styles/sign-in.css[m
[1m+++ b/web/static/styles/sign-in.css[m
[36m@@ -272,6 +272,7 @@[m [miframe {[m
   top: 0;[m
   left: 0;[m
   pointer-events: none;[m
[32m+[m[32m  font-family: 'Font Awesome 5 Free';[m
 }[m
 [m
 .focus-input100::before {[m
[1mdiff --git a/web/templates/layout.html b/web/templates/layout.html[m
[1mindex fc8331e..520ed2d 100644[m
[1m--- a/web/templates/layout.html[m
[1m+++ b/web/templates/layout.html[m
[36m@@ -16,14 +16,18 @@[m
     <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">[m
     <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@docsearch/css@3">[m
     <link href="/docs/5.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">[m
[32m+[m[32m    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet"/>[m
[32m+[m
 [m
     <!--===============================================================================================-->	[m
 	<link rel="icon" type="image/png" href="images/icons/favicon.ico"/>[m
     <!--===============================================================================================-->[m
         <link rel="stylesheet" type="text/css" href="../static/vendor/bootstrap/css/bootstrap.min.css">[m
     <!--===============================================================================================-->[m
[32m+[m[32m        <link rel="stylesheet" type="text/css" href="../static/fonts/font-awesome-4.7.0/css/font-awesome.css">[m
         <link rel="stylesheet" type="text/css" href="../static/fonts/font-awesome-4.7.0/css/font-awesome.min.css">[m
     <!--===============================================================================================-->[m
[32m+[m[32m        <link rel="stylesheet" type="text/css" href="../static/fonts/iconic/css/material-design-iconic-font.css">[m
         <link rel="stylesheet" type="text/css" href="../static/fonts/iconic/css/material-design-iconic-font.min.css">[m
     <!--===============================================================================================-->[m
         <link rel="stylesheet" type="text/css" href="../static/vendor/animate/animate.css">[m
[36m@@ -48,16 +52,12 @@[m
 [m
 </head>[m
 <body class="light-theme">[m
[31m-    <header>[m
 [m
[31m-    </header>[m
     <section>[m
         {% block content %}[m
         {% endblock %}[m
     </section>[m
[31m-    <footer>[m
[31m-[m
[31m-    </footer>[m
[32m+[m[41m    [m
     <!-- Scripts -->[m
     <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>[m
     <!-- <script src="../static/scripts/bootstrap/min.js"></script> -->[m
[1mdiff --git a/web/templates/register.html b/web/templates/register.html[m
[1mindex ad4ff23..6151563 100644[m
[1m--- a/web/templates/register.html[m
[1m+++ b/web/templates/register.html[m
[36m@@ -28,11 +28,8 @@[m
 						</div>[m
 						<div class="wrap-input100">[m
 							<input class="input100" type="text" name="last_name" placeholder="Last Name">[m
[31m-							<span class="focus-input100" data-placeholder="&#xf207;"></span></div>[m
[31m-						<!-- <div class="wrap-input100">[m
[31m-							<input class="input100" type="text" name="email" placeholder="E-mail">[m
 							<span class="focus-input100" data-placeholder="&#xf207;"></span>[m
[31m-						</div> -->[m
[32m+[m						[32m</div>[m
 						<div class="wrap-input100">[m
 							<select class="input100" name="role" disabled>[m
 								<option value="" disabled>Role</option>[m
[36m@@ -40,32 +37,73 @@[m
 								<option value="{{ item }}" {% if item == 'NH' %}selected{% endif %}>Role: {{ item }}</option>[m
 								{% endfor %}[m
 							</select>[m
[31m-							<span class="focus-input100" data-placeholder="&#xf207;"></span>[m
[32m+[m							[32m<span class="focus-input100" data-placeholder="&#xf158;"></span>[m
 						</div>[m
 						<div class="wrap-input100">[m
[31m-							<select class="input100" name="role" disabled>[m
[32m+[m							[32m<select class="input100" name="manager" disabled>[m
[32m+[m								[32m<option value="" disabled>Manager</option>[m
[32m+[m								[32m{% for item in access_level.keys() %}[m
[32m+[m								[32m<option value="{{ item }}" {% if item == 'NH' %}selected{% endif %}>Manager: {{ item }}</option>[m
[32m+[m								[32m{% endfor %}[m
[32m+[m							[32m</select>[m
[32m+[m							[32m<span class="focus-input100 fa-group" data-placeholder="&#xf20d;"></span>[m
[32m+[m						[32m</div>[m
[32m+[m						[32m<div class="wrap-input100">[m
[32m+[m							[32m<select class="input100" name="schedule" disabled>[m
 								<option value="" disabled>Schedule</option>[m
 								{% for item in sched_options.values() %}[m
 								<option value="{{ item }}" {% if item == 'MTWTF' %}selected{% endif %}>Schedule: {{ item }}</option>[m
 								{% endfor %}[m
 							</select>[m
[32m+[m							[32m<span class="focus-input100" data-placeholder="&#xf32e;"></span>[m
[32m+[m						[32m</div>[m
[32m+[m					[32m</div>[m
[32m+[m
[32m+[m					[32m<div class="wrap-input100" id="existing" data-validate="Enter Staff ID" style="display: none;">[m
[32m+[m						[32m<div class="wrap-input100">[m
[32m+[m							[32m<input class="input100" type="text" name="staff_id" placeholder="Staff ID">[m
[32m+[m							[32m<span class="focus-input100" data-placeholder="&#xf200;"></span>[m
[32m+[m						[32m</div>[m
[32m+[m						[32m<div class="wrap-input100">[m
[32m+[m							[32m<input class="input100" type="text" name="email" placeholder="Staff E-mail">[m
[32m+[m							[32m<span class="focus-input100" data-placeholder="&#xf15a;"></span>[m
[32m+[m						[32m</div>[m
[32m+[m						[32m<div class="wrap-input100">[m
[32m+[m							[32m<input class="input100" type="text" name="first_name2" placeholder="First Name">[m
 							<span class="focus-input100" data-placeholder="&#xf207;"></span>[m
 						</div>[m
[31m-						<!-- <div class="wrap-input100">[m
[32m+[m						[32m<div class="wrap-input100">[m
[32m+[m							[32m<input class="input100" type="text" name="last_name2" placeholder="Last Name">[m
[32m+[m							[32m<span class="focus-input100" data-placeholder="&#xf207;"></span>[m
[32m+[m						[32m</div>[m
[32m+[m						[32m<div class="wrap-input100">[m
 							<select class="input100" name="role">[m
 								<option value="" disabled selected>Role</option>[m
 								{% for item in access_level.keys() %}[m
 								<option value="{{ item }}">{{ item }}</option>[m
 								{% endfor %}[m
 							</select>[m
[31m-							<span class="focus-input100" data-placeholder="&#xf207;"></span>[m
[32m+[m							[32m<span class="focus-input100" data-placeholder="&#xf158;"></span>[m
[32m+[m						[32m</div>[m
[32m+[m						[32m<div class="wrap-input100">[m
[32m+[m							[32m<select class="input100" name="manager">[m
[32m+[m								[32m<option value="" disabled selected>Manager</option>[m
[32m+[m								[32m{% for manager in managers %}[m
[32m+[m								[32m<option value="{{ manager.staff_id }}">{{ manager.name }}</option>[m
[32m+[m								[32m{% endfor %}[m
[32m+[m							[32m</select>[m
[32m+[m							[32m<span class="focus-input100" data-placeholder="&#xf20d;"></span>[m
[32m+[m						[32m</div>[m
[32m+[m						[32m<!-- <div class="wrap-input100">[m
[32m+[m							[32m<select class="input100" name="schedule">[m
[32m+[m								[32m<option value="" disabled selected>Schedule</option>[m
[32m+[m								[32m{% for item in sched_options.values() %}[m
[32m+[m								[32m<option value="{{ item }}" {% if item == 'MTWTF' %}selected{% endif %}>{{ item }}</option>[m
[32m+[m								[32m{% endfor %}[m
[32m+[m							[32m</select>[m
[32m+[m							[32m<span class="focus-input100" data-placeholder="&#xf32e;"></span>[m
 						</div> -->[m
 					</div>[m
[31m-[m
[31m-					<div class="wrap-input100" id="existing" data-validate="Enter Staff ID" style="display: none;">[m
[31m-						<input id="staff_id" class="input100" type="text" name="staff_id" placeholder="Staff ID">[m
[31m-						<span class="focus-input100" data-placeholder="&#xf207;"></span>[m
[31m-					</div>[m
 					<div><center>{{ msg }}</center></div>[m
 					<div class="container-login100-form-btn">[m
 						<button id="btnsubmit" type="submit" class="login100-form-btn">[m
[36m@@ -103,5 +141,41 @@[m
 <!--===============================================================================================-->[m
 	<script src="../static/scripts/main.js"></script>[m
 	<script src="../static/scripts/register.js"></script>[m
[32m+[m	[32m<!-- <script>[m
[32m+[m[41m		[m
[32m+[m[32mfunction filterManagers() {[m
[32m+[m[32m    var roleSelect = document.getElementsByName('role')[0];[m
[32m+[m[32m    var managerSelect = document.getElementsByName('manager')[0];[m
[32m+[m[32m    var selectedRole = roleSelect.value;[m
[32m+[m
[32m+[m[32m    // Clear the current manager options[m
[32m+[m[32m    managerSelect.innerHTML = '<option value="" disabled selected>Manager</option>';[m
[32m+[m
[32m+[m[32m    // // Get access level for the selected role[m
[32m+[m[32m    var accessLevel = { access_level , tojson };[m
[32m+[m[32m    var managers = { managers , tojson };[m
[32m+[m
[32m+[m[32m    // Determine the required access level for managers based on the selected role[m
[32m+[m[32m    var requiredAccessLevel;[m
[32m+[m[32m    if (selectedRole === 'SE' || selectedRole === 'T2' || selectedRole === 'TL') {[m
[32m+[m[32m        requiredAccessLevel = accessLevel.TM;[m
[32m+[m[32m    } else if (selectedRole === 'DM' || selectedRole === 'TM') {[m
[32m+[m[32m        requiredAccessLevel = accessLevel.OM;[m
[32m+[m[32m    } else if (selectedRole === 'OM') {[m
[32m+[m[32m        requiredAccessLevel = accessLevel.GM;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // Add the filtered manager options[m
[32m+[m[32m    managers.forEach(function(manager) {[m
[32m+[m[32m        if (manager.access_level >= requiredAccessLevel) {[m
[32m+[m[32m            var option = document.createElement('option');[m
[32m+[m[32m            option.value = manager.name;[m
[32m+[m[32m            option.text = 'Manager: ' + manager.name;[m
[32m+[m[32m            managerSelect.appendChild(option);[m
[32m+[m[32m        }[m
[32m+[m[32m    });[m
[32m+[m[32m}[m
[32m+[m
[32m+[m	[32m</script> -->[m
 [m
 {% endblock %}[m
