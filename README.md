# StaffSync
## About StaffSync
StaffSync is an employee management web-based app which helps to manage and organize employees and members of staff of an organization. 

## Technology
StaffSync (v 1.0) is developed with HTML, CSS and JavaScript for its front-end. Backend is coded in Python with Python Flask modules such as Flask and SQLite3 for database management.

## Code Snippet
![Base Model](https://github.com/user-attachments/assets/6953b346-d8d7-45d5-8f7c-33e4bfe68212)
![Class Initialization](https://github.com/user-attachments/assets/fde19db8-3798-4c10-906c-6e452749a56c)
![Class Methods](https://github.com/user-attachments/assets/57fddb1f-b115-4259-946d-5cd80b294f02)

## Structure
### Models
- [Base Model](https://github.com/AlexOluwaseyi/staffsync/blob/main/models/employee.py)
- [Database Engine](https://github.com/AlexOluwaseyi/staffsync/blob/main/models/engine/db.py)
### Web Static and Flask Templates
- [Flask Template](https://github.com/AlexOluwaseyi/staffsync/tree/main/web/templates)
- [Static web files](https://github.com/AlexOluwaseyi/staffsync/tree/main/web)
### App
- [Flask App](https://github.com/AlexOluwaseyi/staffsync/blob/main/web/app.py)

## Development
StaffSync v1.0 was developed as a portfolio project as a part of the requirements for the graduation from the ALX Software Engineering programme. 
To check out the project, you may clone the repository and run the following code in your terminal.

```
echo "#!/usr/bin/python3 >> ./web/creds.py"
echo "secretKey = [enter a string key here] >> ./web/creds.py"
pip install -r requirement.txt
python3 -m web.app
```

## Future of StaffSync
StaffSync will continue to evolve into a model for implementation in large and complex organizations to replace existing structures.

## Limitation
StaffSync assumes that its features would be implemented behind a secured system. Future versions of StaffSync would remove this (and every other) assumptions to promote implementation for all type organization.
