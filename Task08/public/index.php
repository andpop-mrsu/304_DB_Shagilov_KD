<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Врачи клиники</title>
    <style>
        table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
        th, td { border: 1px solid #000; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .btn { margin-right: 5px; }
    </style>
</head>
<body>
    <h1>Список врачей</h1>
    <table>
        <thead>
            <tr>
                <th>ФИО</th>
                <th>Специализации</th>
                <th>Действия</th>
            </tr>
        </thead>
        <tbody>
            <?php
            require_once '../db.php';
            $stmt = $pdo->query("
                SELECT d.id, d.full_name,
                       GROUP_CONCAT(s.name, ', ') AS specializations
                FROM doctors d
                LEFT JOIN doctor_specializations ds ON d.id = ds.doctor_id
                LEFT JOIN specializations s ON ds.specialization_id = s.id
                GROUP BY d.id
                ORDER BY d.full_name
            ");
            while ($row = $stmt->fetch()):
            ?>
            <tr>
                <td><?= htmlspecialchars($row['full_name']) ?></td>
                <td><?= htmlspecialchars($row['specializations'] ?? '') ?></td>
                <td>
                    <a href="edit_doctor.php?id=<?= $row['id'] ?>" class="btn">Редактировать</a>
                    <a href="delete_doctor.php?id=<?= $row['id'] ?>" class="btn" onclick="return confirm('Удалить врача?')">Удалить</a>
                    <a href="schedule.php?doctor_id=<?= $row['id'] ?>" class="btn">График</a>
                    <a href="services.php?doctor_id=<?= $row['id'] ?>" class="btn">Оказанные услуги</a>
                </td>
            </tr>
            <?php endwhile; ?>
        </tbody>
    </table>
    <a href="add_doctor.php" class="btn">Добавить врача</a>
</body>
</html>
