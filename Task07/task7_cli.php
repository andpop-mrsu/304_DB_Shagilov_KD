<?php
$pdo = new PDO('sqlite:test.db');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

// Получаем всех врачей
$stmt = $pdo->query("SELECT id, full_name FROM doctors ORDER BY full_name");
$doctors = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "Список врачей:\n";
foreach ($doctors as $doc) {
    printf("%d. %s\n", $doc['id'], $doc['full_name']);
}
echo "\nВведите номер врача или нажмите Enter для вывода всех: ";
$handle = fopen("php://stdin", "r");
$input = trim(fgets($handle));
fclose($handle);

$doctor_id = null;
if ($input !== '') {
    if (!ctype_digit($input)) {
        die("Ошибка: введите корректный номер врача.\n");
    }
    $ids = array_column($doctors, 'id');
    if (!in_array((int)$input, $ids)) {
        die("Ошибка: такого врача нет в базе.\n");
    }
    $doctor_id = (int)$input;
}

// Формируем запрос
$sql = "
SELECT d.id AS doctor_id, d.full_name, a.appointment_time, s.name AS service, a.actual_price
FROM appointments a
JOIN doctors d ON a.doctor_id = d.id
JOIN services s ON a.service_id = s.id
WHERE a.performed = 1
";

$params = [];
if ($doctor_id) {
    $sql .= " AND d.id = :doctor_id";
    $params[':doctor_id'] = $doctor_id;
}
$sql .= " ORDER BY d.full_name, a.appointment_time";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$records = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Выводим таблицу псевдографикой
if (empty($records)) {
    echo "Нет записей.\n";
} else {
    printf("+%-5s+%-30s+%-20s+%-30s+%-10s+\n", str_repeat('-',5), str_repeat('-',30), str_repeat('-',20), str_repeat('-',30), str_repeat('-',10));
    printf("|%-5s|%-30s|%-20s|%-30s|%-10s|\n", 'ID', 'ФИО врача', 'Дата', 'Услуга', 'Стоимость');
    printf("+%-5s+%-30s+%-20s+%-30s+%-10s+\n", str_repeat('-',5), str_repeat('-',30), str_repeat('-',20), str_repeat('-',30), str_repeat('-',10));

    foreach ($records as $r) {
        $date = date('Y-m-d H:i', strtotime($r['appointment_time']));
        printf("|%-5d|%-30s|%-20s|%-30s|%-10.2f|\n",
            $r['doctor_id'],
            mb_substr($r['full_name'], 0, 29),
            $date,
            mb_substr($r['service'], 0, 29),
            $r['actual_price']
        );
    }
    printf("+%-5s+%-30s+%-20s+%-30s+%-10s+\n", str_repeat('-',5), str_repeat('-',30), str_repeat('-',20), str_repeat('-',30), str_repeat('-',10));
}
