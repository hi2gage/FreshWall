# FreshWall Beta Roadmap & Current Status

**Current Status**: Scott has beta version, beginning field testing this week

## ✅ 1. Core App Functionality (MVP)

These are required for Scott and his crew to use FreshWall in the field.

- [x] **Authentication & Onboarding**
  - [x] Sign-up / login
  - [x] Create a team
  - [⏳] Invite users via email or link
  - [⏳] Assign user roles: Admin, Manager, Field Worker

  *Note: Role system deferred - Scott will test as single user first*

- [x] **Incident Logging**
  - [x] Field worker can log a graffiti job
    - [x] Take/upload *before* photo
    - [x] Add metadata (location, surface type, notes)
    - [x] Auto-timestamp
  - [x] Field worker can mark job as complete
    - [x] Take/upload *after* photo
    - [x] Add cleanup notes or outcome status

  *Ready for Scott's field testing*

- [x] **Incident Browsing**
  - [x] View incidents by list and map
  - [x] Filter by status (open, complete)
  - [x] Sort by date or location
  - [⏳] Role-based access:
    - [⏳] Field Workers: can view their jobs
    - [⏳] Managers/Admins: can view all jobs

  *Basic browsing complete, role-based access pending user feedback*

- [🔄] **Reporting**
  - [🔄] Generate exportable report (CSV for now)
    - [🔄] Database export to CSV for Scott's existing workflow
    - [⏳] Image encoding into reports (future enhancement)
  - [x] Filter by date range and status

  *Interim solution: Manual CSV export while testing with Scott*

- **Critical Technical Issues** (Must fix before heavy usage):
  - [🚨] Photo caching/performance optimization
  - [🚨] Billing option selection reset bug

**Business Foundation** (Parallel to beta testing):
  - [🔄] LLC setup with EIN and business bank account
  - [🔄] Google Business Profile setup
  - [🔄] Domain email migration
  - [⏳] App Store Connect setup (post-validation)
---

## 📲 2. Beta Status with Scott

**COMPLETED**: Scott has received beta version and is ready to begin field testing

- [x] Demo-ready iPhone build **delivered to Scott**
- [x] Sample workflow demonstrated
- [🔄] **Active**: Scott beginning real job testing this week
- [🔄] **Feedback Collection**: Screen recordings with audio narration requested
- [x] Simplified workflow for single-user testing:
  - Scott logs incidents → Reviews completed work → Exports data to existing invoicing system

---

## 💬 3. Key Validation Questions for Scott

**Primary Success Metrics**:
- [🔄] **Time Savings**: Does this save significant time vs. current process?
- [🔄] **Stickiness**: Would removing this tool be frustrating?
- [🔄] **Payment Willingness**: Confirmed $50-100/month range is acceptable

**Workflow Validation**:
- [🔄] Does this match how jobs are tracked today?
- [🔄] What parts are confusing or missing?
- [⏳] Is the role separation useful? (deferred for now)
- [🔄] Would this improve monthly invoicing/reporting?

**Technical Performance**:
- [🔄] Photo upload/download speed and reliability
- [🔄] App responsiveness and crash rate
- [🔄] Offline functionality in the field

---

## 🔐 4. Account & Data Management

Even during beta, secure and structured data handling is key.

- [x] Firebase Auth with email/password
- [x] Firebase rules to enforce team-based access
- [ ] Role-based permissions in Firestore
- [x] Firebase Storage for photo uploads
- [🔄] Export or backup system (manual CSV being implemented)

---

## 💡 5. Post-Beta Expansion Strategy

**Phase 2 - After Scott Validation**:
- [ ] Additional beta customers from 4.5k graffiti company database
- [ ] Advanced reporting with professional PDF generation
- [ ] Multi-user role system based on feedback
- [ ] Web dashboard for admin/manager users

**Phase 3 - Market Expansion**:
- [ ] SEO content marketing for "visual field service documentation"
- [ ] Integration with QuickBooks/billing systems
- [ ] White-label reporting capabilities
- [ ] Expansion beyond graffiti to general field service

## 🎯 Current Focus Areas

1. **Scott's Success** (70% effort): Ensure smooth field testing experience
2. **Business Foundation** (30% effort): Setup for future customer acquisition
3. **Performance Issues**: Photo caching and billing selection bugs
4. **Feedback Loop**: Systematic collection of Scott's usage data and pain points

---
