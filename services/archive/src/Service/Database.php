<?php

declare(strict_types=1);

namespace App\Service;

use Symfony\Component\DependencyInjection\Attribute\Autowire;

final readonly class Database
{
    public \PDO $pdo;

    public function __construct(
        #[Autowire('%app.db_path%')] string $dbPath
    ) {
        $this->pdo = new \PDO(
            dsn: 'sqlite:' . $dbPath,
            username: null,
            password: null,
            options: [
                \PDO::SQLITE_ATTR_OPEN_FLAGS => \PDO::SQLITE_OPEN_READONLY,
                \PDO::ATTR_PERSISTENT => true,
                \PDO::ATTR_ERRMODE => \PDO::ERRMODE_EXCEPTION,
                \PDO::ATTR_DEFAULT_FETCH_MODE => \PDO::FETCH_ASSOC
            ]
        );

        // Optimizations
        $this->pdo->exec('PRAGMA journal_mode = WAL;');
        $this->pdo->exec('PRAGMA synchronous = NORMAL;');
        $this->pdo->exec('PRAGMA cache_size = 10000;');
        $this->pdo->exec('PRAGMA temp_store = MEMORY;');
        $this->pdo->exec('PRAGMA mmap_size = 30000000;');
    }
}
