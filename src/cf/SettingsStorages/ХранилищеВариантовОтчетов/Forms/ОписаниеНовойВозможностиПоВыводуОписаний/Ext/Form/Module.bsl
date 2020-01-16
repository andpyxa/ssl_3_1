﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ОпределитьПоведениеВМобильномКлиенте();
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	
	ОбщиеНастройки = ПередЗакрытиемНаСервере(ОтключитьОписания);
	Оповестить(
		ВариантыОтчетовКлиент.ИмяСобытияИзменениеОбщихНастроек(),
		ОбщиеНастройки,
		Неопределено);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОтключитьСейчас(Команда)
	ОтключитьОписания = Истина;
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура ОК(Команда)
	Закрыть();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОпределитьПоведениеВМобильномКлиенте()
	ЭтоМобильныйКлиент = ОбщегоНазначения.ЭтоМобильныйКлиент();
	Если Не ЭтоМобильныйКлиент Тогда 
		Возврат;
	КонецЕсли;
	
	ПоложениеКоманднойПанели = ПоложениеКоманднойПанелиФормы.Авто;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПередЗакрытиемНаСервере(ОтключитьОписания)
	ОбщиеНастройки = ВариантыОтчетов.ОбщиеНастройкиПанели();
	Если ОтключитьОписания Тогда
		ОбщиеНастройки.ПоказыватьПодсказки = Ложь;
	КонецЕсли;
	ОбщиеНастройки.ПоказатьОповещениеОПодсказках = Ложь;
	ВариантыОтчетов.СохранитьОбщиеНастройкиПанели(ОбщиеНастройки);
	Возврат ОбщиеНастройки;
КонецФункции

#КонецОбласти
