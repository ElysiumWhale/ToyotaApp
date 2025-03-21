# Toyota API

<details> <summary>Table of contents</summary>

- [Toyota API](#toyota-api)
  - [General](#general)
    - [Services controllers types](#services-controllers-types)
  - [Colors](#colors)
  - [Testing](#testing)
    - [Cars VINs](#cars-vins)
  - [Flows](#flows)
    - [Adding new showroom](#adding-new-showroom)
    - [Change phone number](#change-phone-number)
    - [Test Drive booking](#test-drive-booking)
  - [Requests](#requests)
    - [Сheck user registration at application launch](#сheck-user-registration-at-application-launch)
      - [**Success response**](#success-response)
        - [**Variant 1:** Only phone number checking](#variant-1-only-phone-number-checking)
        - [**Variant 2:** Profile is full](#variant-2-profile-is-full)
        - [**Variant 3:** Fully registered and authorized on device](#variant-3-fully-registered-and-authorized-on-device)
      - [**Failure response**](#failure-response)
    - [Phone number registration](#phone-number-registration)
      - [**Success response**](#success-response-1)
      - [**Failure response**](#failure-response-1)
    - [Check SMS-code](#check-sms-code)
      - [**Success response**](#success-response-2)
        - [**Variant 1:** New account](#variant-1-new-account)
        - [**Variant 2:** Empty account](#variant-2-empty-account)
        - [**Variant 3:** Profile is full](#variant-3-profile-is-full)
        - [**Variant 4:** Full profile](#variant-4-full-profile)
      - [**Failure response**](#failure-response-2)
    - [Set pofile data](#set-pofile-data)
      - [**Success response**](#success-response-3)
      - [**Failure response**](#failure-response-3)
        - [**List of errors**](#list-of-errors)
    - [Get models and colors](#get-models-and-colors)
      - [**Success response**](#success-response-4)
      - [**Failure response**](#failure-response-4)
    - [Set car](#set-car)
      - [**Success response**](#success-response-5)
      - [**Failure response**](#failure-response-5)
    - [Get showrooms](#get-showrooms)
      - [**Success response**](#success-response-6)
      - [**Failure response**](#failure-response-6)
    - [Delete temp phone](#delete-temp-phone)
      - [**Success response**](#success-response-7)
      - [**Failure response**](#failure-response-7)
    - [Get services categories/types](#get-services-categoriestypes)
      - [**Success response**](#success-response-8)
      - [**Failure response**](#failure-response-8)
    - [Get services from the category](#get-services-from-the-category)
      - [**Success response**](#success-response-9)
      - [**Failure response**](#failure-response-9)
    - [Get free time](#get-free-time)
      - [**Success response**](#success-response-10)
        - [**Variant 1:** Anytime](#variant-1-anytime)
        - [**Variant 2:** Time limits](#variant-2-time-limits)
      - [**Failure response**](#failure-response-10)
        - [**List of errors**](#list-of-errors-1)
    - [Get cities](#get-cities)
      - [**Success response**](#success-response-11)
      - [**Failure response**](#failure-response-11)
    - [Add new showroom](#add-new-showroom)
      - [**Success response**](#success-response-12)
      - [**Failure response**](#failure-response-12)
    - [Edit profile data](#edit-profile-data)
      - [**Success response**](#success-response-13)
      - [**Failure response**](#failure-response-13)
    - [Change phone](#change-phone)
      - [**Success response**](#success-response-14)
      - [**Failure response**](#failure-response-14)
    - [Get cars for test drive](#get-cars-for-test-drive)
      - [**Success response**](#success-response-15)
      - [**Failure response**](#failure-response-15)
    - [Get showrooms for test drive](#get-showrooms-for-test-drive)
      - [**Success response**](#success-response-16)
      - [**Failure response**](#failure-response-16)
    - [Book service](#book-service)
      - [**Success response**](#success-response-17)
      - [**Failure response**](#failure-response-17)
    - [Get managers](#get-managers)
      - [**Success response**](#success-response-18)
      - [**Failure response**](#failure-response-18)
  - [Palette](#palette)

</details>

---

## General

API uses **only POST** queries.

Base URL: <http://cv39623.tmweb.ru/avtosalon/mobile/>

Base **image** URL: <http://cv39623.tmweb.ru/avtosalon> (using for downloading avatars for [managers](#get-managers))

### Services controllers types

| Id  | Control type description         | List of services       | Realization is required |
| --- | -------------------------------- | ---------------------- |:-----------------------:|
| 0   | not defined                      |                        |   :heavy_check_mark:    |
| 1   | timepick                         |                        |   :heavy_check_mark:    |
| 2   | map                              | Помощь на дороге       |   :heavy_check_mark:    |
| 3   | 1 question                       |                        |   :heavy_check_mark:    |
| 4   | ~~2 questions~~                  |                        |                         |
| 5   | ~~3 questions~~                  |                        |                         |
| 6   | 1 question + timepick            | Сервисное обслуживание |   :heavy_check_mark:    |
| 7   | ~~2 questions + timepick~~       |                        |                         |
| 8   | 3 questions + timepick           | Тест драйв             |   :heavy_check_mark:    |
| 9   | 1 question + map                 |                        |   :heavy_check_mark:    |
| 10  | ~~2 questions + map~~            |                        |                         |
| 11  | ~~3 questions + map~~            |                        |                         |
| 12  | 1 question + timepick + map      |                        |   :heavy_check_mark:    |
| 13  | ~~2 questions + timepick + map~~ |                        |                         |
| 14  | ~~3 questions + timepick + map~~ |                        |                         |

## Colors

- #D90022
- #F20022
- See brandbook

## Testing

SMS code for registration: **1234**

### Cars VINs

- Самара Юг
  1. 1234567890abcdefg
  2. fDlFjcwmTkCl1dr8W
  3. OKsf8jyHshgQ6pYAD
- Самара Север
  1. uMGT0r6tF6zWZmBzH
  2. IuQ381fbQbrECV9eu
  3. K5MHrhBR6t5wTD5gm

---

## Flows

### Adding new showroom

**Request chain:** [Get cities](#get-cities) —> [Get showrooms](#city-choosing) —> [Add showroom](#add-new-showroom)

---

### Change phone number

**Request chain:** [Register phone](#phone-number-registration) —> [Change phone](#change-phone)

---

### Test Drive booking

**Request chain:** [Get cities](#get-cities) —> [Get cars fot test drive](#get-cars-for-test-drive) —> [Get showrooms for test drive](#get-showrooms-for-test-drive) —> [Get free time](#getting-free-time) —> [Book service](#book-service) (`service_id` - chosen car)

---

## Requests

### Сheck user registration at application launch

**Path:** `check_user.php`

**Params:**

- `brand_id` - app const
- `user_id` - from app memory
- `secret_key` - from app memory

#### **Success response**

##### **Variant 1:** Only phone number checking

```json
{
  "result": "ok",
  "secret_key": "generated secret key",
  "register_page":1
}
```

##### **Variant 2:** Profile is full

```json
{
  "result": "ok",
  "secret_key": "generated secret key",
  "register_page":2,
  "registered_user":
    {
      "profile":
        {
          "first_name": "Иван",
          "second_name": "Иваныч",
          "last_name": "Иванов",
          "phone": "8 909 111-11-11",
          "email": "email@email.com",
          "birthday": "2020-08-01"
        }
    },
  "cities": [
    {
      "id": "1",
      "city_name": "Самара"
    },
    {
      "id": "2",
      "city_name": "Тольятти"
    }
  ]
}
```

> **Including [Get Models and Colors response](#get-models-and-colors)**

##### **Variant 3:** Fully registered and authorized on device

```json
{
  "result": "ok",
  "secret_key": "generated secret key",
  "register_status": 1
}
```

#### **Failure response**

```json
{
  "error_code": "101",
  "error_message": "Пользователь отсутствует в базе"
}
```

[**To table of contents**](#toyota-api)

---

### Phone number registration

**Path:** `register_phone.php`

**Params:**

- `phone_number` - written by user

#### **Success response**

```json
{
  "result": "ok"
}
```

#### **Failure response**

```json
{
  "error_code": "",
  "error_message": ""
}
```

[**To table of contents**](#toyota-api)

---

### Check SMS-code

**Path:** `check_code.php`

**Params:**

- `phone_number` - got on previous step
- `code` - got via SMS
- `brand_id` - app constant

#### **Success response**

##### **Variant 1:** New account

```json
{
  "result": "ok",
  "user_id": "generated_id",
  "secret_key": "generated_secret_key"
}
```

##### **Variant 2:** Empty account

```json
{
  "result": "ok",
  "secret_key": "generated secret key",
  "user_id": "user id",
  "register_page": 1
}
```

##### **Variant 3:** Profile is full

**[Look there](#variant-2-profile-is-full)**

##### **Variant 4:** Full profile

```json
{
  "result": "ok",
  "secret_key": "7ab7e6dc2cf0b6daa789185d51c118a8",
  "user_id": "user id",
  "register_status": 1,
  "registered_user": {
    "profile": {
      "first_name": "Name",
      "second_name": "Name",
      "last_name": "Name",
      "phone": "79083324135",
      "email": "aboba@aboba.com",
      "birthday": "1990-10-30"
    },
    "cars": [
      {
        "car_brand_name": "Toyota",
        "car_id": "1",
        "car_year": "2020",
        "license_plate": "а001аа163rus",
        "vin_code": "1234567890abcdefg",
        "model": {
          "id": "1",
          "car_model_name": "LC 200",
          "car_brand_id": "1"
        },
        "color": {
          "id": "1",
          "color_code": "123",
          "car_color_name": "Абрикос",
          "color_swatch": "#cc6633",
          "color_description": "Светло оранжевый",
          "color_metallic": "1"
        }
      }
    ]
  }
}
```

#### **Failure response**

```json
{
  "error_code": "102",
  "error_message": "Присланный Вами код не совпадает"
}
```

[**To table of contents**](#toyota-api)

---

### Set pofile data

**Path:** `set_profile.php`

**Params:**

- `brand_id` - constant in app
- `user_id` - got on previous step
- `first_name` - written by user
- `second_name` - written by user
- `last_name` - written by user
- `email` - written by user
- `birthday` - written by user

#### **Success response**

```json
{
  "result": "ok",
  "cities": [
    {
      "id": "1",
      "city_name": "Самара"
    },
    {
      "id": "2",
      "city_name": "Тольятти"
    }
  ]
}
```

> **Including [Get Models and Colors response](#get-models-and-colors)**

#### **Failure response**

```json
{
  "error_code": "103",
  "error_message": "Ошибка сервера."
}
```

##### **List of errors**

| Code | Message |
|------|---------|
| 101 | Не удалось получить список городов. |
| 103 | Не удалось заполнить профиль пользователя. |

[**To table of contents**](#toyota-api)

---

### Get models and colors

**Path:** `get_models_and_colors.php`

**Params:**

- `brand_id` - application const

#### **Success response**

```json
{
  "result":"ok",
  "models": [
    {
      "id":"1",
      "car_brand_id":"1",
      "car_model_name":"RAV4"
    },
    {
      "id":"2",
      "car_brand_id":"1",
      "car_model_name":"Avensis"
    }
  ],
  "colors": [
    {
      "id":"1",
      "color_code":"102",
      "color_swatch":"#cc6633",
      "car_color_name":"Абрикос",
      "color_description":"Серебристо-светло оранжевый",
      "color_metallic":"1"
    },
    {
      "id":"2",
      "color_code":"602",
      "color_swatch":"#00111b",
      "car_color_name":"Авантюрин",
      "color_description":"Серебристо-чёрный",
      "color_metallic":"0"
    }
  ]
}
```

#### **Failure response**

```json
{
  "error_code": "",
  "error_message": ""
}
```

[**To table of contents**](#toyota-api)

---

### Set car

**Path:** `get_showrooms.php`

**Params:**

- `brand_id` - application const
- `user_id`  - from memory
- `car_model_id`  - selected by user
- `color_id`  - selected by user
- `license_plate`  - written by user (optional)
- `vin_code`  - written by user
- `year_of_release` - selected by user

#### **Success response**

```json
{
  "result": "ok",
  "car_id": "11"
}
```

#### **Failure response**

```json
{
  "error_code": "",
  "error_message": ""
}
```

[**To table of contents**](#toyota-api)

---

### Get showrooms

**Path:** `get_showrooms.php`

**Params:**

- `brand_id` - application const
- `city_id`  - selected by user

#### **Success response**

```json
{
  "result": "ok",
  "showrooms": [
    {
      "id": "1",
      "showroom_name": "Тойота Центр Самара Юг"
    },
    {
      "id": "2",
      "showroom_name": "Тойота Центр Самара Север"
    },
    {
      "id": "7",
      "showroom_name": "Тойота Центр Самара Аврора"
    }
  ]
} 
```

#### **Failure response**

```json
{
  "error_code": "101",
  "error_message": "Не найдено ни одного салона"
}
```

[**To table of contents**](#toyota-api)

---

### Delete temp phone

**Path:** `delete_tmp_record.php`

**Params:**

- `phone_number` - got on [phone register step](#phone-number-registration)

#### **Success response**

```json
{
  "result": "ok"
}
```

#### **Failure response**

```json
{
  "error_code": "108",
  "message": "Ошибка сервера. Не удалось удалить временную запись."
}
```

[**To table of contents**](#toyota-api)

---

### Get services categories/types

**Path:** `get_service_type.php`

**Params:**

- `showroom_id` - got from selected by user car

#### **Success response**

```json
{
  "result": "ok",
  "service_type": [
    {
      "id": "1",
      "service_type_name": "Сервисное обслуживание",
      "control_type_id": "0",
      "control_type_name": "Тип № 0",
      "control_type_desc": "Тип контроллера не выбран"
    },
    {
      "id": "2",
      "service_type_name": "Услуги сервиса",
      "control_type_id": "0",
      "control_type_name": "Тип № 0",
      "control_type_desc": "Тип контроллера не выбран"
    }
  ]
}
```

#### **Failure response**

```json
{
  "error_code": "101",
  "message": "Ошибка сервера. Не удалось получить список категорий услуг."
}
```

[**To table of contents**](#toyota-api)

---

### Get services from the category

**Path:** `get_services.php`

**Params:**

- `showroom_id` - got on [previous step](#getting-the-categories-of-services)
- `service_type_id` - selected by user

#### **Success response**

```json
{
  "result": "ok",
  "services": [
    {
      "id": "1",
      "service_name": "Плановое ТО №1"
    },
    {
      "id": "2",
      "service_name": "Плановое ТО №2"
    }
  ]
}
```

#### **Failure response**

```json
{
  "error_code": "101",
  "message": "Ошибка сервера. Не удалось получить список услуг."
}
```

[**To table of contents**](#toyota-api)

---

### Get free time

**Path:** `get_free_time.php`

**Params:**

- `showroom_id` - got on [previous step](#getting-the-categories-of-services)
- `sid` - got on [previous step](#getting-a-services-from-a-category)

#### **Success response**

##### **Variant 1:** Anytime

```json
{
  "result": "ok",
  "message": "Время бронирования свободно на любую дату"
}
```

##### **Variant 2:** Time limits

```json
{
  "result": "ok",
  "start_date": "2020-12-22",
  "end_date": "2020-12-23",
  "free_times": [
    {
      "2020-12-22":[18,20,21,22,34,35,36,37]
    },
    {
      "2020-12-23":[18,19,20,21,22,23,24,25,26,27,28,29]
    }
  ]
}
```

#### **Failure response**

```json
{
  "error_code": "104",
  "message": "Ошибка сервера"
}
```

##### **List of errors**

| Code | Message |
|------|---------|
| 104 | Не удалось получить режим работы салона |
| 104 | Не удалось получить данные по выбранной услуге |
| 104 | Не удалось получить список постов |
| 104 | Не удалось получить список свободных дат |
| 104 | Не удалось получить список забронированного времени |

[**To table of contents**](#toyota-api)

---

### Get cities

**Path:** `get_cities.php`

**Params:**

- `brand_id` - app constant

#### **Success response**

```json
{
  "result": "ok",
  "cities": [
    {
      "id": "1",
      "city_name": "Самара"
    },
    {
      "id": "2",
      "city_name": "Тольятти"
    }
  ]
}
```

#### **Failure response**

```json
{
  "error_code": "101",
  "error_message": "Ошибка сервера. Не удалось получить список городов."
}
```

[**To table of contents**](#toyota-api)

---

### Add new showroom

**Path:** `add_showroom.php`

**Params:**

- `user_id` - from memory
- `showroom_id` - got on [previous step](#city-choosing)

#### **Success response**

```json
{
  "result": "ok",
  "message": "Данный салон теперь появится в списке Ваших салонов."
}
```

#### **Failure response**

```json
{
  "error_code": "101",
  "error_message": "Ошибка сервера."
}
```

| Code | Message |
|------|---------|
| 104 | Не удалось проверить список клиентов салона |
| 104 | Не удалось добавить салон |

[**To table of contents**](#toyota-api)

---

### Edit profile data

**Path:** `edit_profile.php`

**Params:**

- `user_id` - from memory
- `first_name` - written by user
- `second_name` - written by user
- `last_name` - written by user
- `email` - written by user
- `birthday` - written by user

#### **Success response**

```json
{
  "result": "ok"
}
```

#### **Failure response**

```json
{
  "error_code": "101",
  "error_message": "Ошибка сервера. Не удалось обновить профиль пользователя."
}
```

[**To table of contents**](#toyota-api)

---

### Change phone

**Path:** `change_phone_number.php`

**Params:**

- `user_id` - from memory
- `code` - got via SMS
- `phone_number` - written by user

#### **Success response**

```json
{
  "result": "ok"
}
```

#### **Failure response**

```json
{
  "error_code": "104",
  "error_message": "Ошибка сервера. Не удалось обновить номер телефона."
}
```

[**To table of contents**](#toyota-api)

---

### Get cars for test drive

**Path:** `get_cars_ftd.php`

**Params:**

- `brand_id` - app constant
- `city_id` - got (selected by user) on [previous step](#get-cities)

#### **Success response**

```json
{
  "result": "ok",
  "cars": [
    {
      "id": "9",
      "service_name": "Тойота LC 200"
    },
    {
      "id": "10",
      "service_name": "Тойота Camry"
    }
  ]
}
```

#### **Failure response**

```json
{
  "error_code": "104",
  "error_message": "Ошибка сервера. Не удалось получить список автомобилей для тест драйва."
}
```

[**To table of contents**](#toyota-api)

---

### Get showrooms for test drive

**Path:** `get_showrooms_list_ftd.php`

**Params:**

- `brand_id` - app constant
- `city_id` - selected by user
- `service_id` - selected by user

#### **Success response**

```json
{
  "result": "ok",
  "showrooms": [
    {
      "id": "1",
      "showroom_name": "Тойота Центр Самара Юг"
    },
    {
      "id": "2",
      "showroom_name": "Тойота Центр Самара Север"
    }
  ]
}
```

#### **Failure response**

```json
{
  "error_code": "104",
  "error_message": "Ошибка сервера. Не удалось получить список автосалонов с выбранным для тест драйва автомобилем."
}
```

[**To table of contents**](#toyota-api)

---

### Book service

**Path:** `book_service.php`

**Params:**

- `user_id` - from memory
- `showroom_id` - selected by user
- `service_id` - selected by user (can vary for custom services -> see chains)
- `date_booking` - selected by user (optional)
- `start_booking` - selected by user (optional)
- `longitude` - got from a map (optional)
- `latitude` - got from a map (optional)

#### **Success response**

```json
{
  "result": "ok"
}
```

#### **Failure response**

```json
{
  "error_code": "104",
  "error_message": "different options"
}
```

[**To table of contents**](#toyota-api)

---

### Get managers

**Path:** `get_managers.php`

**Params:**

- `user_id` - from memory
- `brand_id` - app const

#### **Success response**

> **Notice**: `imageUrl` builds with [Base image URL](#general)

```json
{
  "result": "ok",
  "managers": [
    {
      id: "1",
      userId: "289",
      firstName: "Валерий",
      secondName: "Жма",
      lastName: "Абоба",
      phone: "+78005353535",
      email: "aboba@yandex.ua",
      imageUrl: ".../photoPath.img",
      showroomName: "Тойота Самара Юг"
    }
  ]
}
```

#### **Failure response**

```json
{
  "error_code": "101",
  "message": "Ошибка сервера."
}
```

[**To table of contents**](#toyota-api)

---

## Palette

```json
{
  "error_code": "100",
  "error_message": "Message"
}
```

```json
{
  "result": "ok"
}
```

| Code | Message |
|------|---------|
| 100 |  |

| Possible messages |
|------------------- |
| Message |
