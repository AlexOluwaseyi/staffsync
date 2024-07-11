#!/usr/bin/python3

from models.advocate import SE, NH, T2, TL
from models.manager import TM, DM, OM, GM
from models.bus_enablement import BE
from models.employee import Employee

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
