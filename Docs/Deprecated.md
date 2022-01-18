# Toyota API

## Deprecated methods

### Showroom choosing

**Path:** `get_cars.php`

**Params:**

- `showroom_id` - selected by user
- `user_id` - got on previous step

#### **Success response**

```json
{
  "result": "ok",
  "cars": [
    {
      "id": "3",
      "car_brand_name": "Toyota",
      "car_model_name": "Prado",
      "color_swatch": "#edf5f6",
      "car_color_name": "Айсберг",
      "color_description": "Белая двухслойная",
      "color_metallic": "1",
      "license_plate": "а111аа163rus"
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
  "error_code": "101",
  "error_message": "Ошибка сервера. Не удалось получить список автомобилей."
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
  "result": "ok",
  "message": "Запись уже была создана ранее."
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
  "error_code": "121",
  "message": "Ошибка сервера."
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
  "result": "ok",
  "car":
    {
      "id": "1",
      "car_brand_name": "Toyota",
      "car_model_name": "RAV4",
      "color_swatch": "#cc6633",
      "car_color_name": "Абрикос",
      "color_description": "Серебристо-светло оранжевый",
      "color_metallic": "1",
      "license_plate": "а001аа163rus"
    },
  "message": "Поздравляем! Вы успешно подтвердили владение данным автомобилем. Теперь он появится в списке Ваших авто."
}
```

##### **Variant 2:** Skipping step

```json
{
  "result": "ok",
  "message": "Поздравляем! Вы успешно прошли регистрацию. Выбрать и подтвердить владение автомобилем Вы можете позже, в соответствующем разделе приложения.",
  "warning": "ВНИМАНИЕ! До выбора автомобиля, доступ в некоторые разделы приложения будет ограничен!"
}
```

#### **Failure response**

```json
{
  "error_code": "107",
  "message": "Ошибка"
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