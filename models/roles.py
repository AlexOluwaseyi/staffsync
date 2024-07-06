#!/usr/bin/python3

"""A dictionary of all the
available roles
"""

from models.employee import Employee
from models.advocate import SE, T2, TL
from models.manager import TM, DM, OM, GM
from models.bus_enablement import BE


roles_dict = {
    'Employee': Employee,
    'SE': SE,
    'T2': T2,
    'TL': TL,
    'TM': TM,
    'DM': DM,
    'OM': OM,
    'GM': GM,
    'BE': BE
}
