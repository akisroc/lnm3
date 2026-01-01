<?php

declare(strict_types=1);

$query = $db->prepare(
	'SELECT id, topic_id, place, author, content, created_at
    FROM posts
    WHERE topic_id IS NULL'
);
$query->execute();
$posts = $query->fetchAll(\PDO::FETCH_ASSOC);

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
        <h2>Liste des posts n’ayant pas de topic (récupérés des archives Print)</h2>
        <ul>
            <?php foreach ($posts as $post): ?>
                <li>
                    <article>
                        <p>Posté dans <?= $post['place'] ?></p>
                    	<p>Par <?= $post['author'] ?>, le <?= $post['created_at'] ?></p>
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
