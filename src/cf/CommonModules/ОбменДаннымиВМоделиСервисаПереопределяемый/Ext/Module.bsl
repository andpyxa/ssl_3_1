﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Определяет версию приложения 1С:Предприятия, которая требуется для работы автономного рабочего
// места. Приложение этой версии должно быть установлено на локальном компьютере пользователя.
// Если возвращаемое значение функции не задано, то в качестве требуемой версии приложения
// будет использоваться значение по умолчанию: первые три цифры версии текущего приложения,
// расположенного в Интернете, например, "8.3.3".
// Используется в помощнике создания автономного рабочего места.
//
// Параметры:
//	Версия - Строка - Версия требуемого приложения 1С:Предприятия в формате
//	                  "<основная версия>.<младшая версия>.<релиз>.<дополнительный номер релиза>".
//	                  Например, "8.3.3.715".
//
Процедура ПриОпределенииТребуемойВерсииПриложения(Версия) Экспорт
	
КонецПроцедуры

// Вызывается в момент начала создания пользователем автономного рабочего места.
// В обработчиках события могут быть реализованы дополнительные проверки возможности
// создания автономного рабочего места (при невозможности - сгенерировано исключение).
//
Процедура ПриСозданииАвтономногоРабочегоМеста() Экспорт
	
	
	
КонецПроцедуры

#КонецОбласти