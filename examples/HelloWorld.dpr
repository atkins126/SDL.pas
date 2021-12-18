
{==============================================================================
  ____  ____  _
 / ___||  _ \| |      _ __   __ _ ___
 \___ \| | | | |     | '_ \ / _` / __|
  ___) | |_| | |___ _| |_) | (_| \__ \
 |____/|____/|_____(_) .__/ \__,_|___/
                     |_|
  Simple DirectMedia Layer for Pascal

 Includes:
   SDL2      - 2.0.18
   SDL_image - 2.0.5
   SDL_mixer - 2.0.4
   SDL_net   - 2.0.1
   SDL_ttf   - 2.0.15
   Nuklear   - 4.09.1
   pl_mpeg

Copyright © 2021 tinyBigGAMES™ LLC
All Rights Reserved.

Website: https://tinybiggames.com
Email  : support@tinybiggames.com

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software in
   a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

2. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

3. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the
   distribution.

4. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived
   from this software without specific prior written permission.

5. All video, audio, graphics and other content accessed through the
   software in this distro is the property of the applicable content owner
   and may be protected by applicable copyright law. This License gives
   Customer no rights to such content, and Company disclaims any liability
   for misuse of content.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
----------------------------------------------------------------------------
SDL.pas - https://github.com/tinyBigGAMES/SDL.pas
SDL2    - https://github.com/libsdl-org/SDL, https://libsdl.org/
plmpeg  - https://github.com/phoboslab/pl_mpeg
nuklear - https://github.com/Immediate-Mode-UI/Nuklear
============================================================================= }

program HelloWorld;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  SDL;

var
  MouseState: SDL_rect;
  Window: PSDL_Window;
  Renderer: PSDL_Renderer;
  Event: SDL_Event;
  Quit: Boolean;
  Ready: Boolean;
  Vert: array[0..2] of SDL_Vertex;
  FPSLastTime: Cardinal;
  FPSCurrent: cardinal;
  FPSFrames: cardinal;
  Tex: PSDL_Texture;
  TexSize: SDL_Rect;

// Make color
function MakeColor(r,g,b,a: Byte): SDL_Color;
begin
  Result.r := r;
  Result.g := g;
  Result.b := b;
  Result.a := a;
end;

function MakeRect(x, y, w, h: Integer): SDL_rect;
begin
  Result.x := x;
  Result.y := y;
  Result.w := w;
  Result.h := h;
end;

// Set mouse postion
procedure SetMousePos(aWindow: PSDL_Window; aRenderer: PSDL_Renderer; aX: Integer; aY: Integer);
var
  sx,sy: Single;
  vx,vy: Integer;
  mx,my: Single;
  vr: SDL_Rect;
begin
  SDL_RenderGetScale(aRenderer, @sx, @sy);
  SDL_RenderGetViewport(aRenderer, @vr);

  mx := (aX + vr.x) * sx;
  my := (aY + vr.y) * sy;

  SDL_WarpMouseInWindow(aWindow, Round(mx), Round(my));
end;

// Toggle fullscreen
procedure ToggleFullscreen(aWindow: PSDL_Window; aRenderer: PSDL_Renderer);
var
  x,y: Integer;
begin
  x := MouseState.x;
  y := MouseState.y;

  var IsFullscreen := Boolean(SDL_GetWindowFlags(aWindow) and SDL_WINDOW_FULLSCREEN_DESKTOP);
  if IsFullscreen then
    begin
      SDL_SetWindowFullscreen(aWindow, 0);
    end
  else
    begin
      SDL_SetWindowFullscreen(aWindow, SDL_WINDOW_FULLSCREEN_DESKTOP);
    end;

   SetMousePos(aWindow, aRenderer, x, y);
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  try

    SDL_Init(SDL_INIT_EVERYTHING);
    IMG_Init(IMG_INIT_PNG);

    SDL_SetHint(SDL_HINT_RENDER_LOGICAL_SIZE_MODE, '0');
    SDL_SetHint(SDL_HINT_VIDEO_WINDOW_SHARE_PIXEL_FORMAT, '1');
    SDL_SetHint(SDL_HINT_MOUSE_RELATIVE_SCALING, '1');
    SDL_SetHint(SDL_HINT_FRAMEBUFFER_ACCELERATION, '1');
    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, '2');
    SDL_SetHint(SDL_HINT_VIDEO_HIGHDPI_DISABLED, '0');
    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, '2');

    FPSLastTime := SDL_GetTicks;
    FPSFrames := 0;

    Window := SDL_CreateWindow('HelloWorld', SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 600, SDL_WINDOW_ALLOW_HIGHDPI);
    Renderer := SDL_CreateRenderer(Window, -1, SDL_RENDERER_ACCELERATED or SDL_RENDERER_TARGETTEXTURE or SDL_RENDERER_PRESENTVSYNC);
    SDL_RenderSetLogicalSize(Renderer, 800, 600);

    Tex := IMG_LoadTexture(Renderer, 'resources/alphacheese.png');
    SDL_QueryTexture(Tex, nil, nil, @TexSize.w, @TexSize.h);

    Quit := False;
    Ready := True;
    while not Quit do
    begin
      SDL_PollEvent(@Event);
      case Event.&type of
        SDL_QUIT_:
          begin
            Quit := True;
          end;

        SDL_WINDOWEVENT_:
          begin
            case Event.window.event of
              SDL_WINDOWEVENT_FOCUS_LOST: Ready := False;
              SDL_WINDOWEVENT_FOCUS_GAINED: Ready := True;
            end;
          end;

        SDL_KEYDOWN:
          begin
            case Event.key.keysym.sym of
              // 'F' - toggle fullscreen
              SDLK_f: ToggleFullscreen(Window, Renderer);

              // ESC - quit
              SDLK_ESCAPE: Quit := True;
            end;
          end;

        // mouse motion state
        SDL_MOUSEMOTION:
          begin
            MouseState.x := Event.motion.x;
            MouseState.y := Event.motion.y;
            MouseState.w := Event.motion.xrel;
            MouseState.h := Event.motion.yrel;
          end;
      end;

      if Ready then
        begin
          SDL_SetRenderDrawColor(Renderer, 30, 31, 30, 255);
          SDL_RenderClear(Renderer);

          var rect := MakeRect(50, 50, 200, 200);
          SDL_SetRenderDrawColor(Renderer, 255, 0, 0, 255);
          SDL_RenderFillRect(Renderer, @rect);

          // center
          Vert[0].position.x := 400;
          Vert[0].position.y := 150;
          Vert[0].color := MakeColor(255, 0, 0, 255);

          // left
          Vert[1].position.x := 200;
          Vert[1].position.y := 450;
          //Vert[1].color = (SDL_Color){0, 0, 255, 255};
          Vert[0].color := MakeColor(0, 0, 255, 255);

          // right
          Vert[2].position.x := 600;
          Vert[2].position.y := 450;
          Vert[0].color := MakeColor(0, 255, 0, 255);
          SDL_RenderGeometry(Renderer, nil, @Vert, 3, nil, 0);

          // render texture
          TexSize.x := 500;
          TexSize.y := 50;
          SDL_RenderCopy(Renderer, Tex, nil, @TexSize);

          // show frame buffer
          SDL_RenderPresent(Renderer);

          // calc/show framerate
          inc(FPSFrames);
          if FPSLastTime < SDL_GetTicks - 1.0*1000 then
          begin
            FPSLastTime := SDL_GetTicks;
            FPSCurrent := FPSFrames;
            FPSFrames := 0;
            var m: TMarshaller;
            SDL_SetWindowTitle(Window, m.AsAnsi(Format('HelloWorld - fps %d', [FPSCurrent])).ToPointer);
          end;
        end
      else
        begin
          // if window not active, sleep
          Sleep(1);
        end;
    end;

    // release resources
    SDL_DestroyTexture(Tex);
    SDL_DestroyRenderer(Renderer);
    SDL_DestroyWindow(Window);
    IMG_Quit;
    SDL_Quit;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
