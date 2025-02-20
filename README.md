# nvumi

**nvumi** is a Neovim plugin that integrates the [numi](https://github.com/nikolaeu/numi) natural language calculator with [Snacks.nvim's](https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md) scratch buffer. It lets you construct natural language expressions and see the results evaluated inline as you type.

<p align="center">
  <img src="https://github.com/user-attachments/assets/c0d0fd19-7acf-49db-96d2-0da9eda3b088" alt="Gif" />
</p>

## Installation

### Using Lazy.nvim

```lua
{
  "josephburgess/nvumi",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    virtual_text = "newline", -- or "inline"
    prefix = " 🚀 ", -- prefix shown before the output
    date_format = "iso", -- or: "uk", "us", "long"
    keys = {
      run = "<CR>", -- run/refresh calculations
      reset = "R", -- reset buffer
      yank = "<leader>y", -- yank output of current line
      yank_all = "<leader>Y", -- yank all outputs
    },
  }
}
```

You will also need **[numi-cli](https://github.com/nikolaeu/numi)**. Install with:

```bash
curl -sSL https://s.numi.app/cli | sh
```

or [Homebrew](https://brew.sh/) if on MacOS:

```bash
brew install nikolaeu/numi/numi-cli
```

Nvumi does not have a default keybinding to open the buffer out of the box! To create one add something like the below to your config:

```lua
vim.keymap.set("n", "<leader>on", "<CMD>Nvumi<CR>", { desc = "[O]pen [N]vumi" })
```

## Usage

1. Run the command `:Nvumi` to open a scratch buffer ready for calculations

2. Type your natural language expression(s) (e.g., `20 inches in cm`) in insert mode

3. The answer(s) to your expressions will render in the buffer.

4. Press `<CR>` (Enter) in normal mode and the buffer will re-run all calculations/refresh. Useful if using lots of variables/complicated logic to run on a clean slate top-to-bottom.

5. Pressing `<leader>y` will yank the evaluation of the current line to clipboard (`<leader>Y` to yank all evaluations)

## Variable Assignment

nvumi now supports variable assignment, allowing you to store specific numbers, or evaluated results and reuse them in later calculations.

<p align="center">
  <img src="https://github.com/user-attachments/assets/ea3c06ed-2555-45b3-85bb-89e4834f9d97" alt="Variable Assignment Screenshot" width="800" />
</p>

**How It Works:**

- **Assigning a Variable:**
  In your scratch buffer, type an assignment in the format:

  ```text
  variable_name = expression
  ```

  You can assign a variable either to a numerical value or to an evaluated expression, for example:

  ```text
  x = 20 inches in cm
  y = 5000
  ```

  In the first example, nvumi evaluates the expression (`20 inches in cm`) and stores its result in the variable `x`.
  In the second, `y` simply holds the number `5000` without any further evaluation.

- **Using Variables in Expressions:**
  Once assigned, you can reference variables in other calculations:

  ```text
  x * y
  x + 5
  y meters in kilometers
  ```

  nvumi will substitute the variable with its stored value before evaluation.

- **Resetting Variables:**
  Using the `<reset>` command (default "<R>") clears both the buffer AND all stored variables.

💡 _Tip:_ Variable names must start with a letter or underscore, followed by letters, numbers, or underscores.

## Virtual Text Locations

Currently you can configure where you want the virtual text to be displayed, `inline` or `newline`:

<details closed>
  <summary>Inline</summary>
  <p>
    <img src="https://github.com/user-attachments/assets/dae054cc-bddb-49c2-802a-68bfc9108d49" alt="Inline Screenshot" />
  </p>
</details>

<details closed>
  <summary>Newline</summary>
  <p>
    <img src="https://github.com/user-attachments/assets/f7222430-4cb4-4eb7-a155-477d70dc39ff" alt="Newline Screenshot" />
  </p>
</details>

## Date formatting

If you care about how your dates are formatted, that is configurable!

| **`date_format`** | **Output**          |
| ----------------- | ------------------- |
| `"iso"`           | `2025-02-21`        |
| `"us"`            | `02/21/2025`        |
| `"uk"`            | `21/02/2025`        |
| `"long"`          | `February 21, 2025` |

## Extra commands

There are two extra (possibly useless) commands included with Nvumi:

- `NvumiEvalLine`
- `NvumiEvalBuf`

These will - you guessed it - run Nvumi on ANY line or ANY buffer. Beware that running on a buffer will result in a lot of messy virtual_text (and lots of errors if the text cant be evaluated). But maybe you want to set the `NvumiEvalLine` command to quickly run calculations outside of the scratch buffer.

You can also clear a buffer of the virtual text with `NvumiClear` (or just close it - they wont still be there when you come back).

## The .nvumi filetype

Nvumi was built around a made-up filetype `.nvumi`. This was so that the autocommands used by the plugin under the hood could target a specific filetype without unwanted side effects on other files. It also meant a custom filetype icon could be set for those using nerd fonts.

The fun side-effect/benefit of this, however, is that you can create `.nvumi` files outside of the scratch buffer and they will function exactly the same! You can evaluate to your hearts content in full screen.

## Contributing

This is my first attempt at a Neovim plugin, so contributions are more than welcome! If you encounter issues or have ideas for improvements, please open an issue or submit a pull request on GitHub.

## Planned Features & Roadmap

A few things I'm thinking about adding as I continue trying to expand my knowledge of `lua` and plugin development:

- [x] Assigning answers to variables
- [x] Custom prefixes/suffixes for results (e.g., `=` `→` 🚀 etc).
- [x] Auto-evaluate expressions as you type without need to press `<CR>`
- [x] Ability to call numi/evaluate expressions on a line in _any_ buffer on demand
- [x] Fine-tuning date format
- [x] Yankable answers!
  - [x] Stretch: make possible for all evaluations - now per line or yank ALL are both possible.
- [ ] Additional conversions not currently possible with numi
- [ ] User defined/custom conversions
- [ ] Full syntax highlighting

## License

MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgements

- **[Snacks.nvim](https://github.com/folke/snacks.nvim):**
  Thanks @folke for the incredible plugin. The `lua` code runner built into the Scratch buffer inspired this idea in the first place. Thanks also also for your super-human contributions to the community in general!
- **[numi](https://github.com/nikolaeu/numi):**
  Thanks for providing an amazing natural language calculator.
