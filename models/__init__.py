#!/usr/bin/python3
"""
Initialize the models package
"""
from models.engine.db import DBStorage

storage = DBStorage()
storage.reload()
