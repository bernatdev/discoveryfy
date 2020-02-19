<?php

namespace Phalcon\Api\Tests\integration\library\Models;

use IntegrationTester;
use Discoveryfy\Constants\Relationships;
use Discoveryfy\Models\Companies;
use Discoveryfy\Models\CompaniesXProducts;
use Discoveryfy\Models\Products;
use Phalcon\Filter;

class CompaniesXProductsCest
{
    public function validateModel(IntegrationTester $I)
    {
        $I->haveModelDefinition(
            CompaniesXProducts::class,
            [
                'companyId',
                'productId',
            ]
        );
    }

    public function validateFilters(IntegrationTester $I)
    {
        $model    = new CompaniesXProducts();
        $expected = [
            'companyId' => Filter::FILTER_ABSINT,
            'productId' => Filter::FILTER_ABSINT,
        ];
        $I->assertEquals($expected, $model->getModelFilters());
    }

    public function validateRelationships(IntegrationTester $I)
    {
        $actual   = $I->getModelRelationships(CompaniesXProducts::class);
        $expected = [
            [0, 'companyId', Companies::class, 'id', ['alias' => Relationships::COMPANIES, 'reusable' => true]],
            [0, 'productId', Products::class, 'id', ['alias' => Relationships::PRODUCTS, 'reusable' => true]],
        ];
        $I->assertEquals($expected, $actual);
    }
}
