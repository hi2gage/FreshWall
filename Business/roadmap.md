# FreshWall Beta Roadmap & Checklist for Scott

## ✅ 1. Core App Functionality (MVP)

These are required for Scott and his crew to use FreshWall in the field.

- [ ] **Authentication & Onboarding**
  - [x] Sign-up / login
  - [x] Create a team
  - [ ] Invite users via email or link
  - [ ] Assign user roles: Admin, Manager, Field Worker

- [ ] **Incident Logging**
  - [ ] Field worker can log a graffiti job
    - [ ] Take/upload *before* photo
    - [ ] Add metadata (location, surface type, notes)
    - [ ] Auto-timestamp
  - [ ] Field worker can mark job as complete
    - [ ] Take/upload *after* photo
    - [ ] Add cleanup notes or outcome status

- [ ] **Incident Browsing**
  - [ ] View incidents by list and map
  - [ ] Filter by status (open, complete)
  - [ ] Sort by date or location
  - [ ] Role-based access:
    - [ ] Field Workers: can view their jobs
    - [ ] Managers/Admins: can view all jobs

- [ ] **Reporting**
  - [ ] Generate exportable report (PDF/CSV)
    - [ ] Includes before/after images, timestamps, notes
  - [ ] Filter by date range and status

---

## 📲 2. Beta Presentation Readiness

To clearly present FreshWall to Scott for testing and feedback.

- [ ] Demo-ready iPhone build
- [ ] Preloaded test data (2–3 jobs with photos)
- [ ] Sample report export (PDF)
- [ ] 5-minute demo script or screen recording
- [ ] Summary of intended monthly workflow:
  - Field logs → Manager reviews → Admin exports → Invoice sent

---

## 💬 3. Feedback Goals

You want Scott to help answer:

- [ ] Does this match how jobs are tracked today?
- [ ] What parts are confusing or missing?
- [ ] Is the role separation useful?
- [ ] Would this improve monthly invoicing/reporting?
- [ ] How much would they expect to pay?

---

## 🔐 4. Account & Data Management

Even during beta, secure and structured data handling is key.

- [ ] Firebase Auth with email/password
- [ ] Firebase rules to enforce team-based access
- [ ] Role-based permissions in Firestore
- [ ] Firebase Storage for photo uploads
- [ ] Export or backup system (manual CSV is fine to start)

---

## 💡 5. Future Potential (Optional to show)

Not required now, but shows long-term thinking.

- [ ] Push notifications (e.g., job assigned to user)
- [ ] White-label reporting (logos/colors)
- [ ] Web dashboard for admins (Phase 2)
- [ ] Integration with city systems (e.g., 311)

---
