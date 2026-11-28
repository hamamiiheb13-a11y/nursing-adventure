import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'weapon_system.dart';

enum EnemyType {
  helicoGrub,    // Bactérie agile : esquive les tirs et tente de fuir si on s'approche
  spikeVirion,   // Virus chasseur : repère, accélère et poursuit activement la capsule
  cytokineBlob,  // Amibe tactique : garde ses distances, esquive et crache des globules ciblés
  acidSentry,    // Sentinelle blindée : intercepte la trajectoire et tire des rafales prédictives
  toxicSpore,    // Spore nerveuse : bondit et tente d'esquiver / échapper en diagonale
}

enum EnemyBehaviorState {
  patrol,
  chase,
  flee,
  dodge,
  attackWindup,
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

  // Dynamic AI & rich animation state
  EnemyBehaviorState behaviorState = EnemyBehaviorState.patrol;
  double attackAnimTimer = 0.0;
  double attackRecoilTimer = 0.0;
  double damageWobbleTimer = 0.0;
  double dodgeTimer = 0.0;
  double dodgeCooldown = 0.0;
  double dodgeDirY = 1.0;
  double facingTilt = 0.0;
  double lungeBoostTimer = 0.0;
  bool justAttacked = false;
  Offset knockbackVel = Offset.zero;
  final double _baseHorizontalSpeed;

  ArcadeEnemy({
    required this.id,
    required this.position,
    required this.velocity,
    required this.type,
    required this.maxHp,
    required this.radius,
    this.shootInterval = 2.4,
    this.scoreReward = 150,
    this.xpReward = 30,
    this.animPhase = 0.0,
    this.hitFlashTimer = 0.0,
    this.shootCooldown = 1.0,
    this.isDead = false,
    double? initialY,
  })  : currentHp = maxHp,
        initialY = initialY ?? position.dy,
        _baseHorizontalSpeed = velocity.dx;

  bool get isFlashing => hitFlashTimer > 0;
  bool get isWindingUpAttack => attackAnimTimer > 0;
  bool get isDodging => dodgeTimer > 0;
  bool get isFleeing => behaviorState == EnemyBehaviorState.flee;
  bool get isChasing => behaviorState == EnemyBehaviorState.chase;
  bool get isInjured => currentHp <= (maxHp * 0.5).floor();

  void takeDamage(int dmg, {Offset hitDirection = const Offset(1, 0)}) {
    currentHp = math.max(0, currentHp - dmg);
    hitFlashTimer = 0.24;
    damageWobbleTimer = 0.34;
    knockbackVel = Offset(hitDirection.dx * 115.0, hitDirection.dy * 45.0);
    if (currentHp <= 0) {
      isDead = true;
    }
  }

  double? _detectIncomingShotDodgeDir(
    List<CapsuleProjectile>? playerProjectiles,
    double ceilY,
    double floorY,
  ) {
    if (playerProjectiles == null || playerProjectiles.isEmpty) return null;
    for (final p in playerProjectiles) {
      if (p.isEnemy || p.isDead || p.velocity.dx <= 0) continue;
      final dx = position.dx - p.position.dx;
      final dy = position.dy - p.position.dy;
      if (dx > -10 && dx < 200 && dy.abs() < radius + 34.0) {
        double dirY = dy >= 0 ? 1.0 : -1.0;
        if (dirY > 0 && position.dy > floorY - radius - 48) dirY = -1.0;
        if (dirY < 0 && position.dy < ceilY + radius + 48) dirY = 1.0;
        return dirY;
      }
    }
    return null;
  }

  void update(
    double dt,
    Offset playerPos,
    List<CapsuleProjectile> enemyProjectiles, {
    List<CapsuleProjectile>? playerProjectiles,
    double ceilY = 60.0,
    double floorY = 440.0,
    double speedMultiplier = 1.0,
  }) {
    if (isDead) return;

    animPhase += dt * (3.6 * (0.9 + speedMultiplier * 0.12));
    if (hitFlashTimer > 0) hitFlashTimer = math.max(0.0, hitFlashTimer - dt);
    if (damageWobbleTimer > 0) damageWobbleTimer = math.max(0.0, damageWobbleTimer - dt);
    if (attackRecoilTimer > 0) attackRecoilTimer = math.max(0.0, attackRecoilTimer - dt);
    if (dodgeCooldown > 0) dodgeCooldown = math.max(0.0, dodgeCooldown - dt);
    if (dodgeTimer > 0) dodgeTimer = math.max(0.0, dodgeTimer - dt);
    if (lungeBoostTimer > 0) lungeBoostTimer = math.max(0.0, lungeBoostTimer - dt);
    justAttacked = false;

    // Exponential decay for smooth impact knockback
    final kbDecay = math.pow(0.03, dt).toDouble();
    knockbackVel = knockbackVel * kbDecay;

    final Offset toPlayer = playerPos - position;
    final double distToPlayer = toPlayer.distance;
    final Offset dirToPlayer = distToPlayer > 1.0 ? toPlayer / distToPlayer : const Offset(-1, 0);

    // 1. Evasive dodge check for agile/tactical types
    final bool canDodge = type == EnemyType.helicoGrub ||
        type == EnemyType.toxicSpore ||
        type == EnemyType.cytokineBlob;
    if (canDodge && dodgeCooldown <= 0 && dodgeTimer <= 0) {
      final dodgeY = _detectIncomingShotDodgeDir(playerProjectiles, ceilY, floorY);
      if (dodgeY != null) {
        dodgeDirY = dodgeY;
        dodgeTimer = type == EnemyType.cytokineBlob ? 0.28 : 0.38;
        dodgeCooldown = type == EnemyType.helicoGrub ? 0.95 : 1.35;
        behaviorState = EnemyBehaviorState.dodge;
      }
    }

    Offset desiredVel = Offset(_baseHorizontalSpeed * speedMultiplier, 0);
    final double centerCorridorY = (ceilY + floorY) * 0.5;

    switch (type) {
      case EnemyType.helicoGrub:
        // Evasive runner: dodges shots & flees away if player closes in!
        if (dodgeTimer > 0) {
          behaviorState = EnemyBehaviorState.dodge;
          desiredVel = Offset(
            45.0 * speedMultiplier,
            dodgeDirY * 240.0 * speedMultiplier,
          );
        } else if (distToPlayer < 225.0) {
          behaviorState = EnemyBehaviorState.flee;
          final double fleeDirY = (position.dy >= playerPos.dy ? 1.0 : -1.0);
          desiredVel = Offset(
            105.0 * speedMultiplier,
            (fleeDirY * 145.0 + math.sin(animPhase * 2.8) * 75.0) * speedMultiplier,
          );
        } else {
          behaviorState = EnemyBehaviorState.patrol;
          desiredVel = Offset(
            _baseHorizontalSpeed * 1.15 * speedMultiplier,
            math.cos(animPhase * 2.0) * 115.0 * speedMultiplier,
          );
        }
        break;

      case EnemyType.toxicSpore:
        // Aggressive volatile mine: stealth patrols, then actively hunts player & fires spore burst!
        if (dodgeTimer > 0) {
          behaviorState = EnemyBehaviorState.dodge;
          desiredVel = Offset(
            90.0 * speedMultiplier,
            dodgeDirY * 220.0 * speedMultiplier,
          );
        } else if (distToPlayer < 175.0) {
          behaviorState = EnemyBehaviorState.flee;
          final escapeSignX = position.dx >= playerPos.dx ? 1.0 : -1.0;
          final escapeSignY = position.dy >= playerPos.dy ? 1.0 : -1.0;
          desiredVel = Offset(
            escapeSignX * 118.0 * speedMultiplier,
            escapeSignY * 145.0 * speedMultiplier,
          );
        } else if (distToPlayer < 410.0) {
          behaviorState = EnemyBehaviorState.chase;
          desiredVel = dirToPlayer * (128.0 * speedMultiplier);
          if (attackAnimTimer > 0) {
            behaviorState = EnemyBehaviorState.attackWindup;
            attackAnimTimer = math.max(0.0, attackAnimTimer - dt);
            if (attackAnimTimer <= 0 && distToPlayer < 460.0) {
              for (int k = -1; k <= 1; k += 2) {
                final ang = math.atan2(toPlayer.dy, toPlayer.dx) + k * 0.34;
                enemyProjectiles.add(
                  CapsuleProjectile(
                    position: position,
                    velocity: Offset(math.cos(ang), math.sin(ang)) * (215.0 * speedMultiplier),
                    damage: 1,
                    color: const Color(0xFF34D399),
                    radius: 5.5,
                    isEnemy: true,
                  ),
                );
              }
              justAttacked = true;
              attackRecoilTimer = 0.20;
            }
          } else {
            shootCooldown -= dt * speedMultiplier;
            if (shootCooldown <= 0 && speedMultiplier >= 1.08 && distToPlayer < 380.0) {
              shootCooldown = shootInterval * 1.25;
              attackAnimTimer = 0.32;
            }
          }
        } else {
          behaviorState = EnemyBehaviorState.patrol;
          final targetY = centerCorridorY + math.sin(animPhase * 1.4) * 75.0;
          desiredVel = Offset(
            _baseHorizontalSpeed * 1.15 * speedMultiplier,
            (targetY - position.dy) * 2.2 * speedMultiplier,
          );
        }
        break;

      case EnemyType.spikeVirion:
        // Active Chaser / Predator: locks on, winds up spines, lunges & spits spike pellet!
        if (distToPlayer < 560.0) {
          if (attackAnimTimer > 0) {
            attackAnimTimer = math.max(0.0, attackAnimTimer - dt);
            behaviorState = EnemyBehaviorState.attackWindup;
            desiredVel = dirToPlayer * (62.0 * speedMultiplier);
            if (attackAnimTimer <= 0) {
              lungeBoostTimer = 0.48;
              attackRecoilTimer = 0.22;
              if (distToPlayer < 480.0 && speedMultiplier >= 1.05) {
                enemyProjectiles.add(
                  CapsuleProjectile(
                    position: position + dirToPlayer * (radius + 4),
                    velocity: dirToPlayer * (250.0 * speedMultiplier),
                    damage: 1,
                    color: const Color(0xFFF43F5E),
                    radius: 5.8,
                    isEnemy: true,
                  ),
                );
                justAttacked = true;
              }
            }
          } else {
            behaviorState = EnemyBehaviorState.chase;
            final double lungeMul = lungeBoostTimer > 0 ? 1.48 : 1.0;
            final double chaseSpeed =
                (distToPlayer < 260.0 ? 205.0 : 158.0) * speedMultiplier * lungeMul;
            desiredVel = dirToPlayer * chaseSpeed;
            if (shootCooldown > 0) {
              shootCooldown -= dt;
              if (shootCooldown <= 0 && distToPlayer < 320.0) {
                attackAnimTimer = 0.28;
                shootCooldown = 2.2;
              }
            }
          }
        } else {
          behaviorState = EnemyBehaviorState.patrol;
          desiredVel = Offset(
            _baseHorizontalSpeed * 1.30 * speedMultiplier,
            math.sin(animPhase * 1.8) * 58.0,
          );
        }
        break;

      case EnemyType.cytokineBlob:
        // Ranged Tactical Kiter: keeps optimal range, winds up glow, spits aimed acid!
        if (dodgeTimer > 0) {
          behaviorState = EnemyBehaviorState.dodge;
          desiredVel = Offset(30.0, dodgeDirY * 170.0 * speedMultiplier);
        } else if (distToPlayer < 190.0) {
          behaviorState = EnemyBehaviorState.flee;
          desiredVel = Offset(
            82.0 * speedMultiplier,
            (position.dy >= playerPos.dy ? 1.0 : -1.0) * 110.0 * speedMultiplier,
          );
        } else {
          final double desiredRangeVx = distToPlayer > 380.0
              ? _baseHorizontalSpeed * 1.3 * speedMultiplier
              : -12.0 * speedMultiplier;
          final double trackVy = ((playerPos.dy - position.dy).clamp(-95.0, 95.0) * 0.85) +
              math.sin(animPhase * 1.6) * 28.0;
          desiredVel = Offset(desiredRangeVx, trackVy);
        }

        if (attackAnimTimer > 0) {
          behaviorState = EnemyBehaviorState.attackWindup;
          attackAnimTimer = math.max(0.0, attackAnimTimer - dt);
          if (attackAnimTimer <= 0 && distToPlayer < 600.0) {
            final shootDir = distToPlayer > 0 ? toPlayer / distToPlayer : const Offset(-1, 0);
            enemyProjectiles.add(
              CapsuleProjectile(
                position: position + shootDir * (radius + 4),
                velocity: shootDir * (250.0 * speedMultiplier),
                damage: 1,
                color: const Color(0xFFFB7185),
                radius: 6.5,
                isEnemy: true,
              ),
            );
            justAttacked = true;
            attackRecoilTimer = 0.22;
          }
        } else {
          shootCooldown -= dt * (0.9 + speedMultiplier * 0.1);
          if (shootCooldown <= 0 && distToPlayer < 560.0) {
            shootCooldown = shootInterval / (0.85 + speedMultiplier * 0.15);
            attackAnimTimer = 0.36;
          }
        }
        break;

      case EnemyType.acidSentry:
        // Armored Reactive Striker: tracks player lane & fires aimed twin/triple bursts
        final double trackVy = (playerPos.dy - position.dy).clamp(-115.0, 115.0) * 1.18;
        desiredVel = Offset(
          distToPlayer > 430.0 ? _baseHorizontalSpeed * speedMultiplier : -20.0 * speedMultiplier,
          trackVy + math.sin(animPhase * 2.1) * 35.0,
        );

        if (attackAnimTimer > 0) {
          behaviorState = EnemyBehaviorState.attackWindup;
          attackAnimTimer = math.max(0.0, attackAnimTimer - dt);
          if (attackAnimTimer <= 0 && distToPlayer < 640.0) {
            final baseAngle = math.atan2(toPlayer.dy, toPlayer.dx);
            final spreads = speedMultiplier >= 1.16 ? [-0.22, 0.0, 0.22] : [-0.18, 0.18];
            for (final sp in spreads) {
              final ang = baseAngle + sp;
              enemyProjectiles.add(
                CapsuleProjectile(
                  position: position + Offset(math.cos(ang), math.sin(ang)) * (radius + 4),
                  velocity: Offset(math.cos(ang), math.sin(ang)) * (272.0 * speedMultiplier),
                  damage: 1,
                  color: const Color(0xFFFBBF24),
                  radius: 5.8,
                  isEnemy: true,
                ),
              );
            }
            justAttacked = true;
            attackRecoilTimer = 0.24;
          }
        } else {
          behaviorState = EnemyBehaviorState.chase;
          shootCooldown -= dt * (0.9 + speedMultiplier * 0.12);
          if (shootCooldown <= 0 && distToPlayer < 600.0) {
            shootCooldown = shootInterval / (0.85 + speedMultiplier * 0.15);
            attackAnimTimer = 0.42;
          }
        }
        break;
    }

    // Smooth steering acceleration so movements feel fluid and natural
    final double steerFactor = (dt * 7.5).clamp(0.0, 1.0);
    velocity = Offset.lerp(velocity, desiredVel, steerFactor)!;
    position += (velocity + knockbackVel) * dt;

    // Safe organic wall bouncing within digestive tunnel
    final double minAllowedY = ceilY + radius + 8.0;
    final double maxAllowedY = floorY - radius - 8.0;
    if (maxAllowedY > minAllowedY) {
      if (position.dy < minAllowedY) {
        position = Offset(position.dx, minAllowedY);
        velocity = Offset(velocity.dx, velocity.dy.abs() * 0.7);
      } else if (position.dy > maxAllowedY) {
        position = Offset(position.dx, maxAllowedY);
        velocity = Offset(velocity.dx, -velocity.dy.abs() * 0.7);
      }
    }

    final double targetTilt = (velocity.dy / 260.0).clamp(-0.34, 0.34);
    facingTilt += (targetTilt - facingTilt) * (dt * 8.0).clamp(0.0, 1.0);
  }
}
