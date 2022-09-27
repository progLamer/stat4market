<?php

// Запуск php test.php Y.m.d Y.m.d

// Вычисляемый день - день недели количество которых считаем (по заданию оставим вторник)
$calculatedDay = 2;

$date1 = DateTime::createFromFormat('Y.m.d', $argv[1])->setTime(0, 0);
$date2 = DateTime::createFromFormat('Y.m.d', $argv[2])->setTime(0, 0);

// Меняем даты если они пришли в обратном порядке
if ($date1 > $date2) {
    $date = $date1;
    $date1 = $date2;
    $date2 = $date;
    unset($date);
}

// Получим дни недели начальной и конечной дат
$dayOfWeek1 = (int)$date1->format('N');
$dayOfWeek2 = (int)$date2->format('N');

// Если день недели первой даты меньше вычисляемого дня, то сдвинем дату на воскресение предыдущей недели,
// иначе - на воскресение текущей
$modifier1 = $dayOfWeek1 < $calculatedDay ? (- $dayOfWeek1) : (7 - $dayOfWeek1);
$date1 = $date1->modify(sprintf('%d days', $modifier1));

// Если день недели второй даты больше вычисляемого дня, сдвигаем дату на воскресение текущей недели,
// иначе - на воскресение предыдущей недели
$modifier2 = $dayOfWeek2 > $calculatedDay ? (7 - $dayOfWeek2) : (- $dayOfWeek2);
$date2 = $date2->modify(sprintf('%d days', $modifier2));

// После предыдущих операций количество целых недель будет равняться количеству вычисляемых дней
$daysOfWeekCount = (int)((int)$date1->diff($date2)->format('%a') / 7);

echo sprintf('Количество дней недели между датами: %d%s', $daysOfWeekCount, "\n");