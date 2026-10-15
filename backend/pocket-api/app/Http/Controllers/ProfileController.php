<?php

namespace App\Http\Controllers;

use App\Support\Msg;
use App\Support\Presenter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    /** GET /me */
    public function show(Request $request): JsonResponse
    {
        return response()->json(Presenter::me($request->user()));
    }

    /** PUT /me  {name, username} */
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'username' => [
                'required', 'string', 'regex:/^[A-Za-z0-9._]{3,20}$/',
                Rule::unique('users', 'username')->ignore($user->id),
            ],
        ], Msg::messages(), Msg::attributes());

        $user->update([
            'name' => trim($data['name']),
            'username' => $data['username'],
        ]);

        return response()->json(Presenter::me($user->fresh()));
    }
}
