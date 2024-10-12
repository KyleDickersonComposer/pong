package main

import "core:fmt"
import rl "vendor:raylib"

Ball :: struct {
	pos:    rl.Vector2,
	height: i32,
	width:  i32,
	color:  rl.Color,
}

Paddle :: struct {
	pos:    rl.Vector2,
	height: i32,
	width:  i32,
	color:  rl.Color,
}

p1, p2: Paddle

ball : Ball

PADDLE_HEIGHT :: SCREEN_HEIGHT / 7
PADDLE_WIDTH :: SCREEN_WIDTH / 69

SCREEN_HEIGHT :: 600
SCREEN_WIDTH :: 800

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "pong")
	rl.SetTargetFPS(60)

	p1 = Paddle {
		pos    = {0, f32(SCREEN_HEIGHT / 2)},
		height = PADDLE_HEIGHT,
		width  = PADDLE_WIDTH,
		color  = rl.WHITE,
	}

	p2 = Paddle {
		pos    = {f32(SCREEN_WIDTH) - f32(PADDLE_WIDTH), f32(SCREEN_HEIGHT / 2)},
		height = PADDLE_HEIGHT,
		width  = PADDLE_WIDTH,
		color  = rl.WHITE,
	}

	ball = Ball {
		pos = {
			SCREEN_WIDTH /2,
			SCREEN_HEIGHT /2,
		},
		height = SCREEN_WIDTH / 69,
		width = SCREEN_WIDTH / 69,
		color = rl.GREEN
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
	if rl.IsKeyDown(.J) && (p1.pos.y + PADDLE_HEIGHT) < f32(SCREEN_HEIGHT) {
		p1.pos.y += 5
	}

	if rl.IsKeyDown(.K) && p1.pos.y > 0 {
		p1.pos.y -= 5
	}
}

draw_game :: proc() {
	rl.DrawRectangle(i32(p1.pos.x), i32(p1.pos.y), p1.width, p1.height, p1.color)
	rl.DrawRectangle(i32(p2.pos.x), i32(p2.pos.y), p2.width, p2.height, p2.color)
	rl.DrawRectangle(i32(ball.pos.x), i32(ball.pos.y), ball.width, ball.height, ball.color)
}
