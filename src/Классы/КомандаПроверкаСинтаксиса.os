Перем Конфигуратор;
Перем Лог;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	// ОбщиеКлючиКоманд.ДобавитьОбщиеПараметрыКоманд(Парсер);

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Полная проверка синтаксиса конфигурации");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--junitpath", "Путь отчета в формате JUnit.xml");
	Парсер.ДобавитьПараметрКоллекцияКоманды(ОписаниеКоманды, "--mode", 
		"Параметры синтаксических проверок (через пробел). 
		|	Например, -ThinClient -WebClient -Server -ExternalConnection -ThickClientOrdinaryApplication 
		|	Важно: этот параметр должен быть последним среди параметров!");

	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры (необязательно) - Соответствие - дополнительные параметры
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Лог = ДополнительныеПараметры.Лог;

	ПутьОтчетаВФорматеJUnitxml = ПараметрыКоманды["--junitpath"];
	Если ПутьОтчетаВФорматеJUnitxml = Неопределено Тогда
		ПутьОтчетаВФорматеJUnitxml = "";
	КонецЕсли;
	
	КоллекцияПроверок = ПараметрыКоманды["--mode"];

	ЛогПроверкиИзКонфигуратора = "";
	ДатаНачала = ТекущаяДата();

	МенеджерКонфигуратора = Новый МенеджерКонфигуратора;
	Успешно = МенеджерКонфигуратора.ВыполнитьСинтаксическийКонтроль(
			КоллекцияПроверок,			
			ПараметрыКоманды["--ibname"],
			ЛогПроверкиИзКонфигуратора,
			ПараметрыКоманды["--db-user"], ПараметрыКоманды["--db-pwd"],
			ПараметрыКоманды["--v8version"]);

	Если ЗначениеЗаполнено(ПутьОтчетаВФорматеJUnitxml) Тогда
		Лог.Отладка("Путь к лог-файлу проверки %1", ПутьОтчетаВФорматеJUnitxml);

		ВывестиОтчетПроверкиКонфигурацииВФорматеJUnitXML(ПутьОтчетаВФорматеJUnitxml, ЛогПроверкиИзКонфигуратора, 
			Успешно, ДатаНачала);

		Лог.Информация("Сформированы результаты проверки в формате JUnit.xml - %1", ПутьОтчетаВФорматеJUnitxml);
	КонецЕсли;

	РезультатыКоманд = МенеджерКомандПриложения.РезультатыКоманд();

	Возврат ?(Успешно, РезультатыКоманд.Успех, РезультатыКоманд.ОшибкаВремениВыполнения);

КонецФункции

// { приватная часть 

Функция ВывестиОтчетПроверкиКонфигурацииВФорматеJUnitXML(Знач ПутьОтчетаВФорматеJUnitxml, 
	Знач ЛогПроверкиИзКонфигуратора, Знач НетОшибок, Знач ДатаНачала) 
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку("UTF-8");
	ЗаписьXML.ЗаписатьОбъявлениеXML();
	
	ВсегоТестов = 1;
	КоличествоОшибок = ?(НетОшибок, 0, ВсегоТестов);
	ВремяВыполнения = ТекущаяДата() - ДатаНачала;
	
	ЗаписьXML.ЗаписатьНачалоЭлемента("testsuites");
	ЗаписьXML.ЗаписатьАтрибут("tests", XMLСтрока(ВсегоТестов));
	ЗаписьXML.ЗаписатьАтрибут("name", XMLСтрока("1adminka")); 
	ЗаписьXML.ЗаписатьАтрибут("time", XMLСтрока(ВремяВыполнения));
	ЗаписьXML.ЗаписатьАтрибут("failures", XMLСтрока(КоличествоОшибок));
	
	ЗаписьXML.ЗаписатьНачалоЭлемента("testsuite");	
	ЗаписьXML.ЗаписатьАтрибут("name", "Синтаксическая проверка конфигурации");
	ЗаписьXML.ЗаписатьНачалоЭлемента("properties");	
	ЗаписьXML.ЗаписатьКонецЭлемента();
	
	ЗаписьXML.ЗаписатьНачалоЭлемента("testcase");
	ЗаписьXML.ЗаписатьАтрибут("classname", "Тест");
	ЗаписьXML.ЗаписатьАтрибут("name", "Тест");
	ЗаписьXML.ЗаписатьАтрибут("time", XMLСтрока(ВремяВыполнения));
	
	Если НетОшибок Тогда
		ЗаписьXML.ЗаписатьАтрибут("status", "passed");
	Иначе
		ЗаписьXML.ЗаписатьАтрибут("status", "failure");
		ЗаписьXML.ЗаписатьНачалоЭлемента("failure");
		XMLОписание = XMLСтрока(ЛогПроверкиИзКонфигуратора); 
		ЗаписьXML.ЗаписатьАтрибут("message", XMLОписание);

		ЗаписьXML.ЗаписатьКонецЭлемента();
	КонецЕсли;
	
	ЗаписьXML.ЗаписатьКонецЭлемента(); //testcase
	
	ЗаписьXML.ЗаписатьКонецЭлемента(); //testsuites
	
	СтрокаХМЛ = ЗаписьXML.Закрыть();
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.ОткрытьФайл(ПутьОтчетаВФорматеJUnitxml);
	ЗаписьXML.ЗаписатьБезОбработки(СтрокаХМЛ);// таким образом файл будет записан всего один раз, и не будет проблем с обработкой на билд-сервере TeamCity
	ЗаписьXML.Закрыть();
	
	Лог.Отладка("СтрокаХМЛ %1", СтрокаХМЛ);
	
КонецФункции

// }

