﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	НовыйУникальныйИдентификатор = Новый УникальныйИдентификатор(ИдентификаторСтрокой);
	Если Запись.Идентификатор <> НовыйУникальныйИдентификатор Тогда
		Запись.Идентификатор = НовыйУникальныйИдентификатор;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ИдентификаторСтрокой = Запись.Идентификатор;
	
КонецПроцедуры

#КонецОбласти