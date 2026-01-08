<?php

declare(strict_types=1);

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\StreamedJsonResponse;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\ResponseHeaderBag;
use Symfony\Component\HttpKernel\Attribute\MapQueryParameter;
use Symfony\Component\Routing\Attribute\Route;
use App\Service\Database;

class ApiController extends AbstractController
{
    // 6 months
    // Archive ata is static and eternal anyway
    private const RESPONSES_MAX_AGE = 60 * 60 * 24 * 30 * 6;

    public function __construct(
        private readonly Database $db
    ) {}

    #[Route('/topics', name: 'topics.list', methods: ['GET'])]
    public function topics(): StreamedJsonResponse
    {
        $generator = function () {
            $stmt = $this->db->pdo->query(
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

            while ($topic = $stmt->fetch()) {
                yield $topic;
            }
        };

        return $this->createStreamedResponse($generator());
    }

    #[Route('/topics/{id}', name: 'topics.view', methods: ['GET'])]
    public function topic(string $id): JsonResponse | StreamedJsonResponse
    {
        $stmt = $this->db->pdo->prepare(
            'SELECT id, title FROM topics WHERE id = ?'
        );
        $stmt->execute([$id]);
        $topic = $stmt->fetch();

        $generator = function () use ($id) {
            $stmt = $this->db->pdo->prepare(
                'SELECT id, topic_id, position, author, content, created_at
                FROM posts
                WHERE topic_id = ?
                ORDER BY created_at ASC'
            );
            $stmt->execute([$id]);

            while ($post = $stmt->fetch()) {
                yield $post;
            }    
        };
        
        if ($topic === false) {
            return new JsonResponse([
                'message' => "No topic found for id “{$id}”"
            ], 404);
        }

        return $this->createStreamedResponse([
            'id' => $topic['id'],
            'title' => $topic['title'],
            'posts' => $generator()
        ]);
    }

    #[Route('/posts', name: 'posts.list', methods: ['GET'])]
    public function posts(Request $request): StreamedJsonResponse | JsonResponse {
        $withoutTopicParam = $request->query->get('without_topic');
        $withoutTopic = filter_var(
            $withoutTopicParam,
            \FILTER_VALIDATE_BOOLEAN,
            \FILTER_NULL_ON_FAILURE
        );

        if ($withoutTopicParam !== null && $withoutTopic === null) {
            return $this->createErrorResponse(
                message: "The “without_topic” query parameter must be a valid boolean. Possible values: “1”, “true”, “on”, “yes”, “0”, “false”, “off”, “no”. “{$withoutTopicParam}” given.",
                httpCode: 400
            );
        }

        $generator = function () use ($withoutTopic): iterable {
            $sql = '
                SELECT id, topic_id, place, author, content, created_at
                FROM posts
            ';

            if ($withoutTopic === true) {
                $sql .= ' WHERE topic_id IS NULL';
            }

            $stmt = $this->db->pdo->query($sql);

            while ($post = $stmt->fetch()) {
                yield $post;
            }
        };

        return $this->createStreamedResponse($generator());
    }

    #[Route('/authors', name: 'authors.list', methods: ['GET'])]
    public function authors(): StreamedJsonResponse
    {
        $generator = function (): iterable {
            $stmt = $this->db->pdo->query(
                'SELECT DISTINCT author
                FROM posts
                WHERE author IS NOT NULL
                ORDER BY author ASC'
            );

            while ($author = $stmt->fetch(\PDO::FETCH_COLUMN)) {
                yield $author;
            }
        };

        return $this->createStreamedResponse($generator());
    }

    #[Route('/downloads/database', name: 'downloads.database', methods: ['GET'])]
    public function downloadDatabase(
        #[Autowire('%app.db_path%')] string $dbPath
    ): BinaryFileResponse {
        $this->db->pdo->exec('PRAGMA wal_checkpoint(FULL);');

        return new BinaryFileResponse($dbPath, ResponseHeaderBag::DISPOSITION_ATTACHMENT);
    }

    private function createStreamedResponse(iterable $data): StreamedJsonResponse
    {
        $response = new StreamedJsonResponse($data);
        $response->setPublic();
        $response->setMaxAge(self::RESPONSES_MAX_AGE);
        $response->setSharedMaxAge(self::RESPONSES_MAX_AGE);

        return $response;
    }

    private function createErrorResponse(string $message, int $httpCode): JsonResponse
    {
        return new JsonResponse(['message' => $message], $httpCode);
    }
}
