<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('snap_recipients', function (Blueprint $table) {
            $table->id();
            $table->foreignId('snap_id')->constrained('snaps')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();

            $table->unique(['snap_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('snap_recipients');
    }
};
