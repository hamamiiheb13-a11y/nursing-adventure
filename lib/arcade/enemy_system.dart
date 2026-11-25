import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'weapon_system.dart';

enum EnemyType {
  helicoGrub,    // Bactérie gastrique ondulante (Helicobacter stylisé)
  spikeVirion,   // Virus rotatif à pointes
  cytokineBlob,  // Amibe inflammatoire sécrétant de l'acide
  acidSentry,    // Sentinelle blindée résistante
  toxicSpore,    // Spore instable flottante
}

class ArcadeEnemy {
  final int id;
  Offset position;
  Offset velocity;
  final EnemyType type;
  final int maxHp;
  int currentHp;
  final double radius;
  double animPhase;
  double hitFlashTimer;
  double shootCooldown;
  final double shootInterval;
  final int scoreReward;
  final int xpReward;
  bool isDead;
  double initialY;

  ArcadeEnemy({
    required this.id,
    required this.position,
    required this.velocity,
    required this.type,
    required this.maxHp,
    required this.radius,
    this.shootInterval = 2.5,
    this.scoreReward = 150,
    this.xpReward = 30,
    this.animPhase = 0.0,
    this.hitFlashTimer = 0.0,
    this.shootCooldown = 1.0,
    this.isDead = false,
    double? initialY,
  })  : currentHp = maxHp,
        initialY = initialY ?? position.dy;

  bool get isFlashing => hitFlashTimer > 0;

  void takeDamage(int dmg) {
    currentHp = math.max(0, currentHp - dmg);
    hitFlashTimer = 0.25;
    if (currentHp <= 0) {
      isDead = true;
    }
  }

  void update(double dt, Offset playerPos, List<CapsuleProjectile> enemyProjectiles) {
    if (isDead) return;

    animPhase += dt * 3.5;
    if (hitFlashTimer > 0) {
      hitFlashTimer = math.max(0, hitFlashTimer - dt);
    }

    // Specific enemy movement behaviors
    switch (type) {
      case EnemyType.helicoGrub:
        // Undulating horizontal drift
        final waveY = initialY + math.sin(animPhase * 2.0) * 35.0;
        position = Offset(position.dx + velocity.dx * dt, waveY);
        break;

      case EnemyType.spikeVirion:
        // Tracking viral capsule: glides steadily left while adjusting toward player altitude
        final dy = (playerPos.dy - position.dy).clamp(-65.0, 65.0);
        final trackY = (position.dx - playerPos.dx).abs() < 420 ? dy * 1.15 : 0.0;
        position = Offset(
          position.dx + velocity.dx * dt,
          position.dy + trackY * dt,
        );
        break;

      case EnemyType.cytokineBlob:
        // Hovering and shooting acid globule toward capsule
        final bobY = initialY + math.sin(animPhase * 1.5) * 25.0;
        position = Offset(position.dx + velocity.dx * dt, bobY);

        shootCooldown -= dt;
        if (shootCooldown <= 0 && (position.dx - playerPos.dx).abs() < 550) {
          shootCooldown = shootInterval;
          final dir = (playerPos - position);
          final normDir = dir.distance > 0 ? dir / dir.distance : const Offset(-1, 0);
          enemyProjectiles.add(
            CapsuleProjectile(
              position: position,
              velocity: normDir * 220.0,
              damage: 1,
              color: const Color(0xFFEF4444),
              radius: 6.0,
              isEnemy: true,
            ),
          );
        }
        break;

      case EnemyType.acidSentry:
        // Guarding vertical column and shooting twin bursts
        final sweepY = initialY + math.sin(animPhase * 2.5) * 60.0;
        position = Offset(position.dx + velocity.dx * dt, sweepY);

        shootCooldown -= dt;
        if (shootCooldown <= 0 && (position.dx - playerPos.dx).abs() < 600) {
          shootCooldown = shootInterval;
          enemyProjectiles.add(
            CapsuleProjectile(
              position: position + const Offset(-15, -6),
              velocity: const Offset(-260.0, -30.0),
              damage: 1,
              color: const Color(0xFFF59E0B),
              radius: 5.5,
              isEnemy: true,
            ),
          );
          enemyProjectiles.add(
            CapsuleProjectile(
              position: position + const Offset(-15, 6),
              velocity: const Offset(-260.0, 30.0),
              damage: 1,
              color: const Color(0xFFF59E0B),
              radius: 5.5,
              isEnemy: true,
            ),
          );
        }
        break;

      case EnemyType.toxicSpore:
        // Slow drifting explosive mine
        final driftY = initialY + math.cos(animPhase) * 15.0;
        position = Offset(position.dx + velocity.dx * dt, driftY);
        break;
    }
  }
}
