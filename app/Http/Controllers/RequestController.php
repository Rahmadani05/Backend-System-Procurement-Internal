<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request as HttpRequest;
use App\Models\Request;
use App\Models\StatusHistory;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

use function Symfony\Component\Clock\now;

class RequestController extends Controller
{
    public function index(HttpRequest $request)
    {
        $query = Request::with(['items', 'history']);

        if ($request->has('status')){
            $status = strtoupper($request->query('status'));
            $query->where('status', $status);
        }

        $procurementRequests = $query->get();

        return response()->json([
            'message' => 'Data request Berhasil Diambil',
            'data' => $procurementRequests
        ], 200);
    }

    public function store(HttpRequest $request)
    {
        $validated = $request->validate([
            'items' => 'required|array',
            'items.*.item_name' => 'required|string',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.category' => 'required|string'
        ]);

        DB::beginTransaction();
        try{
            $user = $request->user();
            $newRequest = Request::create([
                'user_id' => $user->id,
                'department_id' => $user->department_id,
                'status' => 'SUBMITTED'
            ]);

            $newRequest->items()->createMany($validated['items']);
            DB::commit();
            return response()->json([
                'message' => 'Request Berhasil Dibuat', 'data' => $newRequest
            ], 201);
        }
        catch (\Exception $e){
            DB::rollBack();
            return response()->json([
                'message' => 'Gagal Dibuat'
            ], 500);
        }
    }

    public function approve(HttpRequest $request, $id)
    {
        DB::beginTransaction();
        try{
            $procReq = Request::where('id', $id)->lockForUpdate()->firstOrFail();

            if ($procReq->status !== 'SUBMITTED'){
                return response()->json([
                    'error' => 'Hanya Status Submitted Yang Bisa Di Approve'
                ], 400);
            }

            $procReq->status = "APPROVED";
            $procReq->save();

            StatusHistory::create([
                'request_id' => $id,
                'changed_by' => Auth::id(),
                'old_status' => 'SUBMITTED',
                'new_status' => 'APPROVED'
            ]);

            DB::commit();
            return response()->json([
                'message' => 'Status Update Ke APPROVED'
            ]);
        }
        catch (\Exception $e){
            DB::rollBack();
            return response()->json([
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function reject(HttpRequest $request, $id)
    {
        $validated = $request->validate([
            'notes' => 'required|string'
        ]);

        DB::beginTransaction();
        try{
            $procurementRequests = Request::where('id', $id)->lockForUpdate()->firstOrFail();
            
            if (in_array($procurementRequests->status, ['APPROVED', 'REJECTED', 'COMPLETED'])){
                return response()->json([
                    'error' => 'Request Sudah Di Proses'
                ], 400);
            }

            $oldStatus = $procurementRequests->status;
            $procurementRequests->status = 'REJECTED';
            $procurementRequests->save();

            StatusHistory::create([
                'request_id' => $procurementRequests->id,
                'changed_by' => Auth::id(),
                'old_status' => $oldStatus,
                'new_status' => 'REJECTED'
            ]);

            DB::table('approvals')->insert([
                'request_id' => $procurementRequests->id,
                'approver_id' => Auth::id(),
                'status' => 'REJECTED',
                'notes' => $validated['notes'],
                'created_at' => now()
            ]);

            DB::commit();
            return response()->json([
                'message' => 'Request Berhasil Di Reject'
            ]);
        }
        catch (\Exception $e){
            DB::rollBack();
            return response()->json([
                'error' => 'Conflict atau Error'
            ], 409);
        }
    }

    public function procure(HttpRequest $request, $id)
    {
        $validated = $request->validate(['vendor_id' => 'required|exists:vendors,id']);

        DB::beginTransaction();
        try{
            $procReq = Request::where('id', $id)->lockForUpdate()->firstOrFail();

            if ($procReq->status !== 'APPROVED'){
                return response()->json([
                    'error' => 'Request Harus APPROVED Dulu'
                ], 400);
            }

            $procReq->status = 'IN_PROCUREMENT';
            $procReq->save();

            DB::table('procurement_orders')->insert([
                'request_id' => $id,
                'vendor_id' => $validated['vendor_id'],
                'status' => 'PENDING',
                'created_at' => now()
            ]);

            DB::commit();
            return response()->json([
                'message' => 'Status Update ke IN_PROCUREMENT'
            ]);
        }
        catch (\Exception $e){
            DB::rollBack();
            return response()->json([
                'error' => 'Gagal Membuat'
            ], 500);
        }
    }

    public function complete(HttpRequest $request, $id)
    {
        return DB::transaction(function () use ($id){
            $procReq = Request::where('id', $id)->lockForUpdate()->firstOrFail();

            if (!in_array($procReq->status, ['IN_PROCUREMENT', 'APPROVED'])){
                return response()->json([
                    'error' => 'Status Tidak Valid Untuk Diselesaikan'
                ], 400);
            }

            $oldStatus = $procReq->status;
            $procReq->update(['status' => 'COMPLETED']);

            StatusHistory::created([
                'request_id' => $id,
                'changed_by' => Auth::id(),
                'old_status' => $oldStatus,
                'new_status' => 'COMPLETE'
            ]);

            if($oldStatus === 'IN_PROCUREMENT'){
                DB::table('procurement_orders')
                ->where('request_id', $id)
                ->update(['status' => 'RECEIVED', 'updated_at' =>now()]);
            }
            return response()->json([
                'message' => 'Request Complete Berhasil'
            ]);
        });
    }
}
