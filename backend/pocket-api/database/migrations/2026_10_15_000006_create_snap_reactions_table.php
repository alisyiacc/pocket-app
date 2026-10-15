<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// Satu user hanya punya satu reaksi per foto (reaksi baru menggantikan yang lama).
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('snap_reactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('snap_id')->constrained('snaps')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('emoji', 32);
            $table->timestamps();

            $table->unique(['snap_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('snap_reactions');
    }
};
