<?php
require_once '../db.php';
$id = (int)$_GET['id'];
if ($_POST) {
    $name = trim($_POST['full_name']);
    $hire = $_POST['hire_date'];
    $fire = $_POST['fire_date'] ?: null;
    $percent = (float)$_POST['salary_percent'];
    $pdo->beginTransaction();
    try {
        $pdo->prepare("UPDATE doctors SET full_name=?, hire_date=?, fire_date=?, salary_percent=? WHERE id=?")
            ->execute([$name, $hire, $fire, $percent, $id]);
        $pdo->prepare("DELETE FROM doctor_specializations WHERE doctor_id=?")->execute([$id]);
        if (!empty($_POST['specializations'])) {
            foreach ($_POST['specializations'] as $spec_id) {
                $pdo->prepare("INSERT INTO doctor_specializations (doctor_id, specialization_id) VALUES (?, ?)")
                    ->execute([$id, (int)$spec_id]);
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
$doctor = $pdo->prepare("SELECT * FROM doctors WHERE id = ?");
$doctor->execute([$id]);
$doctor = $doctor->fetch();
if (!$doctor) die("Врач не найден");

$current_specs = $pdo->prepare("SELECT specialization_id FROM doctor_specializations WHERE doctor_id = ?");
$current_specs->execute([$id]);
$current_specs = $current_specs->fetchAll(PDO::FETCH_COLUMN);

$specs = $pdo->query("SELECT id, name FROM specializations")->fetchAll();
?>
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<title>Редактировать врача</title>
</head>
<body>
<h1>Редактировать врача</h1>
<form method="post">
<p><label>ФИО: <input type="text" name="full_name" value="<?= htmlspecialchars($doctor['full_name']) ?>" required></label></p>
<p><label>Дата приёма: <input type="date" name="hire_date" value="<?= $doctor['hire_date'] ?>" required></label></p>
<p><label>Дата увольнения: <input type="date" name="fire_date" value="<?= $doctor['fire_date'] ?>"></label></p>
<p><label>% ЗП: <input type="number" name="salary_percent" value="<?= $doctor['salary_percent'] ?>" min="0" max="100" step="0.1" required></label></p>
<p><label>Специализации:</label><br>
<?php foreach ($specs as $s): ?>
<label>
<input type="checkbox" name="specializations[]" value="<?= (int)$s['id'] ?>"
<?= in_array($s['id'], $current_specs) ? 'checked' : '' ?>>
<?= htmlspecialchars($s['name']) ?>
</label><br>
<?php endforeach; ?>
</p>
<button type="submit">Сохранить</button>
<a href="index.php">Отмена</a>
</form>
</body>
</html>
