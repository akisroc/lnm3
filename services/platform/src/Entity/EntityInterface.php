<?php

declare(strict_types=1);

namespace App\Entity;

use DateTime;
use Symfony\Component\Uid\Uuid;

interface EntityInterface
{
    public null|\Symfony\Component\Uid\Uuid $id {
        get;
    }

    public \DateTime|null $createdAt {
        get;
    }

    public \DateTime|null $updatedAt {
        get;
    }
}
