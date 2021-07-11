# Toyota API

<details> <summary>Table of contents</summary>

- [Toyota API](#toyota-api)
  - [General](#general)
    - [Services controllers types](#services-controllers-types)
  - [Testing](#testing)
    - [Cars VINs](#cars-vins)
  - [Requests](#requests)
    - [Сheck user registration at application launch](#сheck-user-registration-at-application-launch)
      - [**Success response**](#success-response)
        - [**Variant 1:** Only phone number checking](#variant-1-only-phone-number-checking)
        - [**Variant 2:** Only profile is selected](#variant-2-only-profile-is-selected)
        - [**Variant 3:** Profile and showroom are selected](#variant-3-profile-and-showroom-are-selected)
        - [**Variant 4:** Fully registered and authorized on device](#variant-4-fully-registered-and-authorized-on-device)
      - [**Failure response**](#failure-response)
    - [Phone number registration](#phone-number-registration)
      - [**Success response**](#success-response-1)
      - [**Failure response**](#failure-response-1)
    - [Check SMS-code](#check-sms-code)
      - [**Success response**](#success-response-2)
        - [**Variant 1:** New account](#variant-1-new-account)
        - [**Variant 2:** Empty account](#variant-2-empty-account)
        - [**Variant 3:** Only profile](#variant-3-only-profile)
        - [**Variant 4:** Profile and showroom](#variant-4-profile-and-showroom)
        - [**Variant 5:** Full profile](#variant-5-full-profile)
      - [**Failure response**](#failure-response-2)
    - [Set pofile data](#set-pofile-data)
      - [**Success response**](#success-response-3)
      - [**Failure response**](#failure-response-3)
        - [**List of errors**](#list-of-errors)
    - [Get showrooms (for brand & city)](#get-showrooms-for-brand--city)
      - [**Success response**](#success-response-4)
      - [**Failure response**](#failure-response-4)
    - [Set showroom](#set-showroom)
      - [**Success response**](#success-response-5)
      - [**Failure response**](#failure-response-5)
        - [**List of errors**](#list-of-errors-1)
    - [Check VIN-code](#check-vin-code)
      - [**Success response**](#success-response-6)
        - [**Variant 1:** VIN Checking](#variant-1-vin-checking)
        - [**Variant 2:** Skipping step](#variant-2-skipping-step)
      - [**Failure response**](#failure-response-6)
        - [**List of errors**](#list-of-errors-2)
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
        - [**List of errors**](#list-of-errors-3)
    - [Adding new showroom chain](#adding-new-showroom-chain)
    - [Get cities](#get-cities)
      - [**Success response**](#success-response-11)
      - [**Failure response**](#failure-response-11)
    - [Add new showroom](#add-new-showroom)
      - [**Success response**](#success-response-12)
      - [**Failure response**](#failure-response-12)
    - [Edit profile data](#edit-profile-data)
      - [**Success response**](#success-response-13)
      - [**Failure response**](#failure-response-13)
    - [Change phone number chain](#change-phone-number-chain)
    - [Change phone](#change-phone)
      - [**Success response**](#success-response-14)
      - [**Failure response**](#failure-response-14)
    - [Test Drive booking chain](#test-drive-booking-chain)
    - [Get cars for test drive](#get-cars-for-test-drive)
      - [**Success response**](#success-response-15)
      - [**Failure response**](#failure-response-15)
    - [Get showrooms for test drive](#get-showrooms-for-test-drive)
      - [**Success response**](#success-response-16)
      - [**Failure response**](#failure-response-16)
    - [Get service id](#get-service-id)
      - [**Success response**](#success-response-17)
      - [**Failure response**](#failure-response-17)
    - [Book service](#book-service)
      - [**Success response**](#success-response-18)
      - [**Failure response**](#failure-response-18)
    - [Get managers](#get-managers)
      - [**Success response**](#success-response-19)
      - [**Failure response**](#failure-response-19)
  - [Deprecated](#deprecated)
    - [Showroom choosing](#showroom-choosing)
      - [**Success response**](#success-response-20)
      - [**Failure response**](#failure-response-20)

</details>

---

## General

API uses **only POST** queries.

Base URL: <http://cv39623.tmweb.ru/avtosalon/mobile/>

### Services controllers types

| Id | Control type description | List of services |
|----|--------------------------|------------------|
| 0 | not defined |  |
| 1 | timepick |  |
| 2 | map | Помощь на дороге |
| 3 | 1 question |  |
| 4 | 2 questions |  |
| 5 | 3 questions |  |
| 6 | 1 question + timepick | Сервисное обслуживание |
| 7 | 2 questions + timepick |  |
| 8 | 3 questions + timepick | Тест драйв |
| 9 | 1 question + map |  |
| 10 | 2 questions + map |  |
| 11 | 3 questions + map |  |
| 12 | 1 question + timepick + map |  |
| 13 | 2 questions + timepick + map |  |
| 14 | 3 questions + timepick + map |  |

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
  "result":"ok",
  "secret_key":"generated secret key",
  "register_page":1
}
```

##### **Variant 2:** Only profile is selected

```json
{
  "result":"ok",
  "secret_key":"generated secret key",
  "register_page":2,
  "registered_user":
    {
      "profile":
        {
          "first_name":"Иван",
          "second_name":"Иваныч",
          "last_name":"Иванов",
          "phone":"8 909 111-11-11",
          "email":"email@email.com",
          "birthday":"2020-08-01"
        }
    },
  "cities": [
    {
      "id":"1",
      "city_name":"Самара"
    },
    {
      "id":"2",
      "city_name":"Тольятти"
    }
  ]
}
```

##### **Variant 3:** Profile and showroom are selected

```json
{
  "result":"ok",
  "secret_key":"generated secret key",
  "register_page":3,
  "registered_user":
    {
      "profile":
        {
          "first_name":"Иван",
          "second_name":"Иваныч",
          "last_name":"Иванов",
          "phone":"8 909 111-11-11",
          "email":"email@email.com",
          "birthday":"2020-08-01"
        },
      "showroom": [
        {
          "id":"1",
          "showroom_name":"Тойота Центр Самара Юг",
          "city_name":"Самара"
        }
      ]
    },
  "cities": [
    {
      "id":"1",
      "city_name":"Самара"
    },
    {
      "id":"2",
      "city_name":"Тольятти"
    }
  ]
}
```

##### **Variant 4:** Fully registered and authorized on device

```json
{
  "result":"ok",
  "secret_key":"generated secret key",
  "register_status":1
}
```

#### **Failure response**

```json
{
  "error_code":"101",
  "error_message":"Пользователь отсутствует в базе"
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
  "result":"ok"
}
```

#### **Failure response**

```json
{
  "error_code":"",
  "error_message":""
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
  "result":"ok",
  "user_id":"generated_id",
  "secret_key":"generated_secret_key"
}
```

##### **Variant 2:** Empty account

```json
{
  "result":"ok",
  "secret_key":"generated secret key",
  "user_id":"user id",
  "register_page":1
}
```

##### **Variant 3:** Only profile

**[Look there](#variant-2-only-profile-is-selected)**

##### **Variant 4:** Profile and showroom

**[Look there](#variant-3-profile-and-showroom-are-selected)**

##### **Variant 5:** Full profile

**[Look there](#variant-4-fully-registered-and-authorized-on-device)**

plus addiotional field:

```json
  "register_status":1
```

#### **Failure response**

```json
{
  "error_code":"102",
  "error_message":"Присланный Вами код не совпадает"
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

#### **Failure response**

```json
{
  "error_code":"103",
  "error_message":"Ошибка сервера."
}
```

##### **List of errors**

| Code | Message |
|------|---------|
| 101 | Не удалось получить список городов. |
| 103 | Не удалось заполнить профиль пользователя. |

[**To table of contents**](#toyota-api)

---

### Get showrooms (for brand & city)

**Path:** `get_showrooms.php`

**Params:**

- `brand_id` - application const
- `city_id`  - selected by user

#### **Success response**

```json
{
  "result":"ok",
  "showrooms": [
    {
      "id":"1",
      "showroom_name":"Тойота Центр Самара Юг"
    },
    {
      "id":"2",
      "showroom_name":"Тойота Центр Самара Север"
    },
    {
      "id":"7",
      "showroom_name":"Тойота Центр Самара Аврора"
    }
  ]
} 
```

#### **Failure response**

```json
{
  "error_code":"101",
  "error_message":"Не найдено ни одного салона"
}
```

[**To table of contents**](#toyota-api)

---

### Set showroom

**Path:** `set_showroom.php`

**Params:**

- `user_id`  - got on previous step
- `showroom_id` - selected by user

#### **Success response**

```json
{
  "result":"ok",
  "message":"Запись уже была создана ранее."
}
```

| Possible messages |
|------------------- |
| Запись уже была создана ранее. |
| Новая запись успешно создана. |
| Запись успешно обновлена. |

#### **Failure response**

```json
{
  "error_code":"121",
  "message":"Ошибка сервера."
}
```

##### **List of errors**

| Code | Message |
|------|---------|
| 104 | Не удалось проверить список клиентов салона. |
| 104 | Не удалось обновить запись. |
| 104 | Не удалось создать запись. |
| 121 | Не удалось проверить статус регистрации пользователя. |

[**To table of contents**](#toyota-api)

---

### Check VIN-code

**Path:** `check_vin_code.php`

**Params:**

- `skip_step` - **1**(skip this step)/**0**(enter vin code)
- `user_id` - got on previous step
- `showroom_id` - got on previous step
- `vin_code` - entered by user

#### **Success response**

##### **Variant 1:** VIN Checking

```json
{
  "result":"ok",
  "car":
    {
      "id":"1",
      "car_brand_name":"Toyota",
      "car_model_name":"RAV4",
      "color_swatch":"#cc6633",
      "car_color_name":"Абрикос",
      "color_description":"Серебристо-светло оранжевый",
      "color_metallic":"1",
      "license_plate":"а001аа163rus"
    },
  "message":"Поздравляем! Вы успешно подтвердили владение данным автомобилем. Теперь он появится в списке Ваших авто."
}
```

##### **Variant 2:** Skipping step

```json
{
  "result":"ok",
  "message":"Поздравляем! Вы успешно прошли регистрацию. Выбрать и подтвердить владение автомобилем Вы можете позже, в соответствующем разделе приложения.",
  "warning":"ВНИМАНИЕ! До выбора автомобиля, доступ в некоторые разделы приложения будет ограничен!"
}
```

#### **Failure response**

```json
{
  "error_code":"107",
  "message":"Ошибка"
}
```

##### **List of errors**

| Code | Message |
|------|---------|
| 107 | VIN не подтвержден. Проверьте внимательно введённый vin-код и повторите попытку. |
| 108 | Данный автомобиль уже привязан к Вашей учетной записи. Выберите другой автомобиль. |
| 108 | Данный автомобиль уже выбран другим пользователем. Внимательно проверьте введённый Вами VIN-код - 1234567890abcdefg. Если введённый код верный - обратитесь в службу поддержки. |

[**To table of contents**](#toyota-api)

---

### Delete temp phone

**Path:** `delete_tmp_record.php`

**Params:**

- `phone_number` - got on [phone register step](#phone-number-registration)

#### **Success response**

```json
{
  "result":"ok"
}
```

#### **Failure response**

```json
{
  "error_code":"108",
  "message":"Ошибка сервера. Не удалось удалить временную запись."
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
  "result":"ok",
  "service_type": [
    {
      "id":"1",
      "service_type_name":"Сервисное обслуживание",
      "control_type_id":"0",
      "control_type_name":"Тип № 0",
      "control_type_desc":"Тип контроллера не выбран"
    },
    {
      "id":"2",
      "service_type_name":"Услуги сервиса",
      "control_type_id":"0",
      "control_type_name":"Тип № 0",
      "control_type_desc":"Тип контроллера не выбран"
    }
  ]
}
```

#### **Failure response**

```json
{
  "error_code":"101",
  "message":"Ошибка сервера. Не удалось получить список категорий услуг."
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
  "result":"ok",
  "services": [
    {
      "id":"1",
      "service_name":"Плановое ТО №1"
    },
    {
      "id":"2",
      "service_name":"Плановое ТО №2"
    }
  ]
}
```

#### **Failure response**

```json
{
  "error_code":"101",
  "message":"Ошибка сервера. Не удалось получить список услуг."
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
  "result":"ok",
  "message":"Время бронирования свободно на любую дату"
}
```

##### **Variant 2:** Time limits

```json
{
  "result":"ok",
  "start_date":"2020-12-22",
  "end_date":"2020-12-23",
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
  "error_code":"104",
  "message":"Ошибка сервера"
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

### Adding new showroom chain

**Request chain:** [Get cities](#get-cities) --> [Get showrooms](#city-choosing) --> [Add showroom](#add-new-showroom)

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
  "error_code":"101",
  "error_message":"Ошибка сервера. Не удалось получить список городов."
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
  "result":"ok",
  "message":"Данный салон теперь появится в списке Ваших салонов."
}
```

#### **Failure response**

```json
{
  "error_code":"101",
  "error_message":"Ошибка сервера."
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
  "result":"ok"
}
```

#### **Failure response**

```json
{
  "error_code":"101",
  "error_message":"Ошибка сервера. Не удалось обновить профиль пользователя."
}
```

[**To table of contents**](#toyota-api)

---

### Change phone number chain

**Request chain:** [Register phone](#phone-number-registration) --> [Change phone](#change-phone)

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
  "result":"ok"
}
```

#### **Failure response**

```json
{
  "error_code":"104",
  "error_message":"Ошибка сервера. Не удалось обновить номер телефона."
}
```

[**To table of contents**](#toyota-api)

---

### Test Drive booking chain

**Request chain:** [Get cities](#get-cities) --> [Get cars fot test drive](#get-cars-for-test-drive) --> [Get showrooms for test drive](#get-showrooms-for-test-drive) --> [Get service id](#get-service-id) --> [Get free time](#getting-free-time) --> [Book service](#book-service)

---

### Get cars for test drive

**Path:** `get_cars_ftd.php`

**Params:**

- `brand_id` - app constant
- `city_id` - got (selected by user) on [previous step](#get-cities)

#### **Success response**

```json
{
  "result":"ok",
  "cars": [
    {
      "id":"9",
      "service_name":"Тойота LC 200"
    },
    {
      "id":"10",
      "service_name":"Тойота Camry"
    }
  ]
}
```

#### **Failure response**

```json
{
  "error_code":"104",
  "error_message":"Ошибка сервера. Не удалось получить список автомобилей для тест драйва."
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
  "result":"ok",
  "showrooms": [
    {
      "id":"1",
      "showroom_name":"Тойота Центр Самара Юг"
    },
    {
      "id":"2",
      "showroom_name":"Тойота Центр Самара Север"
    }
  ]
}
```

#### **Failure response**

```json
{
  "error_code":"104",
  "error_message":"Ошибка сервера. Не удалось получить список автосалонов с выбранным для тест драйва автомобилем."
}
```

[**To table of contents**](#toyota-api)

---

### Get service id

**Path:** `get_service_id.php`

**Params:**

- `showroom_id` - selected by user
- `sid` - selected by user

#### **Success response**

```json
{
  "result":"ok",
  "service_id":"24"
}
```

#### **Failure response**

```json
{
  "error_code":"104",
  "error_message":"Ошибка сервера. Не удалось получить id услуги в выбранном автосалоне."
}
```

[**To table of contents**](#toyota-api)

---

### Book service

**Path:** `book_service.php`

**Params:**

- `user_id` - from memory
- `showroom_id` - selected by user
- `service_id` - selected by user
- `date_booking` - selected by user
- `start_booking` - selected by user

#### **Success response**

```json
{
  "result":"ok"
}
```

#### **Failure response**

```json
{
  "error_code":"104",
  "error_message":"different options"
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

```json
{
  "result":"ok",
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
  "error_code":"101",
  "message":"Ошибка сервера."
}
```

[**To table of contents**](#toyota-api)

---

## Deprecated

### Showroom choosing

**Path:** `get_cars.php`

**Params:**

- `showroom_id` - selected by user
- `user_id` - got on previous step

#### **Success response**

```json
{
  "result":"ok",
  "cars": [
    {
      "id":"3",
      "car_brand_name":"Toyota",
      "car_model_name":"Prado",
      "color_swatch":"#edf5f6",
      "car_color_name":"Айсберг",
      "color_description":"Белая двухслойная",
      "color_metallic":"1",
      "license_plate":"а111аа163rus"
    },
    {
      ...
    }
  ]
}
```

#### **Failure response**

```json
{
  "error_code":"101",
  "error_message":"Ошибка сервера. Не удалось получить список автомобилей."
}
```

[**To table of contents**](#toyota-api)

---
