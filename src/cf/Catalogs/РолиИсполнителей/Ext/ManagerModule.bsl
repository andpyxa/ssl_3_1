﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// Возвращает реквизиты объекта, которые не рекомендуется редактировать
// с помощью обработки группового изменения реквизитов.
//
// Возвращаемое значение:
//  Массив Из Строка -
Функция РеквизитыНеРедактируемыеВГрупповойОбработке() Экспорт
	
	Результат = Новый Массив;
	
	Результат.Добавить("КраткоеПредставление");
	Результат.Добавить("Комментарий");
	Результат.Добавить("ВнешняяРоль");
	Результат.Добавить("УзелОбмена");
	
	Возврат Результат
КонецФункции

// Конец СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// Заполнение предопределенных элементов

#КонецОбласти

#КонецОбласти

#КонецЕсли

#Область ОбработчикиСобытий

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Процедура ОбработкаПолученияДанныхВыбора(ДанныеВыбора, Параметры, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если Пользователи.ЭтоСеансВнешнегоПользователя() Тогда
		ТекущийПользователь = ВнешниеПользователи.ТекущийВнешнийПользователь();
		ОбъектАвторизации = Справочники[ТекущийПользователь.ОбъектАвторизации.Метаданные().Имя].ПустаяСсылка();
	Иначе
		ОбъектАвторизации = Справочники.Пользователи.ПустаяСсылка();
	КонецЕсли;
	
	ТекстПоискаДляДополнительныхЯзыков = "";
	Если МультиязычностьСервер.ИспользуетсяПервыйДополнительныйЯзык() Тогда
		ТекстПоискаДляДополнительныхЯзыков  = " ИЛИ РолиИсполнителей.НаименованиеЯзык1 ПОДОБНО &СтрокаПоиска";
	КонецЕсли;
	
	Если МультиязычностьСервер.ИспользуетсяПервыйДополнительныйЯзык() Тогда
		ТекстПоискаДляДополнительныхЯзыков  = ТекстПоискаДляДополнительныхЯзыков 
			+ " ИЛИ РолиИсполнителей.НаименованиеЯзык2 ПОДОБНО &СтрокаПоиска";
	КонецЕсли;
	
	Если МультиязычностьСервер.ИспользуетсяВторойДополнительныйЯзык() Тогда
		СуффиксЯзыка = МультиязычностьСервер.СуффиксТекущегоЯзыка();
	КонецЕсли;
	
	ТекстЗапроса = "ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 20
		|	РолиИсполнителей.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.РолиИсполнителей.Назначение КАК РолиИсполнителейНазначение
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.РолиИсполнителей КАК РолиИсполнителей
		|		ПО РолиИсполнителейНазначение.Ссылка = РолиИсполнителей.Ссылка
		|ГДЕ
		|	РолиИсполнителейНазначение.ТипПользователей = &Тип
		|	И (РолиИсполнителей.Наименование ПОДОБНО &СтрокаПоиска " + ТекстПоискаДляДополнительныхЯзыков + "
		|			ИЛИ РолиИсполнителей.Код ПОДОБНО &СтрокаПоиска)
		|	И НЕ РолиИсполнителей.Ссылка ЕСТЬ NULL";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	
	Запрос.УстановитьПараметр("Тип",          ОбъектАвторизации);
	Запрос.УстановитьПараметр("СтрокаПоиска", "%" + Параметры.СтрокаПоиска + "%");
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	ДанныеВыбора = Новый СписокЗначений;
	Пока РезультатЗапроса.Следующий() Цикл
		ДанныеВыбора.Добавить(РезультатЗапроса.Ссылка, РезультатЗапроса.Ссылка);
	КонецЦикла;
	
КонецПроцедуры

#КонецЕсли

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	
	МультиязычностьКлиентСервер.ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка);
	
КонецПроцедуры

Процедура ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка)
	
	МультиязычностьКлиентСервер.ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка);
	
КонецПроцедуры

#КонецОбласти

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

Процедура ПриНастройкеНачальногоЗаполненияЭлементов(Настройки) Экспорт
	
	Настройки.ПриНачальномЗаполненииЭлемента = Истина;
	
КонецПроцедуры

// Вызывается при начальном заполнении справочника РолиИсполнителей.
//
// Параметры:
//  КодыЯзыков - Массив - список языков конфигурации. Актуально для мультиязычных конфигураций.
//  Элементы   - ТаблицаЗначений - данные заполнения. Состав колонок соответствует набору реквизитов
//                                 справочника РолиИсполнителей.
//  ТабличныеЧасти - Структура - описание табличных частей объекта, где:
//   * Ключ - Строка - имя табличной части;
//   * Значение - ТаблицаЗначений - табличная часть в виде таблицы значений, структуру которой
//                                  необходимо скопировать перед заполнением. Например:
//                                  Элемент.Ключи = ТабличныеЧасти.Ключи.Скопировать();
//                                  ЭлементТЧ = Элемент.Ключи.Добавить();
//                                  ЭлементТЧ.ИмяКлюча = "Первичный";
//
Процедура ПриНачальномЗаполненииЭлементов(КодыЯзыков, Элементы, ТабличныеЧасти) Экспорт
	
	Элемент = Элементы.Добавить();
	Элемент.ИмяПредопределенныхДанных = "ОтветственныйЗаКонтрольИсполнения";
	МультиязычностьСервер.ЗаполнитьМультиязычныйРеквизит(Элемент, "Наименование",
		"ru='Координатор выполнения задач'", КодыЯзыков); // @НСтр
	Элемент.ИспользуетсяБезОбъектовАдресации = Истина;
	Элемент.ИспользуетсяСОбъектамиАдресации  = Истина;
	Элемент.ВнешняяРоль                      = Ложь;
	Элемент.Код                              = "000000001";
	Элемент.КраткоеПредставление             = НСтр("ru = '000000001'");
	Элемент.ТипыОсновногоОбъектаАдресации = ПланыВидовХарактеристик.ОбъектыАдресацииЗадач.ВсеОбъектыАдресации;
	
	Элемент.Назначение = ТабличныеЧасти.Назначение.Скопировать();
	ЭлементТЧ = Элемент.Назначение.Добавить();
	ЭлементТЧ.ТипПользователей = Справочники.Пользователи.ПустаяСсылка();
	
	БизнесПроцессыИЗадачиПереопределяемый.ПриНачальномЗаполненииРолейИсполнителей(КодыЯзыков, Элементы, ТабличныеЧасти);
	
КонецПроцедуры

// Вызывается РолиИсполнителей при начальном заполнении создаваемой роли исполнителя.
//
// Параметры:
//  Объект                  - СправочникОбъект.РолиИсполнителей - заполняемый объект.
//  Данные                  - СтрокаТаблицыЗначений - данные заполнения.
//  ДополнительныеПараметры - Структура - Дополнительные параметры.
//
Процедура ПриНачальномЗаполненииЭлемента(Объект, Данные, ДополнительныеПараметры) Экспорт
	
	БизнесПроцессыИЗадачиПереопределяемый.ПриНачальномЗаполненииРолиИсполнителя(Объект, Данные, ДополнительныеПараметры);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Регистрирует к обработке в обработчике обновления
//
Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	МультиязычностьСервер.ЗарегистрироватьПредопределенныеЭлементыДляОбновления(Параметры, Метаданные.Справочники.РолиИсполнителей);
	
КонецПроцедуры

Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	МультиязычностьСервер.ОбновитьПредставленияПредопределенныхЭлементов(Параметры, Метаданные.Справочники.РолиИсполнителей);
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
