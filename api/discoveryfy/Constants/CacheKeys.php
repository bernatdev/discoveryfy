<?php
declare(strict_types=1);

/**
 * This file is part of the Discoveryfy.
 *
 * For the full copyright and license information, please view
 * the LICENSE file that was distributed with this source code.
 */

namespace Discoveryfy\Constants;

use Lcobucci\JWT\Token;

class CacheKeys
{
    const LOGIN_CSRF        = 'login.csrf.';
    const REGISTER_CSRF     = 'register.csrf.';
    const JWT               = 'jwt.';

    public static function getLoginCSRFCacheKey(string $csrf_token): string
    {
        return self::LOGIN_CSRF.$csrf_token;
    }

    public static function getRegisterCSRFCacheKey(string $csrf_token): string
    {
        return self::REGISTER_CSRF.$csrf_token;
    }

    public static function getJWTCacheKey(Token $token): string
    {
        return self::REGISTER_CSRF.$token->__toString();
    }

    public static function getModelCacheKey(string $model, string $uuid): string
    {
        return sprintf('%s.%s', $model, $uuid);
    }
}