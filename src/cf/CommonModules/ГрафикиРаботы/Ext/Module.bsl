﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Возвращает даты, которые отличаются указанной даты ДатаОт на количество дней,
// входящих в указанный график ГрафикРаботы.
//
// Параметры:
//	ГрафикРаботы	- СправочникСсылка.Календари - график, который необходимо использовать.
//	ДатаОт			- Дата - дата, от которой нужно рассчитать количество дней.
//	МассивДней		- Массив - количество дней (Число), на которые нужно увеличить дату начала.
//	РассчитыватьСледующуюДатуОтПредыдущей	- Булево - нужно ли рассчитывать следующую дату от предыдущей, 
//											           или все даты рассчитываются от переданной даты.
//	ВызыватьИсключение - Булево - если Истина, вызывается исключение в случае незаполненного графика.
//
// Возвращаемое значение:
//	Массив, Неопределено - даты, увеличенные на количество дней, входящих в график ГрафикРаботы.
//	                       Если график ГрафикРаботы не заполнен, и ВызыватьИсключение = Ложь, возвращается Неопределено.
//
Функция ДатыПоГрафику(Знач ГрафикРаботы, Знач ДатаОт, Знач МассивДней, 
	Знач РассчитыватьСледующуюДатуОтПредыдущей = Ложь, ВызыватьИсключение = Истина) Экспорт
	
	МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	
	КалендарныеГрафики.СоздатьВТПриращениеДней(МенеджерВременныхТаблиц, МассивДней, РассчитыватьСледующуюДатуОтПредыдущей);
	
	// Алгоритм работает следующим образом:
	// Получаем количество включенных в график дней на дату отсчета.
	// Для всех последующих годов получаем "смещение" количества дней в виде суммы количества дней предыдущих годов.
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	КалендарныеГрафики.Год,
	|	МАКСИМУМ(КалендарныеГрафики.КоличествоДнейВГрафикеСНачалаГода) КАК ДнейВГрафике
	|ПОМЕСТИТЬ ВТКоличествоДнейВГрафикеПоГодам
	|ИЗ
	|	РегистрСведений.КалендарныеГрафики КАК КалендарныеГрафики
	|ГДЕ
	|	КалендарныеГрафики.ДатаГрафика >= &ДатаОт
	|	И КалендарныеГрафики.Календарь = &ГрафикРаботы
	|
	|СГРУППИРОВАТЬ ПО
	|	КалендарныеГрафики.Год
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КоличествоДнейВГрафикеПоГодам.Год,
	|	СУММА(ЕСТЬNULL(КоличествоДнейПредыдущихГодов.ДнейВГрафике, 0)) КАК ДнейВГрафике
	|ПОМЕСТИТЬ ВТКоличествоДнейСУчетомПредыдущихГодов
	|ИЗ
	|	ВТКоличествоДнейВГрафикеПоГодам КАК КоличествоДнейВГрафикеПоГодам
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТКоличествоДнейВГрафикеПоГодам КАК КоличествоДнейПредыдущихГодов
	|		ПО (КоличествоДнейПредыдущихГодов.Год < КоличествоДнейВГрафикеПоГодам.Год)
	|
	|СГРУППИРОВАТЬ ПО
	|	КоличествоДнейВГрафикеПоГодам.Год
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	МИНИМУМ(КалендарныеГрафики.КоличествоДнейВГрафикеСНачалаГода) КАК КоличествоДнейВГрафикеСНачалаГода
	|ПОМЕСТИТЬ ВТКоличествоДнейВГрафикеНаДатуОтсчета
	|ИЗ
	|	РегистрСведений.КалендарныеГрафики КАК КалендарныеГрафики
	|ГДЕ
	|	КалендарныеГрафики.ДатаГрафика >= &ДатаОт
	|	И КалендарныеГрафики.Год = ГОД(&ДатаОт)
	|	И КалендарныеГрафики.Календарь = &ГрафикРаботы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПриращениеДней.ИндексСтроки,
	|	ЕСТЬNULL(КалендарныеГрафики.ДатаГрафика, НЕОПРЕДЕЛЕНО) КАК ДатаПоКалендарю
	|ИЗ
	|	ВТПриращениеДней КАК ПриращениеДней
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТКоличествоДнейВГрафикеНаДатуОтсчета КАК КоличествоДнейВГрафикеНаДатуОтсчета
	|		ПО (ИСТИНА)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КалендарныеГрафики КАК КалендарныеГрафики
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТКоличествоДнейСУчетомПредыдущихГодов КАК КоличествоДнейСУчетомПредыдущихГодов
	|			ПО (КоличествоДнейСУчетомПредыдущихГодов.Год = КалендарныеГрафики.Год)
	|		ПО (КалендарныеГрафики.КоличествоДнейВГрафикеСНачалаГода = КоличествоДнейВГрафикеНаДатуОтсчета.КоличествоДнейВГрафикеСНачалаГода - КоличествоДнейСУчетомПредыдущихГодов.ДнейВГрафике + ПриращениеДней.КоличествоДней)
	|			И (КалендарныеГрафики.ДатаГрафика >= &ДатаОт)
	|			И (КалендарныеГрафики.Календарь = &ГрафикРаботы)
	|			И (КалендарныеГрафики.ДеньВключенВГрафик)
	|
	|УПОРЯДОЧИТЬ ПО
	|	ПриращениеДней.ИндексСтроки";
	
	Запрос.УстановитьПараметр("ДатаОт", НачалоДня(ДатаОт));
	Запрос.УстановитьПараметр("ГрафикРаботы", ГрафикРаботы);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	МассивДат = Новый Массив;
	
	Пока Выборка.Следующий() Цикл
		Если Выборка.ДатаПоКалендарю = Неопределено Тогда
			СообщениеОбОшибке = НСтр("ru = 'График работы «%1» не заполнен с даты %2 на указанное количество рабочих дней.'");
			Если ВызыватьИсключение Тогда
				ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СообщениеОбОшибке, ГрафикРаботы, Формат(ДатаОт, "ДЛФ=D"));
			Иначе
				Возврат Неопределено;
			КонецЕсли;
		КонецЕсли;
		
		МассивДат.Добавить(Выборка.ДатаПоКалендарю);
	КонецЦикла;
	
	Возврат МассивДат;
	
КонецФункции

// Возвращает дату, которая отличается указанной даты ДатаОт на количество дней,
// входящих в указанный график ГрафикРаботы.
//
// Параметры:
//	ГрафикРаботы	- СправочникСсылка.Календари - график, который необходимо использовать.
//	ДатаОт			- Дата - дата, от которой нужно рассчитать количество дней.
//	КоличествоДней	- Число - количество дней, на которые нужно увеличить дату начала ДатаОт.
//	ВызыватьИсключение - Булево - если Истина, вызывается исключение в случае незаполненного графика.
//
// Возвращаемое значение:
//	Дата, Неопределено - дата, увеличенная на количество дней, входящих в график ГрафикРаботы.
//	                     Если график ГрафикРаботы не заполнен, и ВызыватьИсключение = Ложь, возвращается Неопределено.
//
Функция ДатаПоГрафику(Знач ГрафикРаботы, Знач ДатаОт, Знач КоличествоДней, ВызыватьИсключение = Истина) Экспорт
	
	ДатаОт = НачалоДня(ДатаОт);
	
	Если КоличествоДней = 0 Тогда
		Возврат ДатаОт;
	КонецЕсли;
	
	МассивДней = Новый Массив;
	МассивДней.Добавить(КоличествоДней);
	
	МассивДат = ДатыПоГрафику(ГрафикРаботы, ДатаОт, МассивДней, , ВызыватьИсключение);
	
	Возврат ?(МассивДат <> Неопределено, МассивДат[0], Неопределено);
	
КонецФункции

// Составляет расписания работы для дат, включенных в указанные графики на указанный период.
// Если расписание на предпраздничный день не задано, то оно определяется так, как если бы этот день был бы рабочим.
//
// Параметры:
//	Графики       - Массив - массив элементов типа СправочникСсылка.Календари, для которых составляются расписания.
//	ДатаНачала    - Дата   - дата начала периода, за который нужно составить расписания.
//	ДатаОкончания - Дата   - дата окончания периода.
//
// Возвращаемое значение:
//   ТаблицаЗначений - таблица с колонками:
//	  * ГрафикРаботы    - СправочникСсылка.Календари - график работы.
//	  * ДатаГрафика     - Дата - дата в графике работы ГрафикРаботы.
//	  * ВремяНачала     - Дата - время начала работы в день ДатаГрафика.
//	  * ВремяОкончания  - Дата - время окончания работы в день ДатаГрафика.
//
Функция РасписанияРаботыНаПериод(Графики, ДатаНачала, ДатаОкончания) Экспорт
	
	МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	
	// Создаем временную таблицу расписаний.
	СоздатьВТРасписанияРаботыНаПериод(МенеджерВременныхТаблиц, Графики, ДатаНачала, ДатаОкончания);
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	РасписанияРаботы.ГрафикРаботы,
	|	РасписанияРаботы.ДатаГрафика,
	|	РасписанияРаботы.ВремяНачала,
	|	РасписанияРаботы.ВремяОкончания
	|ИЗ
	|	ВТРасписанияРаботы КАК РасписанияРаботы";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

// Создает в менеджере временную таблицу ВТРасписанияРаботы с колонками, соответствующими возвращаемому значению
// функции РасписанияРаботыНаПериод.
//
// Параметры:
//  МенеджерВременныхТаблиц - МенеджерВременныхТаблиц - менеджер, в котором будет создана временная таблица.
//	Графики       - Массив - массив элементов типа СправочникСсылка.Календари, для которых составляются расписания.
//	ДатаНачала    - Дата   - дата начала периода, за который нужно составить расписания.
//	ДатаОкончания - Дата   - дата окончания периода.
//
Процедура СоздатьВТРасписанияРаботыНаПериод(МенеджерВременныхТаблиц, Графики, ДатаНачала, ДатаОкончания) Экспорт
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	ШаблонЗаполнения.Ссылка КАК ГрафикРаботы,
	|	МАКСИМУМ(ШаблонЗаполнения.НомерСтроки) КАК ДлинаЦикла
	|ПОМЕСТИТЬ ВТДлинаЦиклаГрафиков
	|ИЗ
	|	Справочник.Календари.ШаблонЗаполнения КАК ШаблонЗаполнения
	|ГДЕ
	|	ШаблонЗаполнения.Ссылка В(&Календари)
	|
	|СГРУППИРОВАТЬ ПО
	|	ШаблонЗаполнения.Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Календари.Ссылка КАК ГрафикРаботы,
	|	ДанныеПроизводственногоКалендаря.Дата КАК ДатаГрафика,
	|	ВЫБОР
	|		КОГДА ДанныеПроизводственногоКалендаря.ВидДня = ЗНАЧЕНИЕ(Перечисление.ВидыДнейПроизводственногоКалендаря.Предпраздничный)
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК ПредпраздничныйДень
	|ПОМЕСТИТЬ ВТПредпраздничныеДни
	|ИЗ
	|	РегистрСведений.ДанныеПроизводственногоКалендаря КАК ДанныеПроизводственногоКалендаря
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Календари КАК Календари
	|		ПО ДанныеПроизводственногоКалендаря.ПроизводственныйКалендарь = Календари.ПроизводственныйКалендарь
	|			И (Календари.Ссылка В (&Календари))
	|			И (ДанныеПроизводственногоКалендаря.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания)
	|			И (ДанныеПроизводственногоКалендаря.ВидДня = ЗНАЧЕНИЕ(Перечисление.ВидыДнейПроизводственногоКалендаря.Предпраздничный))
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Календари.Ссылка КАК ГрафикРаботы,
	|	ДанныеПроизводственногоКалендаря.Дата КАК ДатаГрафика,
	|	ДанныеПроизводственногоКалендаря.ДатаПереноса
	|ПОМЕСТИТЬ ВТДатыПереноса
	|ИЗ
	|	РегистрСведений.ДанныеПроизводственногоКалендаря КАК ДанныеПроизводственногоКалендаря
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Календари КАК Календари
	|		ПО ДанныеПроизводственногоКалендаря.ПроизводственныйКалендарь = Календари.ПроизводственныйКалендарь
	|			И (Календари.Ссылка В (&Календари))
	|			И (ДанныеПроизводственногоКалендаря.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания)
	|			И (ДанныеПроизводственногоКалендаря.ДатаПереноса <> ДАТАВРЕМЯ(1, 1, 1))
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КалендарныеГрафики.Календарь КАК ГрафикРаботы,
	|	КалендарныеГрафики.ДатаГрафика КАК ДатаГрафика,
	|	РАЗНОСТЬДАТ(Календари.ДатаОтсчета, КалендарныеГрафики.ДатаГрафика, ДЕНЬ) + 1 КАК ДнейОтДатыОтсчета,
	|	ПредпраздничныеДни.ПредпраздничныйДень,
	|	ДатыПереноса.ДатаПереноса
	|ПОМЕСТИТЬ ВТДниВключенныеВГрафик
	|ИЗ
	|	РегистрСведений.КалендарныеГрафики КАК КалендарныеГрафики
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Календари КАК Календари
	|		ПО КалендарныеГрафики.Календарь = Календари.Ссылка
	|			И (КалендарныеГрафики.Календарь В (&Календари))
	|			И (КалендарныеГрафики.ДатаГрафика МЕЖДУ &ДатаНачала И &ДатаОкончания)
	|			И (КалендарныеГрафики.ДеньВключенВГрафик)
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТПредпраздничныеДни КАК ПредпраздничныеДни
	|		ПО (ПредпраздничныеДни.ГрафикРаботы = КалендарныеГрафики.Календарь)
	|			И (ПредпраздничныеДни.ДатаГрафика = КалендарныеГрафики.ДатаГрафика)
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТДатыПереноса КАК ДатыПереноса
	|		ПО (ДатыПереноса.ГрафикРаботы = КалендарныеГрафики.Календарь)
	|			И (ДатыПереноса.ДатаГрафика = КалендарныеГрафики.ДатаГрафика)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДниВключенныеВГрафик.ГрафикРаботы,
	|	ДниВключенныеВГрафик.ДатаГрафика,
	|	ВЫБОР
	|		КОГДА ДниВключенныеВГрафик.РезультатДеленияПоМодулю = 0
	|			ТОГДА ДниВключенныеВГрафик.ДлинаЦикла
	|		ИНАЧЕ ДниВключенныеВГрафик.РезультатДеленияПоМодулю
	|	КОНЕЦ КАК НомерДня,
	|	ДниВключенныеВГрафик.ПредпраздничныйДень
	|ПОМЕСТИТЬ ВТДатыНомераДней
	|ИЗ
	|	(ВЫБРАТЬ
	|		ДниВключенныеВГрафик.ГрафикРаботы КАК ГрафикРаботы,
	|		ДниВключенныеВГрафик.ДатаГрафика КАК ДатаГрафика,
	|		ДниВключенныеВГрафик.ПредпраздничныйДень КАК ПредпраздничныйДень,
	|		ДниВключенныеВГрафик.ДлинаЦикла КАК ДлинаЦикла,
	|		ДниВключенныеВГрафик.ДнейОтДатыОтсчета - ДниВключенныеВГрафик.ЦелаяЧастьРезультатаДеления * ДниВключенныеВГрафик.ДлинаЦикла КАК РезультатДеленияПоМодулю
	|	ИЗ
	|		(ВЫБРАТЬ
	|			ДниВключенныеВГрафик.ГрафикРаботы КАК ГрафикРаботы,
	|			ДниВключенныеВГрафик.ДатаГрафика КАК ДатаГрафика,
	|			ДниВключенныеВГрафик.ПредпраздничныйДень КАК ПредпраздничныйДень,
	|			ДниВключенныеВГрафик.ДнейОтДатыОтсчета КАК ДнейОтДатыОтсчета,
	|			ДлинаЦиклов.ДлинаЦикла КАК ДлинаЦикла,
	|			(ВЫРАЗИТЬ(ДниВключенныеВГрафик.ДнейОтДатыОтсчета / ДлинаЦиклов.ДлинаЦикла КАК ЧИСЛО(15, 0))) - ВЫБОР
	|				КОГДА (ВЫРАЗИТЬ(ДниВключенныеВГрафик.ДнейОтДатыОтсчета / ДлинаЦиклов.ДлинаЦикла КАК ЧИСЛО(15, 0))) > ДниВключенныеВГрафик.ДнейОтДатыОтсчета / ДлинаЦиклов.ДлинаЦикла
	|					ТОГДА 1
	|				ИНАЧЕ 0
	|			КОНЕЦ КАК ЦелаяЧастьРезультатаДеления
	|		ИЗ
	|			ВТДниВключенныеВГрафик КАК ДниВключенныеВГрафик
	|				ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Календари КАК Календари
	|				ПО ДниВключенныеВГрафик.ГрафикРаботы = Календари.Ссылка
	|					И (Календари.СпособЗаполнения = ЗНАЧЕНИЕ(Перечисление.СпособыЗаполненияГрафикаРаботы.ПоЦикламПроизвольнойДлины))
	|				ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТДлинаЦиклаГрафиков КАК ДлинаЦиклов
	|				ПО ДниВключенныеВГрафик.ГрафикРаботы = ДлинаЦиклов.ГрафикРаботы) КАК ДниВключенныеВГрафик) КАК ДниВключенныеВГрафик
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ДниВключенныеВГрафик.ГрафикРаботы,
	|	ДниВключенныеВГрафик.ДатаГрафика,
	|	ВЫБОР
	|		КОГДА ДниВключенныеВГрафик.ДатаПереноса ЕСТЬ NULL 
	|			ТОГДА ДЕНЬНЕДЕЛИ(ДниВключенныеВГрафик.ДатаГрафика)
	|		ИНАЧЕ ДЕНЬНЕДЕЛИ(ДниВключенныеВГрафик.ДатаПереноса)
	|	КОНЕЦ,
	|	ДниВключенныеВГрафик.ПредпраздничныйДень
	|ИЗ
	|	ВТДниВключенныеВГрафик КАК ДниВключенныеВГрафик
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Календари КАК Календари
	|		ПО ДниВключенныеВГрафик.ГрафикРаботы = Календари.Ссылка
	|ГДЕ
	|	Календари.СпособЗаполнения = ЗНАЧЕНИЕ(Перечисление.СпособыЗаполненияГрафикаРаботы.ПоНеделям)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ДниВключенныеВГрафик.ГрафикРаботы,
	|	ДниВключенныеВГрафик.ДатаГрафика,
	|	ДниВключенныеВГрафик.НомерДня,
	|	ЕСТЬNULL(РасписанияРаботыПредпраздничногоДня.ВремяНачала, РасписанияРаботы.ВремяНачала) КАК ВремяНачала,
	|	ЕСТЬNULL(РасписанияРаботыПредпраздничногоДня.ВремяОкончания, РасписанияРаботы.ВремяОкончания) КАК ВремяОкончания
	|ПОМЕСТИТЬ ВТРасписанияРаботы
	|ИЗ
	|	ВТДатыНомераДней КАК ДниВключенныеВГрафик
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Календари.РасписаниеРаботы КАК РасписанияРаботы
	|		ПО (РасписанияРаботы.Ссылка = ДниВключенныеВГрафик.ГрафикРаботы)
	|			И (РасписанияРаботы.НомерДня = ДниВключенныеВГрафик.НомерДня)
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Календари.РасписаниеРаботы КАК РасписанияРаботыПредпраздничногоДня
	|		ПО (РасписанияРаботыПредпраздничногоДня.Ссылка = ДниВключенныеВГрафик.ГрафикРаботы)
	|			И (РасписанияРаботыПредпраздничногоДня.НомерДня = 0)
	|			И (ДниВключенныеВГрафик.ПредпраздничныйДень)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ДниВключенныеВГрафик.ГрафикРаботы,
	|	ДниВключенныеВГрафик.ДатаГрафика";
	
	// Для вычисления номера в цикле произвольной длины для дня, включенного в график, используется следующая формула:
	// Номер дня = Дней от даты отсчета % Длина цикла, где % - операция деления по модулю.
	
	// Операция деления по модулю в свою очередь производится по формуле:
	// Делимое - Цел(Делимое / Делитель) * Делитель, где Цел() - функция выделения целой части.
	
	// Для выделения целой части используется конструкция:
	// если результат округления числа по правилам «1.5 как 2» больше исходного значения, уменьшаем результат на 1.
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	Запрос.УстановитьПараметр("Календари", Графики);
	Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", ДатаОкончания);
	Запрос.Выполнить();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Выполняет обновление графиков работы по данным производственных календарей, 
// на основании которых они заполняются.
//
// Параметры:
//	- УсловияОбновления - таблица значений с колонками.
//		- КодПроизводственногоКалендаря - код производственного календаря, данные которого изменились,
//		- Год - год, за который нужно обновить данные.
//
Процедура ОбновитьГрафикиРаботыПоДаннымПроизводственныхКалендарей(УсловияОбновления) Экспорт
	
	РегистрыСведений.КалендарныеГрафики.ОбновитьГрафикиРаботыПоДаннымПроизводственныхКалендарей(УсловияОбновления);
	
КонецПроцедуры

// Добавляет в список блокируемых объектов справочник графиков работы, 
// чтобы на время обновления производственных календарей, графики были недоступны для изменения пользователем.
//
// Параметры:
//	БлокируемыеОбъекты - Массив из Строка - имена метаданных блокируемых объектов.
//
Процедура ЗаполнитьБлокируемыеОбъектыЗависимыеОтПроизводственныхКалендарей(БлокируемыеОбъекты) Экспорт
	
	БлокируемыеОбъекты.Добавить("Справочник.Календари");
	
КонецПроцедуры

// Добавляет в список изменяемых объектов регистр календарных графиков.
//
// Параметры:
//	ИзменяемыеОбъекты - Массив из Строка - имена метаданных изменяемых объектов.
//
Процедура ЗаполнитьИзменяемыеОбъектыЗависимыеОтПроизводственныхКалендарей(ИзменяемыеОбъекты) Экспорт
	
	ИзменяемыеОбъекты.Добавить("РегистрСведений.КалендарныеГрафики");
	
КонецПроцедуры

// Создает временную таблицу ВТКалендарныеГрафики, содержащую данные графика ГрафикРаботы за годы, 
// приведенные в ВТРазличныеГодыГрафика.
//
// Параметры:
//	- МенеджерВременныхТаблиц - должен содержать ВТРазличныеГодыГрафика с полем Год, типа Число (4,0),
//	- ГрафикРаботы - график, который необходимо использовать, тип СправочникСсылка.Календари.
//
Процедура СоздатьВТДанныеГрафика(МенеджерВременныхТаблиц, ГрафикРаботы) Экспорт
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	КалендарныеГрафики.Год,
	|	КалендарныеГрафики.ДатаГрафика,
	|	КалендарныеГрафики.ДеньВключенВГрафик
	|ПОМЕСТИТЬ ВТКалендарныеГрафики
	|ИЗ
	|	РегистрСведений.КалендарныеГрафики КАК КалендарныеГрафики
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТРазличныеГодыГрафика КАК ГодыГрафика
	|		ПО (ГодыГрафика.Год = КалендарныеГрафики.Год)
	|ГДЕ
	|	КалендарныеГрафики.Календарь = &ГрафикРаботы";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	Запрос.УстановитьПараметр("ГрафикРаботы", ГрафикРаботы);
	Запрос.Выполнить();
	
КонецПроцедуры

// Формирует шаблон текста запроса, встраиваемый в методе КалендарныеГрафики.ПолучитьДатыРабочихДней.
//
Функция ШаблонТекстаЗапросаОпределенияБлижайшихДатПоГрафикуРаботы() Экспорт
	
	Возврат
	"ВЫБРАТЬ
	|	НачальныеДаты.Дата,
	|	%Функция%(ДатыКалендаря.ДатаГрафика) КАК БлижайшаяДата
	|ИЗ
	|	НачальныеДаты КАК НачальныеДаты
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КалендарныеГрафики КАК ДатыКалендаря
	|		ПО (ДатыКалендаря.ДатаГрафика %ЗнакУсловия% НачальныеДаты.Дата)
	|			И (ДатыКалендаря.Календарь = &График)
	|			И (ДатыКалендаря.ДеньВключенВГрафик)
	|
	|СГРУППИРОВАТЬ ПО
	|	НачальныеДаты.Дата";
	
КонецФункции

Функция ИмяПроцедурыОбновленияГрафиковРаботы() Экспорт
	
	Возврат "РегистрыСведений.КалендарныеГрафики.ОбработатьДанныеДляПереходаНаНовуюВерсию";
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОбновлениеИнформационнойБазыБСП.ПриДобавленииОбработчиковОбновления.
// 
// Параметры:
// 	Обработчики - см. ОбновлениеИнформационнойБазы.НоваяТаблицаОбработчиковОбновления
//
Процедура ПриДобавленииОбработчиковОбновления(Обработчики) Экспорт
	
	Если Метаданные.Обработки.Найти("ЗаполнениеГрафиковРаботы") <> Неопределено Тогда
		МодульГрафикиРаботы = ОбщегоНазначения.ОбщийМодуль("Обработки.ЗаполнениеГрафиковРаботы");
		МодульГрафикиРаботы.ПриДобавленииОбработчиковОбновления(Обработчики);
	КонецЕсли;
	
	Обработчик = Обработчики.Добавить();
	Обработчик.Версия = "3.1.2.78";
	Обработчик.Процедура = "РегистрыСведений.КалендарныеГрафики.ОбработатьДанныеДляПереходаНаНовуюВерсию";
	Обработчик.ОчередьОтложеннойОбработки = 2;
	Обработчик.ПроцедураЗаполненияДанныхОбновления = "РегистрыСведений.КалендарныеГрафики.ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию";
	Обработчик.РежимВыполнения = "Отложенно";
	Обработчик.ЗапускатьИВПодчиненномУзлеРИБСФильтрами = Истина;
	Обработчик.ЧитаемыеОбъекты = "РегистрСведений.КалендарныеГрафики, РегистрСведений.РучныеИзмененияГрафиковРаботы, РегистрСведений.ДанныеПроизводственногоКалендаря";
	Обработчик.ИзменяемыеОбъекты = "РегистрСведений.КалендарныеГрафики";
	Обработчик.ПроцедураПроверки = "ОбновлениеИнформационнойБазы.ДанныеОбновленыНаНовуюВерсиюПрограммы";
	Обработчик.Идентификатор = Новый УникальныйИдентификатор("39e6fbf8-c02d-4459-bdbd-58adf6c6127c");
	Обработчик.Комментарий = НСтр("ru = 'Исправление включения в график рабочих и предпраздничных дней, выпадающих на субботу или воскресенье.'");
	Обработчик.БлокируемыеОбъекты = "Справочник.Календари";
	Обработчик.ПриоритетыВыполнения = ОбновлениеИнформационнойБазы.ПриоритетыВыполненияОбработчика();
	Приоритет = Обработчик.ПриоритетыВыполнения.Добавить();
	Приоритет.Процедура = "КалендарныеГрафики.ОбновитьДанныеЗависимыеОтПроизводственныхКалендарей";
	Приоритет.Порядок = "После";
	
КонецПроцедуры

// Параметры:
// 	НазначениеРолей - см. ПользователиПереопределяемый.ПриОпределенииНазначенияРолей.НазначениеРолей
//
Процедура ПриОпределенииНазначенияРолей(НазначениеРолей) Экспорт
	
	// СовместноДляПользователейИВнешнихПользователей.
	НазначениеРолей.СовместноДляПользователейИВнешнихПользователей.Добавить(
		Метаданные.Роли.ЧтениеГрафиковРаботы.Имя);
	
КонецПроцедуры

#КонецОбласти