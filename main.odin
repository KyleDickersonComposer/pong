package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strings"
import rl "vendor:raylib"

PADDLE_HEIGHT :: SCREEN_HEIGHT / 7.
PADDLE_WIDTH :: SCREEN_WIDTH / 69.
BALL_WIDTH :: SCREEN_WIDTH / 69.
BALL_HEIGHT :: SCREEN_WIDTH / 69.

SCREEN_HEIGHT: f32 : 300 * 2
SCREEN_WIDTH: f32 : 400 * 2

Ball :: struct {
	rect:     rl.Rectangle,
	color:    rl.Color,
	velocity: rl.Vector2,
}

Paddle :: struct {
	rect:  rl.Rectangle,
	color: rl.Color,
	score: i32,
}

p1, p2: Paddle

ball: Ball

BALL_SPEED: f32 = 6.

main :: proc() {
	rl.InitWindow(i32(SCREEN_WIDTH), i32(SCREEN_HEIGHT), "pong")
	rl.SetTargetFPS(60)
	//rl.ToggleFullscreen()
	rl.HideCursor()

	p1 = Paddle {
		rect = {x = 0, y = f32(SCREEN_HEIGHT / 2), width = PADDLE_WIDTH, height = PADDLE_HEIGHT},
		color = rl.WHITE,
		score = 0,
	}

	p2 = Paddle {
		rect = {
			x = f32(SCREEN_WIDTH) - f32(PADDLE_WIDTH),
			y = f32(SCREEN_HEIGHT / 2),
			height = PADDLE_HEIGHT,
			width = PADDLE_WIDTH,
		},
		color = rl.WHITE,
		score = 0,
	}

	ball = Ball {
		rect = {
			x = SCREEN_WIDTH / 2,
			y = SCREEN_WIDTH / 2,
			width = BALL_WIDTH,
			height = BALL_HEIGHT,
		},
		color = rl.GREEN,
		velocity = {rand.float32_range(-1, 1), rand.float32_range(-1, 1)},
	}

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		update_game()

		draw_game()

		rl.EndDrawing()
	}

	rl.CloseWindow()
}

update_game :: proc() {
	fix_ball_velocity_edge_cases()

	display_score()

	move_p1()

	check_collision()

	check_score()

	move_ball()

	simulate_p2()
}

// puts lower bound on ball velocity
fix_ball_velocity_edge_cases :: proc() {
	if ball.velocity.x < 0 && math.abs(ball.velocity.x) < 0.5 {
		ball.velocity.x -= 0.3
	} else if ball.velocity.x > 0 && math.abs(ball.velocity.x) < 0.5 {
		ball.velocity.x += 0.3
	}

	if ball.velocity.y < 0 && math.abs(ball.velocity.y) < 0.5 {
		ball.velocity.y -= 0.3
	} else if ball.velocity.y > 0 && math.abs(ball.velocity.y) < 0.5 {
		ball.velocity.y += 0.3
	}
}

display_score :: proc() {
	p1_score := fmt.tprintf("%d", p1.score)
	p2_score := fmt.tprintf("%d", p2.score)
	rl.DrawText(
		strings.clone_to_cstring(p1_score),
		i32(SCREEN_WIDTH) / 5 * 1,
		i32(SCREEN_WIDTH) / 10,
		20,
		rl.GRAY,
	)

	rl.DrawText(
		strings.clone_to_cstring(p2_score),
		i32(SCREEN_WIDTH) / 5 * 4,
		i32(SCREEN_WIDTH) / 10,
		20,
		rl.GRAY,
	)
}

move_p1 :: proc() {
	if (rl.IsKeyDown(.J) || rl.IsKeyDown(.DOWN)) &&
	   (p1.rect.y + PADDLE_HEIGHT) < f32(SCREEN_HEIGHT) {
		p1.rect.y += 5
	}

	if (rl.IsKeyDown(.K) || rl.IsKeyDown(.UP)) && p1.rect.y > 0 {
		p1.rect.y -= 5
	}
}

check_collision :: proc() {
	if rl.CheckCollisionRecs(ball.rect, p1.rect) {
		ball.velocity.x *= -1
		BALL_SPEED += 0.5
	}
	if rl.CheckCollisionRecs(ball.rect, p2.rect) {
		ball.velocity.x *= -1
		BALL_SPEED += 0.5
	}
}

check_score :: proc() {
	if ball.rect.x < 0 {
		ball.rect.x = SCREEN_WIDTH / 2
		ball.rect.y = SCREEN_HEIGHT / 2
		ball.velocity = {rand.float32_range(-1, 1), rand.float32_range(-1, 1)}
		BALL_SPEED = 6.
		p1.score += 1
	}
	if ball.rect.x > SCREEN_WIDTH {
		ball.rect.x = SCREEN_WIDTH / 2
		ball.rect.y = SCREEN_HEIGHT / 2
		ball.velocity = {rand.float32_range(-1, 1), rand.float32_range(-1, 1)}
		BALL_SPEED = 6.
		p2.score += 1
	}

}

move_ball :: proc() {
	if ball.rect.y >= SCREEN_HEIGHT {
		ball.velocity.y *= -1
	} else if ball.rect.y <= 0 {
		ball.velocity.y *= -1
	}
	ball.rect.x += ball.velocity.x * BALL_SPEED
	ball.rect.y += ball.velocity.y * BALL_SPEED
}

simulate_p2 :: proc() {
	target_y := ball.rect.y - PADDLE_HEIGHT / 2

	target_y = max(0, min(target_y, SCREEN_HEIGHT - PADDLE_HEIGHT))

	if p2.rect.y < target_y {
		p2.rect.y += min(5, target_y - p2.rect.y)
	} else if p2.rect.y > target_y {
		p2.rect.y -= min(5, p2.rect.y - target_y)
	}
}

draw_game :: proc() {
	rl.DrawRectangle(
		i32(p1.rect.x),
		i32(p1.rect.y),
		i32(p1.rect.width),
		i32(p1.rect.height),
		p1.color,
	)
	rl.DrawRectangle(
		i32(p2.rect.x),
		i32(p2.rect.y),
		i32(p2.rect.width),
		i32(p2.rect.height),
		p2.color,
	)
	rl.DrawCircle(i32(ball.rect.x), i32(ball.rect.y), 7, ball.color)
}
