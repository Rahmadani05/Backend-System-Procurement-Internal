<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StatusHistory extends Model
{
    protected $table = 'status_history';
    const UPDATED_AT = null;
    protected $fillable = ['request_id', 'changed_by', 'old_status', 'new_status'];

    public function procurementRequest()
    {
        return $this->belongsTo(Request::class, 'request_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'changed_by');
    }
}
