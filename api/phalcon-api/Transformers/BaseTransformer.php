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

namespace Phalcon\Api\Transformers;

use Discoveryfy\Exceptions\ModelException;
use League\Fractal\Resource\Collection;
use League\Fractal\Resource\Item;
use League\Fractal\TransformerAbstract;
use Phalcon\Api\Mvc\Model\AbstractModel;
use function array_intersect;
use function array_keys;

/**
 * Class BaseTransformer
 *
 * @see https://fractal.thephpleague.com/transformers/
 * @package Phalcon\Api\Transformers
 */
class BaseTransformer extends TransformerAbstract
{
    /** @var array */
    private $fields = [];

    /** @var string */
    private $resource = '';

    /**
     * BaseTransformer constructor.
     *
     * @param array  $fields
     * @param string $resource
     */
    public function __construct(array $fields = [], string $resource = '')
    {
        $this->fields   = $fields;
        $this->resource = $resource;
    }

    /**
     * @param AbstractModel $model
     *
     * @return array
     * @throws ModelException
     */
    public function transform(AbstractModel $model)
    {
        $modelFields     = array_keys($model->getPublicAttributes());
        $requestedFields = $this->fields[$this->resource] ?? $modelFields;
        $fields          = array_intersect($modelFields, $requestedFields);
        $data            = [];
        foreach ($fields as $field) {
            if ($field === 'created_at') {
                $data[$field] = $model->getCreatedAt()->format(\DateTime::ATOM);
            } else if ($field === 'updated_at' && !empty($model->get($field))) {
                $data[$field] = $model->getUpdatedAt()->format(\DateTime::ATOM);
            } else {
                $data[$field] = $model->get($field);
            }
        }

        return $data;
    }

    /**
     * @param string        $method
     * @param AbstractModel $model
     * @param string        $transformer
     * @param string        $resource
     *
     * @return Collection|Item
     */
    protected function getRelatedData(string $method, AbstractModel $model, string $transformer, string $resource)
    {
        /** @var AbstractModel $data */
        $data = $model->getRelated($resource);

        return $this->$method($data, new $transformer($this->fields, $resource), $resource);
    }
}
