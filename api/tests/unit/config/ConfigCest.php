<?php

namespace Discoveryfy\Tests\unit\config;

use UnitTester;
use function is_array;
use function Phalcon\Api\Core\appPath;

class ConfigCest
{
    public function checkConfig(UnitTester $I)
    {
        $config = require(appPath('config/config.php'));

        $I->assertTrue(is_array($config));
        $I->assertTrue(isset($config['app']));
        $I->assertTrue(isset($config['cache']));
        $I->assertTrue(isset($config['routers']));
        $I->assertTrue(isset($config['public_routes']));
    }
}
