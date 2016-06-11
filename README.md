# boidFish

(updated to v0.17)

To check the outcome

```bash
elm-reactor
open http://localhost:8000/Main.elm
```

To transpile to html+js

```bash
elm-make Main.elm --output=main.html
```

Steps followed

```bash
elm package install
elm-package install evancz/elm-graphics
elm-package install elm-lang/html
elm-package install elm-lang/mouse
elm-package install elm-lang/window
atom Main.elm
elm-reactor
open http://localhost:8000/Main.elm
```
