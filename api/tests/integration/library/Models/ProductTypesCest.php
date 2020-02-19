<?php

namespace Phalcon\Api\Tests\integration\library\Models;

use IntegrationTester;
use Discoveryfy\Constants\Relationships;
use Discoveryfy\Models\Products;
use Discoveryfy\Models\ProductTypes;
use Phalcon\Filter;

class ProductTypesCest
{
    public function validateModel(IntegrationTester $I)
    {
        $I->haveModelDefinition(
            ProductTypes::class,
            [
                'id',
                'name',
                'description',
            ]
        );
    }

    public function validateFilters(IntegrationTester $I)
    {
        $model    = new ProductTypes();
        $expected = [
            'id'          => Filter::FILTER_ABSINT,
            'name'        => Filter::FILTER_STRING,
            'description' => Filter::FILTER_STRING,
        ];
        $I->assertEquals($expected, $model->getModelFilters());
    }

    public function validateRelationships(IntegrationTester $I)
    {
        $actual   = $I->getModelRelationships(ProductTypes::class);
        $expected = [
            [2, 'id', Products::class, 'typeId', ['alias' => Relationships::PRODUCTS, 'reusable' => true]],
        ];
        $I->assertEquals($expected, $actual);
    }
}
