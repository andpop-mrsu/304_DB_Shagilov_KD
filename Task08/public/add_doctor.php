<?php
if ($_POST) {
    require_once '../db.php';
    $name = trim($_POST['full_name']);
    $hire = $_POST['hire_date'];
    $fire = $_POST['fire_date'] ?: null;
    $percent = (float)$_POST['salary_percent'];
    $pdo->beginTransaction();
    try {
        $stmt = $pdo->prepare("INSERT INTO doctors (full_name, hire_date, fire_date, salary_percent) VALUES (?, ?, ?, ?)");
        $stmt->execute([$name, $hire, $fire, $percent]);
        $doctor_id = $pdo->lastInsertId();
        if (!empty($_POST['specializations'])) {
            foreach ($_POST['specializations'] as $spec_id) {
                $pdo->prepare("INSERT INTO doctor_specializations (doctor_id, specialization_id) VALUES (?, ?)")
                    ->execute([$doctor_id, (int)$spec_id]);
            }
        }
        $pdo->commit();
        header("Location: index.php");
        exit;
    } catch (Exception $e) {
        $pdo->rollback();
        echo "<p style='color:red;'>Ошибка: " . htmlspecialchars($e->getMessage()) . "</p>";
    }
}
require_once '../db.php';
$specs = $pdo->query("SELECT id, name FROM specializations")->fetchAll();
?>
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<title>Добавить врача</title>
</head>
<body>
<h1>Добавить врача</h1>
<form method="post">
<p><label>ФИО: <input type="text" name="full_name" required></label></p>
<p><label>Дата приёма: <input type="date" name="hire_date" required></label></p>
<p><label>Дата увольнения: <input type="date" name="fire_date"></label></p>
<p><label>% ЗП: <input type="number" name="salary_percent" min="0" max="100" step="0.1" required></label></p>
<p><label>Специализации:</label><br>
<?php foreach ($specs as $s): ?>
<label><input type="checkbox" name="specializations[]" value="<?= (int)$s['id'] ?>"> <?= htmlspecialchars($s['name']) ?></label><br>
<?php endforeach; ?>
</p>
<button type="submit">Добавить</button>
<a href="index.php">Отмена</a>
</form>
</body>
</html>
