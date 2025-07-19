## Setup Instructions

### Clone the Repository

```bash
git clone https://github.com/NamitCodes/sarva-suvidha-job-task.git
cd sarva-suvidha-job-apply
```

---

### Backend Setup (FastAPI)

```bash
cd backend
# Create and configure .env file (see env-example)
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

---

### Frontend Setup (Flutter)

```bash
cd KPA-ERP-FE
flutter pub get
flutter run
```

> **Login Credentials (Demo)**
>
> * Mobile Number: `7760873976`
> * Password: `to_share@123`

---

### Features Overview

* **Submit Wheel Specification Form** — Adds new data to the database
* **Filter Wheel Data** — By **Form Number**, **Submitted By**, or **Submitted Date** using the filter icon beside *ICF Wheel Specs* title

---

## Tech Stack Used

* **Frontend:** Flutter (with Provider & HTTP client)
* **Backend:** FastAPI (with SQLAlchemy & PostgreSQL async)
* **Database:** Supabase PostgreSQL
* **ORM:** SQLAlchemy Async

---

## Implemented APIs

| Endpoint                          | Method | Description                                      |
| --------------------------------- | ------ | ------------------------------------------------ |
| `/api/forms/wheel-specifications` | POST   | Submit wheel specification form                  |
| `/api/forms/wheel-specifications` | GET    | Fetch wheel specifications with optional filters |
| `/api/users/login`                | POST   | Dummy User login (phone/password) authentication       |

---

## Assumptions & Limitations

* 📝 **Login credentials are hardcoded** for demo/testing purposes
* 📃 **Token is not validated on backend** (Assumed trusted client for now)
* 🐘 Supabase pooler URL is used; ensure correct database permissions
* 🌐 CORS is allowed from all origins (`*`) — should be restricted in production
* ✅ Form field validations are basic/minimal

---

## Screen Recording / Demonstration
* [Here](https://drive.google.com/file/d/1Gj7w8fNRLOnLmD8q0jrNqUDTNBJAk1XF/view)
