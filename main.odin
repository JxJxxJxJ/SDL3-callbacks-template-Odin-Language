package main

import "core:log"
import "core:c"
import "base:runtime"
import sdl "vendor:sdl3"

AppState :: struct {
	odin_ctx : runtime.Context,
	stuff    : string,
}

SDL_AppInit :: proc "c" (appstate: ^rawptr, argc: c.int, argv: [^]cstring) -> sdl.AppResult {
	context = runtime.default_context()
	context.logger = log.create_console_logger() // Allocates memory (* )

	log.info("Starting")

	state := new(AppState)                       // Allocates memory (**)
	state.odin_ctx = context
	state.stuff = "hi"

	appstate^ = state

	return sdl.AppResult.CONTINUE
}

SDL_AppIterate :: proc "c" (appstate: rawptr) -> sdl.AppResult {
	state := cast(^AppState) appstate
	context = state.odin_ctx
	
	return sdl.AppResult.CONTINUE
}

SDL_AppEvent :: proc "c" (appstate: rawptr, event: ^sdl.Event) -> sdl.AppResult {
	state := cast(^AppState)appstate
	context = state.odin_ctx 

	#partial switch event.type {
	case .QUIT:
		log.info("QUIT Event!")
		return sdl.AppResult.SUCCESS 
	}
	
	return sdl.AppResult.CONTINUE
}
    
SDL_AppQuit :: proc "c" (appstate: rawptr, result: sdl.AppResult) {
	state := cast(^AppState)appstate
	
	if state != nil {
		context = state.odin_ctx
        log.info("Closing")
		log.destroy_console_logger(context.logger) // Frees memory (* )
		free(state)                                // Frees memory (**)
	}
}

@(private="file")
fakemain :: proc(argc: c.int, argv: [^]cstring) {
	_ = sdl.EnterAppMainCallbacks(
		argc, 
		argv, 
		SDL_AppInit, 
		SDL_AppIterate, 
		SDL_AppEvent, 
		SDL_AppQuit,
	)
}

main :: proc() {
	sdl.RunApp(0, nil, fakemain, nil)
}