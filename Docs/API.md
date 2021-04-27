# Toyota API

- [Toyota API](#toyota-api)
  - [General](#general)
  - [Testing](#testing)
    - [Cars VINs](#cars-vins)
  - [Requests](#requests)
    - [Сhecking user registration at application launch](#сhecking-user-registration-at-application-launch)
    - [Phone number registration](#phone-number-registration)
    - [SMS-code checking](#sms-code-checking)
    - [Profile creation](#profile-creation)
    - [City choosing](#city-choosing)
    - [Showroom setting](#showroom-setting)
    - [VIN checking](#vin-checking)
    - [Temp record deleting](#temp-record-deleting)
    - [Getting the categories of services](#getting-the-categories-of-services)
    - [Getting a services from a category](#getting-a-services-from-a-category)
    - [Getting free time](#getting-free-time)
    - [Adding new showroom](#adding-new-showroom)
    - [Editing profile](#editing-profile)
    - [Change phone number](#change-phone-number)
    - [Test Drive booking](#test-drive-booking)
  - [Deprecated](#deprecated)
    - [Showroom choosing](#showroom-choosing)
    - [Car checking](#car-checking)

---

## General

API uses **only POST** queries.

Base URL: http://cv39623.tmweb.ru/avtosalon/mobile/

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

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---

### Phone number registration

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---

### SMS-code checking

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---

### Profile creation

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---

### City choosing

**Path:** `get_showrooms.php`

**Params:**
 * `brand_id` - application const
 * `city_id`  - selected by user


**Success response:**

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

**Failure response:**

```json
{ 
  "result":"error_getting",
  "error_code":"101",
  "error_message":"Не найдено ни одного салона"
}
```

[**To table of contents**](#toyota-api)

---

### Showroom setting

**Path:** `set_showroom.php`

**Params:**
 * `user_id`  - got on previous step
 * `showroom_id` - selected by user

**Success response:**

**Variant 1:**
```json
{
  "result":"ok",
  "message":"Запись уже была создана ранее."
}
```

**Variant 2:**
```json
{
  "result":"ok",
  "message":"Новая запись успешно создана."
}
```

**Variant 3:**
```json
{
  "result":"ok",
  "message":"Запись успешно обновлена."
}
```

**Failure response:**

**Variant 1:** Server error (showroom clients query)
```json
{
  "result":"error_getting",
  "error_code":"121",
  "message":"Ошибка сервера. Не удалось проверить статус регистрации пользователя."
}
```

**Variant 2:** Server error (showroom clients query)
```json
{
  "result":"server_error",
  "error_code":"104",
  "message":"Ошибка сервера. Не удалось проверить список клиентов салона."
}
```

**Variant 3:** Server error (update record query)
```json
{
  "result":"server_error",
  "error_code":"104",
  "message":"Ошибка сервера. Не удалось обновить запись."
}
```

**Variant 4:** Server error (insert record query)
```json
{
  "result":"server_error",
  "error_code":"104",
  "message":"Ошибка сервера. Не удалось создать запись."
}
```

[**To table of contents**](#toyota-api)

---

### VIN checking

**Path:** `check_vin_code.php`

**Params:**
 * `skip_step` - **1**(skip this step)/**0**(enter vin code)
 * `user_id` - got on previous step
 * `showroom_id` - got on previous step
 * `vin_code` - entered by user

**Success response:**

**Variant 1:** VIN Checking
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

**Variant 2:** Skipping step
```json
{
  "result":"ok",
  "message":"Поздравляем! Вы успешно прошли регистрацию. Выбрать и подтвердить владение автомобилем Вы можете позже, в соответствующем разделе приложения.",
  "warning":"ВНИМАНИЕ! До выбора автомобиля, доступ в некоторые разделы приложения будет ограничен!"
}
```

**Failure response:**

**Variant 1:** Incorrect 
```json
{
  "result":"error_vin",
  "error_code":"107",
  "message":"VIN не подтвержден. Проверьте внимательно введённый vin-код и повторите попытку."
}
```

**Variant 2:** Car is already linked
```json
{
  "result":"error_select",
  "error_code":"108",
  "message":"Данный автомобиль уже привязан к Вашей учетной записи. Выберите другой автомобиль."
}
```
	
**Variant 3:** Car is already linked
```json
{
  "result":"error_select",
  "error_code":"108",
  "message":"Данный автомобиль уже выбран другим пользователем. Внимательно проверьте введённый Вами VIN-код - 1234567890abcdefg. Если введённый код верный - обратитесь в службу поддержки."
}
```

[**To table of contents**](#toyota-api)

---

### Temp record deleting

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---

### Getting the categories of services

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---

### Getting a services from a category

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---

### Getting free time

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---

### Adding new showroom

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---

### Editing profile

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---

### Change phone number

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---

### Test Drive booking

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---

## Deprecated

### Showroom choosing

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---

### Car checking

**Path:**

**Params:**
 * 1
 * 2

**Success response:**

**Failure response:**

[**To table of contents**](#toyota-api)

---
