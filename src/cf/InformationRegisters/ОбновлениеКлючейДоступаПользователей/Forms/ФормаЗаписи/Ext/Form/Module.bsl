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
	
	Если Параметры.Ключ.Пустой() Тогда
		ЭтоНоваяЗапись = Истина;
		Элементы.КлючУникальности.ТолькоПросмотр = Истина;
		Элементы.ДатаИзмененияЗаписиРегистра.ТолькоПросмотр = Истина;
		Запись.РазмерЗадания = 3;
	КонецЕсли;
	
	ТолькоПросмотр = Истина;
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Если Не ЭтоНоваяЗапись Тогда
		Возврат;
	КонецЕсли;
	
	ТекущийОбъект.КлючУникальности = Новый УникальныйИдентификатор;
	ТекущийОбъект.ДатаИзмененияЗаписиРегистра = ТекущаяДатаСеанса();
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	ЭтоНоваяЗапись = Ложь;
	
	Элементы.КлючУникальности.ТолькоПросмотр = Ложь;
	Элементы.ДатаИзмененияЗаписиРегистра.ТолькоПросмотр = Ложь;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВключитьВозможностьРедактирования(Команда)
	
	ТолькоПросмотр = Ложь;
	
КонецПроцедуры

#КонецОбласти
