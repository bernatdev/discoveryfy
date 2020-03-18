<?php
declare(strict_types=1);

/**
 * This file is part of the Phalcon API.
 *
 * (c) Phalcon Team <team@phalcon.io>
 *
 * For the full copyright and license information, please view
 * the LICENSE file that was distributed with this source code.
 */

namespace Phalcon\Api\Providers;

use Phalcon\Cache\AdapterFactory;
use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
//use Phalcon\Mvc\Model\MetaData\Libmemcached;
use Phalcon\Mvc\Model\MetaData\Memory;
use Phalcon\Storage\SerializerFactory;
use function Phalcon\Api\Core\appPath;
use function Phalcon\Api\Core\envValue;

class ModelsMetadataProvider implements ServiceProviderInterface
{
    /**
     * @param DiInterface $container
     */
    public function register(DiInterface $container): void
    {
        $container->setShared(
            'modelsMetadata',
            function () {
//                $backOptions = [
//                    'servers'  => [
//                        0 => [
//                            'host'   => envValue('DATA_API_MEMCACHED_HOST', '127.0.0.1'),
//                            'port'   => envValue('DATA_API_MEMCACHED_PORT', 11211),
//                            'weight' => envValue('DATA_API_MEMCACHED_WEIGHT', 100),
//                        ],
//                    ],
//                    'client'   => [
//                        \Memcached::OPT_PREFIX_KEY => 'api-',
//                    ],
//                    'lifetime' => 3600,
//                    'prefix'   => 'metadata-',
//                ];
//
//                $serializer = new SerializerFactory();
//                $adapterFactor = new AdapterFactory($serializer);
//
//                return new Libmemcached($adapterFactor, $backOptions);
                return new Memory([
                    'cacheDir' => appPath('storage/cache/data/'),
                    'prefix'   => 'data-',
                ]);
            }
        );
    }
}
