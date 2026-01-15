<?php
require_once '../db.php';
$id = (int)$_GET['id'];
$pdo->beginTransaction();
try {
    // Сначала удаляем все приёмы врача
    $pdo->prepare("DELETE FROM appointments WHERE doctor_id = ?")->execute([$id]);
    // Потом — самого врача
    $pdo->prepare("DELETE FROM doctors WHERE id = ?")->execute([$id]);
    $pdo->commit();
    header("Location: index.php");
    exit;
} catch (Exception $e) {
    $pdo->rollback();
    die("Ошибка при удалении: " . htmlspecialchars($e->getMessage()));
}
