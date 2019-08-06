# File Sharing contract

Этот контракт контролирует доступ к пользовательским файлам по whitelist, owner и KYC.

| Поле | Тип | Ключевые слова | Описание |
|---|---|---|---|
| `contractKYC` | `KYC` | `public` | Объект KYC контракта для проверки авторизации |
| `files` | `mapping(bytes32 => FileInfo)` | `public` | Маппинг адресов файлов на информацию о них |

| Модификатор | Принимаемые значения | Описание |
|---|---|---|
| `onlyOwner` | `bytes32 fileID` - идентификатор файла | Модификатор доступа "только для владельца" |

| Метод | Возвращаемое значение | Аргументы | Ключевые слова | Описание |
|---|---|---|---|---|
| `constructor` | -//- | `address KYCAddress` - адрес KYC контракта | `public` | Конструктор контракта |
| `addFile` | -//- | `bytes32 fileID` - идентификатор нового файла, `bool isKYCNeeded` - флаг для проверки KYC у пользователей из whitelist файла | `public` | Метод для добавления нового файла |
| `addFile` | -//- | `bytes32 fileID` - идентификатор нового файла, `address[] memory accounts` - whitelist файла, `bool isKYCNeeded` - флаг для проверки KYC у пользователей из whitelist файла | `public` | Перегрузка метода addFile с whitelist файла |
| `addAccess` | -//- | `bytes32 fileID` - идентификатор файла, `address[] memory accounts` - новые аккаунты для whitelist файла | `public` | Метод для выдачи пользователям доступа к файлу |
| `removeAccess` | -//- | `bytes32 fileID` - идентификатор файла, `address[] memory accounts` - аккаунты, которые нужно удалить из whitelist | `public` | Метод для лишения пользователей доступа к файлу |
| `checkAccess` | `bool` | `bytes32 fileID` - идентификатор файла, `address account` - аккаунт, у которого проверяется наличие доступа к файлу | `public view` | Метод для проверки доступа к файлу у пользователя |

