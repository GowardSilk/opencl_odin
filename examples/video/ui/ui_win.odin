//#+private

package ui;

import "base:runtime"

import "core:c"
import "core:log"
import "core:mem"
import "core:strings"

import win "core:sys/windows"

Mouse_State :: enum {
    Invalid,

    Down,
    Up,
}

Mouse_ID :: enum {
    Left,
    Middle,
    Right,
}

Window_Descriptor :: struct {
    name: cstring,
    size: [2]i32,
    pos:  [2]i32,
}

_Window :: struct {
    hwnd: win.HWND,
    should_close: bool,
}

WindowProcT :: win.WNDPROC;

wide_char :: proc(str: string) -> [^]u16 {
    size := win.MultiByteToWideChar(win.CP_UTF8, 0, raw_data(str), -1, nil, 0);
    assert(size != 0, "Failed to receive wchar size!");
    new_str, err := mem.make_multi_pointer([^]u16, size);
    assert(err == .None, "Failed to allocate wchar memory!");
    win.MultiByteToWideChar(win.CP_UTF8, 0, raw_data(str), -1, new_str, size);
    return new_str;
}

@(require_results)
register_window_class :: proc() -> [^]u16 {
    @static registered := false;

    class_name  := wide_char("OpenCL Video Example Windows");

    if !registered {
        registered = true;
        win.RegisterClassW(&{
            lpfnWndProc = window_proc,
            hInstance = auto_cast win.GetModuleHandleW(nil),
            lpszClassName = class_name,
        });
    }

    return class_name;
}

prepare_window_win :: proc(size: [2]c.int, name: cstring, draw: Draw_Proc) -> (window: Window, err: General_Error) {
    // Window ops functions
    get_mouse_pos_win   :: proc "cdecl" (handle: Window_Handle) -> ([2]f64) {
        window := cast(^_Window)handle;
        pt: win.POINT;
        if win.GetCursorPos(&pt) == win.FALSE {
            return [2]f64{0, 0};
        }

        _ = win.ScreenToClient(window.hwnd, &pt);
        return [2]f64{f64(pt.x), f64(pt.y)};
    }
    get_mouse_state_win :: proc "cdecl" (handle: Window_Handle, button: Mouse_ID) -> Mouse_State {
        vk_code: i32;
        switch button {
            case .Left:   vk_code = win.VK_LBUTTON;
            case .Right:  vk_code = win.VK_RBUTTON;
            case .Middle: vk_code = win.VK_MBUTTON;
        };

        state := win.GetAsyncKeyState(vk_code);
        if (cast(u16)state & 0x8000) != 0 {
            return .Down;
        }

        return .Up;
    }

    window.handle = cast(Window_Handle)create_window_handle({
        name,
        size,
        {0, 0},
    });
    window.size = size;
    window.draw_proc = draw;
    window.cursor = DRAW_CURSOR_DEFAULT();
    window.vtable = Window_Ops_Table {
        get_mouse_pos_win,
        get_mouse_state_win,
    };

    return window, nil;
}

create_window_handle :: proc(desc: Window_Descriptor) -> ^_Window {
    class_name := register_window_class();
    defer mem.free(class_name);
    desc_name := strings.clone_from_cstring(desc.name);
    defer delete(desc_name);
    window_name := wide_char(desc_name);
    defer mem.free(window_name);

    window, err := mem.new(_Window);
    assert(window != nil && err == .None);
    {
        window.hwnd = win.CreateWindowExW(
            0,
            class_name,
            window_name,
            win.WS_OVERLAPPEDWINDOW,
            win.CW_USEDEFAULT, win.CW_USEDEFAULT,
            desc.size.x, desc.size.y,
            nil, nil,
            auto_cast win.GetModuleHandleW(nil),
            window,
        );
        assert(window.hwnd != nil, "Failed to create hwnd!");
    }

    win.ShowWindow(window.hwnd, win.SW_SHOW);
    win.UpdateWindow(window.hwnd);

    return window;
}

destroy_window_win :: proc(window: Window) {
    assert(win.DestroyWindow(cast(win.HWND)window.handle) == win.TRUE);
}

draw_win :: proc() {
    ctx := get_context();
    assert(ctx^.ren.backend == .D3D11);

    q := &ctx^.queue;
    for len(q^.windows) > 0 {
        l := len(q^.windows);
        for i := 0; i < l; i += 1 {
            w := q^.windows[i];
            w_handle := cast(^_Window)w.handle;

            if w_handle.should_close {
                // signal to the draw function that the window is being closed
                w.signal = .Should_Close;
                w->draw_proc();
                batch_renderer_unload(&ctx^.ren, cast(Window_ID)w_handle.hwnd);
                delete_window(w_handle);
                ordered_remove(&q^.windows, i);
                l -= 1;
            } else {
                q^.active_window = &w;

                msg: win.MSG;
                for win.PeekMessageW(&msg, w_handle.hwnd, 0, 0, win.PM_REMOVE) != win.FALSE {
                    win.TranslateMessage(&msg);
                    win.DispatchMessageW(&msg);
                }

                perwindow, ok := ctx.ren.perwindow[cast(Window_ID)w_handle.hwnd];
                assert(ok);
                color := [4]f32{0.1, 0.1, 0.1, 1.0};
                ctx^.ren.persistent.device_context->ClearRenderTargetView(
                    perwindow.d3d11.framebuffer_view,
                    &color
                );

                w->draw_proc();
                execute_draw_commands();
                reset_state();

                perwindow.d3d11.swapchain->Present(1, {});
            }
        }

        batch_renderer_reset(&ctx^.ren);
    }
}

delete_window :: #force_inline proc(window: ^_Window) {
    assert(window != nil);
    if window^.hwnd != nil do win.DestroyWindow(window^.hwnd); 
    mem.free(window);
}

window_proc_close :: proc "system" (window: ^_Window) -> win.LRESULT {
    win.PostQuitMessage(0);
    window.should_close = true;
    return 0;
}

window_proc :: proc "system" (hwnd: win.HWND, msg: win.UINT, wparam: win.WPARAM, lparam: win.LPARAM) -> win.LRESULT {
    window: ^_Window = nil;

    context = runtime.default_context();

    if msg == win.WM_NCCREATE {
        window_create := (cast(^win.CREATESTRUCTW)(cast(uintptr)lparam))^.lpCreateParams;
        win.SetWindowLongPtrW(hwnd, win.GWLP_USERDATA, cast(win.LONG_PTR)(cast(uintptr)window_create));
    } else {
        window = cast(^_Window)(cast(uintptr)win.GetWindowLongPtrW(hwnd, win.GWLP_USERDATA));
    }

    switch msg {
        case win.WM_CLOSE:
            win.DestroyWindow(hwnd);
            window^.hwnd = nil;
            window^.should_close = true;
            return 0;
        case win.WM_DESTROY:
            win.PostQuitMessage(0);
            return 0;
        case:                       return win.DefWindowProcW(hwnd, msg, wparam, lparam);
    }
}

