#import "../lib.typ": *

= CSS styling

== Introduction

The project is based on a single CSS file, `components.css`, and all the others rely upon it to retrieve the styles. Futhermore, all the colours are sourced from the `colors.css` file, which is itself is based on #emph[tinted-theming] @tinted-theming, a collection of commonly used themes in the developing world. We have chosen to use the #emph[Classic Light theme]#footnote[Very similar to #link("https://nothing.community/d/22988-nothing-os-30-general-release")[NothingOS] colorscheme.].

If you want to change the overall theme of the website, just switch to a new colorscheme by looking at the #link("https://tinted-theming.github.io/tinted-gallery/")[gallery]. In `colors.css` there are commented styles to choose from.

#css_explanation(
  ```css
  body {
      background-color: var(--default-background);
      padding: 1rem 2rem 2rem 2rem;
      line-height: 1.6;
      word-spacing: 1px;
      font-family: "JetBrains Mono", monospace;
      height: 100vh;
      text-overflow: ellipsis;
  }
  ```,
  [
    As stated earlier, the `background-color` is sourced from the `colors.css`. Then the padding is always `2rem`, except above, where it's `1rem`. The text is able to wrap thanks to `ellipsis` option on `text-overflow`.
  ],
)

After the body, we styled all the elements in a consistent manner.

== Buttons

#css_explanation(
  ```css
  .button {
      color: var(--selection-background);
      background-color: var(--default-foreground);
      border: 2px solid var(--dark-foreground);
      height: 3rem;
      border-radius: 6px;
      font-weight: bold;
      vertical-align: middle;
      margin: 0.5rem 0 0.5rem 0;
      padding: 1em;
      font-family: "JetBrains Mono", monospace;
  }
  ```,
  [
    Every button is derived from the one above. The text is aligned in the center both horizontally and vertically, bold. Then there are some margin and padding to help the user see better#footnote[There will be later an exception.].
  ],
)

A notable exception to the buttons colorscheme is the `logout` button:
#css_explanation(
  ```css
  .logout {
      background-color: var(--variables);
      font-weight: bolder;
      color: var(--lighter-background);
  }

  .logout:hover {
      background-color: var(--data-types);
  }
  ```,
  [
    Both the `background-color`, `font-weight` and `color` are different, to further imply that button is different from the others (upload track, create playlist...).
  ],
)

The same can be said to the `close` button in the modal, will be explained below.

== Containers

The first container the user encounters is the Login one, which shares its design with Register and the track player:
#css_explanation(
  ```css
  .center-panel {
      width: 300px;
      background-color: var(--lighter-background);
      border: 1px solid var(--dark-foreground);
      padding: 3rem;
      text-align: center;
  }
  ```,
  [
    An important aspect of login and register is their horizontal bar:
    ```css
    hr {
      display: block;
      height: 1px;
      border: 0;
      border-top: 1px solid var(--light-background);
      margin: 1em 0;
      padding: 0;
    }
    ```
    which is not used in the track player.
  ],
)

A central part of a Playlist Manager is displaying all the playlist and tracks of a given user. To achieve that, we opted for a classic layout composed of a top and bottom navigation bars and a main section.

#css_explanation(
  ```css
  .nav-bar {
      width: 100%;
      margin: 0;
      display: flex;
      flex-wrap: wrap;
      align-content: space-around;
      justify-content: center;
      align-items: center;
      gap: 1rem;
  }
  ```,
  [
    The navigation bar is the same both above and below. It's a flex container because it's important to have a flexible container for the main-title (e.g. "All Playlists") and the buttons (with a variable number between screens).

    The layout is computed as follows:
    #table(
      columns: (auto, 1fr) + (auto,) * 2,
      stroke: silver,
      align: center,
      `title`,
      table.cell(fill: purple.transparentize(50%), `spacer`),
      `button`,
      `logout`,
    )
    so we created the `spacer` element:
    ```css
    .spacer {
        flex-grow: 1;
    }
    ```
    which takes all the space available.
  ],
)

Next, the tracks and playlists containers.

#css_explanation(
  ```css
  .items-container {
      width: 100%;
      display: grid;
      grid-template-columns: 1fr 1fr 1fr 1fr 1fr;
      align-content: baseline;
      justify-content: center;
      gap: 1rem;
      padding: 1rem 0 1rem 0;
  }

  .single-item {
      display: flex;
      flex-wrap: nowrap;
      background-color: var(--light-background);
      border: 2px solid var(--data-types);
      border-radius: 5px;
      color: var(--lighter-background);
      padding: 1rem;
      height: 150px;
      font-family: "JetBrains Mono", monospace;
      font-weight: 700;
      text-align: left;
      align-content: end;
      align-items: end;
      justify-content: space-between;
  }

  .single-item:hover {
      background-color: var(--variables);
      cursor: pointer;
  }
  ```,
  [
    According to project specifications, there must be #strong[at most 5 tracks per page]: we opted for a CSS grid. This works well along witht the `body` previously set because the grid can expand and shrink its items accordingly.

    As per the navigation bar, the single items are themselves flexible boxes. The different is they are not allowed to wrap -- one might ask: why not, since the tracks must list the title and the album? because we handle that line break manually with the `<br` tag.
  ],
)

== Modal

Finally, without a doubt the most difficult CSS component in this project is the modal, which is a dialog window created entirely with CSS. As a complex element, it can be broke into multiple parts:

- The window
```css
.modal-window {
    position: fixed;
    background-color: rgba(255, 255, 255, 0.25);
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    z-index: 999;
    visibility: hidden;
    pointer-events: none;
    transition: all 0.5s;
}
```
it's `hidden` by default, but once it's invoked it must be be above everything -- this is handled by the `z-index` property. Its position must be `fixed`, since it's not a movable window; also it can't be targeted by cursor: `pointer-events` are none. Another key aspect is the background color: in order to make it stand from its background, a slight blurred white is needed:
#figure(
  scope: "parent",
  placement: bottom,
  {
    let height = 3cm
    let width = 7cm
    let spacing = 1fr
    stack(
      dir: ltr,
      spacing: spacing,
      rect(
        width: width,
        height: height,
        fill: comments,
        align(
          start,
          "nav-bar",
        ),
      ),
      rect(
        width: width,
        height: height,
        fill: comments,
        align(
          start,
          "nav-bar",
        )
          + place(
            center + horizon,
            rect(
              width: width,
              height: height,
              fill: rgb(255, 255, 255, 25%),
              box(
                inset: 4pt,
                stroke: variables,
                fill: lighter-background,
                "modal-window",
              ),
            ),
          ),
      ),
    )
  },
  caption: [Modal representation.],
)

// #pagebreak()

- The target, when the user presses a button that launches the modal (e.g. Upload Track)

```css
.modal-window:target {
    visibility: visible;
    opacity: 1;
    pointer-events: auto;
}

.modal-window > div {
    width: 400px;
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    padding: 1em;
    background: var(--lighter-background);
    border: 2px solid var(--variables);
}
```
once the modal has been invoked, its visibility must be switched to `visible` and `opacity` to 1. The child element `div` of the window must at the center of screen, both horizontally and vertically: this is managed with the `top`, `left` and `translate` properties.

- The close button
```css
.modal-close {
    color: var(--lighter-background);
    background-color: var(--variables);
    border-radius: 5px;
    position: absolute;
    top: 2%;
    right: 2%;
    cursor: pointer;
    padding: 0.2rem;
    font-size: 0.8rem;
    font-weight: bold;
    text-align: center;
    text-decoration: none;
}

.modal-close:hover {
    color: black;
}
```
as stated previously, the `modal-close` button is an exception to the `button` rule. It's considerably smaller than the others, the cursor is immediately `pointer`. In conclusion its position is computed on the `modal-window`, from above right.
