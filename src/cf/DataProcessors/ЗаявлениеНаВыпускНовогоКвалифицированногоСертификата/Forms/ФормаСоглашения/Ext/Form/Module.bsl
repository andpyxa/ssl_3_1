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
	
	ТекстHTML = Обработки.ЗаявлениеНаВыпускНовогоКвалифицированногоСертификата.ПолучитьМакет(
		"Соглашение").ПолучитьТекст();
	
	ТекстHTML = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстHTML,
		НСтр("ru = 'ООО «Научно-производственный центр ""1С""»'"),
		НСтр("ru = 'http://ca.1c.ru/reglament.pdf'"),
		НСтр("ru = 'уполномоченного федерального органа в области использования электронной подписи'"));
	
	Соглашение.УстановитьHTML(ТекстHTML, Новый Структура);
	
КонецПроцедуры

#КонецОбласти
