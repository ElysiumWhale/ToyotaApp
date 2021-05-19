# ToyotaApp

## About

This is box solution prototype for car dealers which want present their services for customers in easy form of mobile app.

---

## Overview

Main testing device: **iPhone XS iOS 14.5.1**

Secondary testing device: **iPhone 7 14.5.1**

SMS-code for testing: **1234** (will be generated and sent during pre-release testing)

For testing HTTPS **is off** (will be turned on during pre-release testing)

VIN codes for cars in [API.md](Docs/API.md) (Testing section)

### Ready parts

- Registration:
  - full register with car or without
  - auth from new device with downloading all userdata
  - continue from particular registration step (from personal data, dealer picking or car checking)
  - logout
- Editing user info:
  - cnahge personal info
  - change phone number from settings
  - adding new cars
- Services:
  - choosing car for downloading actual services (if user has more than 1 car)
  - ~~booking in ServicesMaintananceVC (***Сервисное обслуживание***) (picking service and time then booking)~~
  - working with apple maps in HelpOnRoadVC (***Помощь на дороге***)
  - choosing service and date with time in ServiceMaintenanceViewController (***Сервисное обслуживание***)

### Mocks

List of mocks:

- NewsViewController (represents possible view of news cells)
- HistoryViewController (represents possible view of news cells)
- Service booking is not ready on server side...
- TestDriveVC
- RepairingVC

## Future release

- Dynamic adding of servcies categories created by admin of client module (several types of VC with inheritance for code reusabitiy (types: 1,2,3 choices, map, map with time)
- Booking history
- News from server created by admin of client module
- Some UI adaptation for 4.7' iPhone generation
- Delete cars
- FontAwesome for services icons cells
- Working with secret auth key through keychain
- Push notifications
