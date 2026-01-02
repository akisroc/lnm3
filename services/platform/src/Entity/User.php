<?php

declare(strict_types=1);

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Gedmo\Mapping\Annotation as Gedmo;
use Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity;
use Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface;
use Symfony\Component\Security\Core\User\UserInterface;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\Validator\Context\ExecutionContextInterface;

#[ORM\Entity]
#[ORM\Table(name: 'users')]
#[UniqueEntity('username', message: 'violation.username.not_unique')]
#[UniqueEntity('email', message: 'violation.email.not_unique')]
#[UniqueEntity('slug', message: 'violation.slug.not_unique')]
class User extends AbstractEntity implements UserInterface, PasswordAuthenticatedUserInterface
{
    #[ORM\Column(type: 'string', length: 31, unique: true, nullable: false)]
    #[Assert\NotBlank(message: 'violation.name.blank')]
    #[Assert\Regex(
        pattern: '/^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ\'’\-]+$/',
        message: 'violation.name.invalid_characters',
    )]
    #[Assert\Length(
        min: 1,
        max: 30,
        minMessage: 'violation.name.too_short',
        maxMessage: 'violation.name.too_long'
    )]
    public ?string $username = null;

    #[ORM\Column(type: 'string', length: 255, unique: true, nullable: false)]
    #[Assert\NotBlank(message: 'violation.email.blank')]
    #[Assert\Email(message: 'violation.email.wrong_format')]
    public ?string $email = null;

    #[ORM\Column(type: 'string', length: 511, nullable: true)]
    #[Assert\Url(message: 'violation.url.wrong_format')]
    #[Assert\Length(
        min: 1,
        max: 500,
        minMessage: 'violation.url.too_short',
        maxMessage: 'violation.url.too_long'
    )]
    public ?string $profilePicture = null;

    #[ORM\Column(type: 'string', length: 511, nullable: false)]
    public ?string $password = null;

//    #[Assert\NotBlank(message: 'violation.password.blank')]
//     #[Assert\Length(
//         min: 8,
//         max: 4000,
//         minMessage: 'violation.password.too_short',
//         maxMessage: 'violation.password.too_long'
//     )]
//    public ?string $plainPassword = null {
//        get { return $this->plainPassword; }
//        set { $this->plainPassword = $value; }
//    }

//    #[ORM\Column(type: 'string', length: 127, nullable: false)]
//     public ?string $salt = null {
//        get { return $this->salt; }
//        set { $this->salt = $value; }
//    }

    #[ORM\Column(type: 'json', length: 31, nullable: false)]
    #[Assert\NotBlank]
    public array $roles = ['ROLE_USER'];

    #[ORM\Column(type: 'string', length: 63, unique: true, nullable: false)]
    #[Gedmo\Slug(fields: ['username'])]
     public ?string $slug = null;

    #[ORM\Column(type: 'boolean', nullable: false)]
     public bool $isEnabled = true;

    public function __construct()
     {
//         $this->salt = $this->generateSalt();
     }

     public function getRoles(): array
     {
         return $this->roles;
     }

    public function hasRole(string $role): bool
    {
        return in_array($role, $this->roles, true);
    }

    public function isAdmin(): bool
    {
        return $this->hasRole('ROLE_ADMIN');
    }

    public function addRoles(iterable $roles): void
    {
        foreach ($roles as $role) {
            $this->addRole($role);
        }
    }

    public function addRole(string $role): void
    {
        if (!in_array($role, $this->roles, true)) {
            $this->roles[] = $role;
        }
    }

    public function getUserIdentifier(): string
    {
        return $this->username;
    }

    public function getPassword(): ?string
    {
        return $this->password;
    }

//    public function eraseCredentials(): void
//    {
//        $this->plainPassword = null;
//    }

//     private function generateSalt(): string
//     {
//         return substr(base64_encode(random_bytes(64)), 8, 72);
//     }

    #[Assert\Callback]
    public function validateRoles(ExecutionContextInterface $context, array $payload): void
    {
        foreach ($this->roles as $role) {
            if (strpos($role, 'ROLE_') !== 0) {
                $context
                    ->buildViolation('violation.roles.wrong_format')
                    ->atPath('roles')
                    ->addViolation();
            }
        }

        if (false === in_array('ROLE_USER', $this->roles, true)) {
            $context
                ->buildViolation('violation.roles.missing_user_role')
                ->atPath('roles')
                ->addViolation();
        }
    }
}
