<?php

namespace App\Models;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Model;

class Request extends Model
{
    use SoftDeletes;
    protected $fillable = ['user_id', 'department_id', 'status', 'total_amount'];

    public function items()
    {
        return $this->hasMany(RequestItem::class);
    }

    public function history()
    {
        return $this->hasMany(StatusHistory::class);
    }
}
