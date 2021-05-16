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
      - [**Failure response**](#failure-response-2)
    - [Profile creation](#profile-creation)
      - [**Success response**](#success-response-3)
      - [**Failure response**](#failure-response-3)
    - [City choosing](#city-choosing)
      - [**Success response**](#success-response-4)
      - [**Failure response**](#failure-response-4)
    - [Showroom setting](#showroom-setting)
      - [**Success response**](#success-response-5)
        - [**Variant 1:**](#variant-1)
        - [**Variant 2:**](#variant-2)
        - [**Variant 3:**](#variant-3)
      - [**Failure response**](#failure-response-5)
        - [**Variant 1:** Server error (showroom clients query)](#variant-1-server-error-showroom-clients-query)
        - [**Variant 2:** Server error (showroom clients query)](#variant-2-server-error-showroom-clients-query)
        - [**Variant 3:** Server error (update record query)](#variant-3-server-error-update-record-query)
        - [**Variant 4:** Server error (insert record query)](#variant-4-server-error-insert-record-query)
    - [VIN checking](#vin-checking)
      - [**Success response**](#success-response-6)
        - [**Variant 1:** VIN Checking](#variant-1-vin-checking)
        - [**Variant 2:** Skipping step](#variant-2-skipping-step)
      - [**Failure response**](#failure-response-6)
        - [**Variant 1:** Incorrect](#variant-1-incorrect)
        - [**Variant 2:** Car is already linked](#variant-2-car-is-already-linked)
        - [**Variant 3:** Car is already linked](#variant-3-car-is-already-linked)
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
      - [**Failure response**](#failure-response-10)
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
    - [Car checking](#car-checking)
      - [**Success response**](#success-response-16)
      - [**Failure response**](#failure-response-16)

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

**Path:**

**Params:**

- 1
- 2

#### **Success response**

#### **Failure response**

[**To table of contents**](#toyota-api)

---

### SMS-code checking

**Path:**

**Params:**

- 1
- 2

#### **Success response**

#### **Failure response**

[**To table of contents**](#toyota-api)

---

### Profile creation

**Path:**

**Params:**

- 1
- 2

#### **Success response**

#### **Failure response**

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

##### **Variant 1:**

```json
{
  "result":"ok",
  "message":"Запись уже была создана ранее."
}
```

##### **Variant 2:**

```json
{
  "result":"ok",
  "message":"Новая запись успешно создана."
}
```

##### **Variant 3:**

```json
{
  "result":"ok",
  "message":"Запись успешно обновлена."
}
```

#### **Failure response**

##### **Variant 1:** Server error (showroom clients query)

```json
{
  "error_code":"121",
  "message":"Ошибка сервера. Не удалось проверить статус регистрации пользователя."
}
```

##### **Variant 2:** Server error (showroom clients query)

```json
{
  "error_code":"104",
  "message":"Ошибка сервера. Не удалось проверить список клиентов салона."
}
```

##### **Variant 3:** Server error (update record query)

```json
{
  "error_code":"104",
  "message":"Ошибка сервера. Не удалось обновить запись."
}
```

##### **Variant 4:** Server error (insert record query)

```json
{
  "error_code":"104",
  "message":"Ошибка сервера. Не удалось создать запись."
}
```

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

##### **Variant 1:** Incorrect

```json
{
  "error_code":"107",
  "message":"VIN не подтвержден. Проверьте внимательно введённый vin-код и повторите попытку."
}
```

##### **Variant 2:** Car is already linked

```json
{
  "error_code":"108",
  "message":"Данный автомобиль уже привязан к Вашей учетной записи. Выберите другой автомобиль."
}
```

##### **Variant 3:** Car is already linked

```json
{
  "error_code":"108",
  "message":"Данный автомобиль уже выбран другим пользователем. Внимательно проверьте введённый Вами VIN-код - 1234567890abcdefg. Если введённый код верный - обратитесь в службу поддержки."
}
```

[**To table of contents**](#toyota-api)

---

### Temp record deleting

**Path:**

**Params:**

- 1
- 2

#### **Success response**

#### **Failure response**

[**To table of contents**](#toyota-api)

---

### Getting the categories of services

**Path:**

**Params:**

- 1
- 2

#### **Success response**

#### **Failure response**

[**To table of contents**](#toyota-api)

---

### Getting a services from a category

**Path:**

**Params:**

- 1
- 2

#### **Success response**

#### **Failure response**

[**To table of contents**](#toyota-api)

---

### Getting free time

**Path:**

**Params:**

- 1
- 2

#### **Success response**

#### **Failure response**

[**To table of contents**](#toyota-api)

---

### Adding new showroom

**Path:**

**Params:**

- 1
- 2

#### **Success response**

#### **Failure response**

[**To table of contents**](#toyota-api)

---

### Editing profile

**Path:**

**Params:**

- 1
- 2

#### **Success response**

#### **Failure response**

[**To table of contents**](#toyota-api)

---

### Change phone number

**Path:**

**Params:**

- 1
- 2

#### **Success response**

#### **Failure response**

[**To table of contents**](#toyota-api)

---

### Test Drive booking

**Path:**

**Params:**

- 1
- 2

#### **Success response**

#### **Failure response**

[**To table of contents**](#toyota-api)

---

## Deprecated

### Showroom choosing

**Path:**

**Params:**

- 1
- 2

#### **Success response**

#### **Failure response**

[**To table of contents**](#toyota-api)

---

### Car checking

**Path:**

**Params:**

- 1
- 2

#### **Success response**

#### **Failure response**

[**To table of contents**](#toyota-api)

---
