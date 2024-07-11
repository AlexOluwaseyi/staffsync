#!/usr/bin/python3

from models.advocate import NH, SE, T2, TL
from models.bus_enablement import BE
from models.employee import Employee
from models.manager import DM, GM, OM, TM

roles_dict = {
    'Employee': Employee,
    'NH': NH,
    'SE': SE,
    'T2': T2,
    'TL': TL,
    'TM': TM,
    'DM': DM,
    'OM': OM,
    'GM': GM,
    'BE': BE,
}
