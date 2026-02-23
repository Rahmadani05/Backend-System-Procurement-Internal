<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\RequestController;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function(){
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::post('/requests', [RequestController::class, 'store']);
    Route::get('/requests', [RequestController::class, 'index']);

    Route::post('/requests/{id}/approve', [RequestController::class, 'approve']);
    Route::post('/requests/{id}/reject', [RequestController::class, 'reject']);
    Route::post('/requests/{id}/procure', [RequestController::class, 'procure']);
    Route::post('/requests/{id}/complete', [RequestController::class, 'complete']);

});
