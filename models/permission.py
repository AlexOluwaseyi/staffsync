#!/usr/bin/python3

from enum import IntEnum


class AccessLevel(IntEnum):
    SUPER_ADMIN = 0
    ADMIN = 1
    GM = 2
    OM = 3
    BE = 3
    TM = 4
    DM = 4
    SME = 5
    TL = 6
    T2 = 7
    SE = 8
    NH = 9
    VISITORS = 10


roles_description = {
    'Super Admin': "Super Admin",
    'MGMT': "Admin.",
    "BE": "Business Enablement",
    'TM': "Team Manager",
    'DM': "Duty Manager",
    'OM': "Operations Manager",
    'SME': "Subject Matter Experts",
    'TL': "Technical Lead",
    'T2': "Tier 2 Support Advocate",
    'SE': "Tenured Advocate",
    'NH': "New Hires",
    'VIS': "Visitors"
}
# roles_description = {
#     1: "Super Admin",
#     2: "Management",
#     3: "Manager",
#     4: "Operations Manager",
#     5: "Subject Matter Experts",
#     6: "Technical Lead",
#     7: "Tier 2 Support Advocate",
#     8: "Tenured Advocate",
#     9: "New Hires",
#     10: "Visitors"
# }


# Create a dictionary to map roles to access levels
access_level = {
    "SUPER_ADMIN": AccessLevel.SUPER_ADMIN,
    "ADMIN": AccessLevel.ADMIN,
    "GM": AccessLevel.GM,
    "TM": AccessLevel.TM,
    "OM": AccessLevel.OM,
    "DM": AccessLevel.DM,
    "BE": AccessLevel.BE,
    "TM": AccessLevel.TM,
    "SME": AccessLevel.SME,
    "TL": AccessLevel.TL,
    "T2": AccessLevel.T2,
    "SE": AccessLevel.SE,
    "NH": AccessLevel.NH,
    "VISITORS": AccessLevel.VISITORS
}


class Permission:
    """
    VIEW_REPORTS = AccessLevel.EMPLOYEE
    EDIT_REPORTS = AccessLevel.MANAGER
    DELETE_REPORTS = AccessLevel.ADMIN
    CONFIGURE_SYSTEM = AccessLevel.SUPER_ADMIN
    """
    pass
