<?php

declare(strict_types=1);

namespace App\DataFixtures\Dev;

use App\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;
use Symfony\Component\PasswordHasher\Hasher\SodiumPasswordHasher;

class UserFixtures extends Fixture
{
    public const COUNT = 30;

    public function load(ObjectManager $manager): void
    {
        $faker = Factory::create();

        $hasher = new SodiumPasswordHasher();

        $users = [];

        $users[] = [
            'username' => 'adrien',
            'email' => $faker->unique()->safeEmail(),
            'password' => 'adrien',
            'roles' => ['ROLE_USER', 'ROLE_GM', 'ROLE_ADMIN'],
        ];

        for ($i = 0; $i < self::COUNT; ++$i) {
            $users[] = [
                'username' => $faker->unique()->firstName,
                'email' => $faker->unique()->safeEmail,
                'password' => $faker->password(8, 100),
                'roles' => ['ROLE_USER']
            ];
        }

        for ($i = 0, $c = count($users); $i < $c; ++$i) {
            $user = new User();

            $user->username = $users[$i]['username'];
            $user->email = $users[$i]['email'];
            $user->password = $hasher->hash($users[$i]['password']);
            $user->addRoles($users[$i]['roles']);
            $user->isEnabled = $faker->boolean(92);
            $user->profilePicture = $faker->imageUrl();

            $this->setReference("user_$i", $user);
            $manager->persist($user);
        }

        $manager->flush();
    }
}
