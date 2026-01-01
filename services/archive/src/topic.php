<?php

declare(strict_types=1);

if (!isset($_GET['id'])) {
	header('Location: /');
	exit;
}

$query = $db->prepare(
	'SELECT id, topic_id, position, author, content, created_at
	FROM posts
	WHERE topic_id = ?
	ORDER BY created_at ASC'
);
$query->execute([$_GET['id']]);
$posts = $query->fetchAll(\PDO::FETCH_ASSOC);

$query = $db->prepare('SELECT id, title FROM topics WHERE id = ?');
$query->execute([$_GET['id']]);
$topic = $query->fetchAll(\PDO::FETCH_ASSOC);


?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LNM Archive</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <h1>LNM Archive</h1>
    <section>   
        <h2><?= $topic['title'] ?></h2>
        <ul>
            <?php foreach ($posts as $post): ?>
                <li>
                    <article>
                    	<p>Par <?= htmlspecialchars($post['author'] ?? '') ?>, le <?= htmlspecialchars($post['created_at'] ?? '') ?></p>
                    	<div>
                    		<?= nl2br($post['content']) ?>
                    	</div>
                    </article>
                    <hr/>
                </li>
            <?php endforeach; ?>
        </ul>
    </section>
</body>
</html>
