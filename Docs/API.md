# Toyota API

<details> <summary>Table of contents</summary>

- [Toyota API](#toyota-api)
  - [General](#general)
  - [Testing](#testing)
    - [Cars VINs](#cars-vins)
  - [Requests](#requests)
    - [Сhecking user registration at application launch](#сhecking-user-registration-at-application-launch)
      - [**Success response**](#success-response)
        - [**Variant 1:** Only phone number checking](#variant-1-only-phone-number-checking)
        - [**Variant 2:** Only profile is selected](#variant-2-only-profile-is-selected)
        - [**Variant 3:** Profile and showroom are selected](#variant-3-profile-and-showroom-are-selected)
        - [**Variant 4:** Fully registered and authorized on device](#variant-4-fully-registered-and-authorized-on-device)
      - [**Failure response**](#failure-response)
    - [Phone number registration](#phone-number-registration)
      - [**Success response**](#success-response-1)
      - [**Failure response**](#failure-response-1)
    - [SMS-code checking](#sms-code-checking)
      - [**Success response**](#success-response-2)
        - [**Variant 1:** New account](#variant-1-new-account)
        - [**Variant 2:** Empty account](#variant-2-empty-account)
        - [**Variant 3:** Only profile](#variant-3-only-profile)
        - [**Variant 4:** Profile and showroom](#variant-4-profile-and-showroom)
        - [**Variant 5:** Full profile](#variant-5-full-profile)
      - [**Failure response**](#failure-response-2)
    - [Profile creation](#profile-creation)
      - [**Success response**](#success-response-3)
      - [**Failure response**](#failure-response-3)
        - [**List of errors**](#list-of-errors)
    - [City choosing](#city-choosing)
      - [**Success response**](#success-response-4)
      - [**Failure response**](#failure-response-4)
    - [Showroom setting](#showroom-setting)
      - [**Success response**](#success-response-5)
      - [**Failure response**](#failure-response-5)
        - [**List of errors**](#list-of-errors-1)
    - [VIN checking](#vin-checking)
      - [**Success response**](#success-response-6)
        - [**Variant 1:** VIN Checking](#variant-1-vin-checking)
        - [**Variant 2:** Skipping step](#variant-2-skipping-step)
      - [**Failure response**](#failure-response-6)
        - [**List of errors**](#list-of-errors-2)
    - [Temp record deleting](#temp-record-deleting)
      - [**Success response**](#success-response-7)
      - [**Failure response**](#failure-response-7)
    - [Getting the categories of services](#getting-the-categories-of-services)
      - [**Success response**](#success-response-8)
      - [**Failure response**](#failure-response-8)
    - [Getting a services from a category](#getting-a-services-from-a-category)
      - [**Success response**](#success-response-9)
      - [**Failure response**](#failure-response-9)
    - [Getting free time](#getting-free-time)
      - [**Success response**](#success-response-10)
        - [**Variant 1:** Anytime](#variant-1-anytime)
        - [**Variant 2:** Time limits](#variant-2-time-limits)
      - [**Failure response**](#failure-response-10)
        - [**List of errors**](#list-of-errors-3)
    - [Adding new showroom](#adding-new-showroom)
      - [**Success response**](#success-response-11)
      - [**Failure response**](#failure-response-11)
    - [Editing profile](#editing-profile)
      - [**Success response**](#success-response-12)
      - [**Failure response**](#failure-response-12)
    - [Change phone number](#change-phone-number)
      - [**Success response**](#success-response-13)
      - [**Failure response**](#failure-response-13)
    - [Test Drive booking](#test-drive-booking)
      - [**Success response**](#success-response-14)
      - [**Failure response**](#failure-response-14)
  - [Deprecated](#deprecated)
    - [Showroom choosing](#showroom-choosing)
      - [**Success response**](#success-response-15)
      - [**Failure response**](#failure-response-15)

</details>

---

## General

API uses **only POST** queries.

Base URL: <http://cv39623.tmweb.ru/avtosalon/mobile/>

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

### Сhecking user registration at application launch

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

### SMS-code checking

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

### Profile creation

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

### City choosing

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

### Showroom setting

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

### VIN checking

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

### Temp record deleting

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

### Getting the categories of services

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

### Getting a services from a category

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

### Getting free time

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

### Adding new showroom

**Path:** `get_cities.php, get_showrooms.php, add_showroom.php`

**Params:**

- `brand_id` - app constant

#### **Success response**

```json
```

#### **Failure response**

```json
```

[**To table of contents**](#toyota-api)

---

### Editing profile

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

### Change phone number

**Path:** `register_phone.php, change_phone_number.php`

**Params:**

- `user_id` - from memory
- `code` - got via SMS
- `phone_number` - written by user

#### **Success response**

```json
```

#### **Failure response**

```json
```

[**To table of contents**](#toyota-api)

---

### Test Drive booking

**Path:** `get_cities.php, get_cars_ftd.php, get_showrooms_list_ftd.php, get_service_id.php, get_free_time.php, book_service.php`

**Params:**

- `brand_id` - app constant
- `city_id` - selected by user

#### **Success response**

```json
```

#### **Failure response**

```json
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
