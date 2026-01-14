<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Услуги врачей</title>
    <style>
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #000; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Список оказанных услуг</h1>

    <?php
    $pdo = new PDO('sqlite:test.db');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Получаем врачей для выпадающего списка
    $stmt = $pdo->query("SELECT id, full_name FROM doctors ORDER BY full_name");
    $doctors = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Обработка фильтрации
    $selected_id = $_GET['doctor_id'] ?? null;
    if ($selected_id && !is_numeric($selected_id)) {
        $selected_id = null;
    }

    // Запрос данных
    $sql = "
        SELECT d.full_name, a.appointment_time, s.name AS service, a.actual_price
        FROM appointments a
        JOIN doctors d ON a.doctor_id = d.id
        JOIN services s ON a.service_id = s.id
        WHERE a.performed = 1
    ";
    $params = [];
    if ($selected_id) {
        $sql .= " AND d.id = :doctor_id";
        $params[':doctor_id'] = (int)$selected_id;
    }
    $sql .= " ORDER BY d.full_name, a.appointment_time";

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);
    ?>

    <form method="get">
        <label for="doctor">Выберите врача:</label>
        <select name="doctor_id" id="doctor" onchange="this.form.submit()">
            <option value="">Все врачи</option>
            <?php foreach ($doctors as $doc): ?>
                <option value="<?= htmlspecialchars($doc['id']) ?>" 
                    <?= ($selected_id == $doc['id']) ? 'selected' : '' ?>>
                    <?= htmlspecialchars($doc['full_name']) ?>
                </option>
            <?php endforeach; ?>
        </select>
    </form>

    <?php if (empty($records)): ?>
        <p>Нет записей.</p>
    <?php else: ?>
        <table>
            <thead>
                <tr>
                    <th>ФИО врача</th>
                    <th>Дата</th>
                    <th>Услуга</th>
                    <th>Стоимость</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($records as $r): ?>
                    <tr>
                        <td><?= htmlspecialchars($r['full_name']) ?></td>
                        <td><?= date('Y-m-d H:i', strtotime($r['appointment_time'])) ?></td>
                        <td><?= htmlspecialchars($r['service']) ?></td>
                        <td><?= number_format($r['actual_price'], 2) ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    <?php endif; ?>
</body>
</html>
