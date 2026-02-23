<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RequestItem extends Model
{
    protected $fillable = ['request_id', 'item_name', 'category', 'quantity', 'price'];

    public function procurementRequest()
    {
        return $this->belongsTo(Request::class, 'request_id');
    }
}
