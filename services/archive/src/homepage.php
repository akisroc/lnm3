<?php

declare(strict_types=1);

$query = $db->query(
	"SELECT
    t.id,
    t.title,
    REPLACE(GROUP_CONCAT(DISTINCT p.author), ',', ', ') AS authors,
    MAX(p.created_at) AS last_post_date
    FROM topics t
    INNER JOIN posts p ON t.id = p.topic_id
    GROUP BY t.id
    ORDER BY last_post_date DESC"
);
$topics = $query->fetchAll(\PDO::FETCH_ASSOC);

$query = $db->query('SELECT COUNT(id) FROM posts');
$postsCount = $query->fetchColumn();

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
    <h2><?= $postsCount ?> posts sauvés</h2>
    <p>Ces archives sont pour l’instant extrêmement moches et peu pratiques. J’ai tapé ce site à la zob en une soirée, j’espère trouver le temps de l’améliorer plus tard. Je n’ai pas pris le temps de mettre en place un champ de recherche ou la possibilité de filtrer par ci ou ça, donc j’ai préféré ne rien paginer pour que vous puissiez au moins Ctrl + F dans la totalité des données. Ça peut faire des pages énormes mais ça devrait s’afficher correctement.</p>
    <p>Je mettrai peut-être rapidement en place un outil de parcours de données comme Datasette, ce sera tout aussi simple.</p>
    <p>Sur cette première page, vous avez la liste des topics. Vous avez aussi une rubrique spéciale pour les posts sans topics. J’en ai récupéré quelques milliers via la page d’impression des posts, les archives ne faisaient pas le lien avec le topic d’origine ; j’avais seulement le sous-forum : Vie en Dragostina, En Vrac, etc.</p>
    <p>Les infos sont souvent incomplètes : un post peut ne pas avoir d’auteur, de date, etc.</p>
    <p>J’espère que vous récupèrerez des trucs cools, que ce soit les dramas bibliques de LNM ou vos RP perdus. (:</p>
    <p>Pour ceux qui le souhaitent, je peux fournir les données complètes. J’ai les archives HTML d’origine scrapées sur la Web Archive, les fichiers JSON intermédiaires que j’ai créés à partir du HTML, et la base SQLite finale que j’utilise pour ce site. Je file ça à qui veut. Venez me joindre sur Discord : <a target="_blank" href="https://discord.gg/kzT8D3B">https://discord.gg/kzT8D3B</a> .</p>
    <hr/>
    <section>
        <h2><a href="/no-topic">POSTS SANS TOPIC</a></h2>
    </section>
    <hr/>
    <section>
        <h2>Liste des topics</h2>
        <ul>
            <?php foreach ($topics as $topic): ?>
                <li>
                	<p><a href="/topic?id=<?= (int) $topic['id'] ?>"><?= htmlspecialchars($topic['title']) ?></a> | (Dernier post le <?= $topic['last_post_date'] ?>)</p>
                	<p>
                		Participants : <?= $topic['authors'] ?>
                	</p>
                    <hr/>
                </li>
            <?php endforeach; ?>
        </ul>
    </section>
</body>
</html>
