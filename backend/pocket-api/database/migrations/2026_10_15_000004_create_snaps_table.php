<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// image_path = nama file di public/uploads/snaps
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('snaps', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->string('image_path');
            $table->string('caption', 255)->default('');
            $table->timestamps();

            $table->index(['sender_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('snaps');
    }
};
