# nvumi

**nvumi** is a Neovim plugin that integrates the [numi](https://github.com/nikolaeu/numi) natural language calculator with a scratch buffer. It lets you construct natural language expressions and see the results evaluated inline as you type.

<p align="center">
  <img src="https://github.com/user-attachments/assets/c0d0fd19-7acf-49db-96d2-0da9eda3b088" alt="Gif" />
</p>

## Installation

### Using Lazy.nvim

```lua
{
  "josephburgess/nvumi",
  opts = {
    virtual_text = "newline", -- or "inline"
    prefix = " = ", -- prefix shown before the output
    date_format = "iso", -- or: "uk", "us", "long"
    keys = {
      run = "<CR>", -- run/refresh calculations
      reset = "R", -- reset buffer
      yank = "<leader>y", -- yank output of current line
      yank_all = "<leader>Y", -- yank all outputs
    },
    -- see below for more on custom conversions/functions
    custom_conversions = {},
    custom_functions = {}
  }
}
```

### Install `numi-cli`

You will also need **[numi-cli](https://github.com/nikolaeu/numi)**.

**MacOS**

```sh
brew install nikolaeu/numi/numi-cli
```

**Linux & Windows**

```sh
curl -sSL https://s.numi.app/cli | sh
```

### Keybinding to open nvumi

nvumi does not have a default keybinding to open the scratch buffer. You can set one:

```lua
vim.keymap.set("n", "<leader>on", "<CMD>Nvumi<CR>", { desc = "Open nvumi" })
```

## Usage

1. Run `:Nvumi` to open a scratch buffer.
2. Type a natural language expression (`20 inches in cm`).
3. The result appears **inline** or on a **new line**, based on your settings.
4. Press `<CR>` to refresh calculations.
5. Use `<leader>y` to yank the current result (or `<leader>Y` for all results).

## Variable Assignment

nvumi supports variables for storing values and reusing them in subsequent expressions. Variable names must start with a letter or underscore, followed by letters, numbers, or underscores.

```text
x = 20 inches in cm
y = 5000
x * y
x + 5
y meters in kilometers
```

- `x` stores the result of `20 inches in cm`
- `y` holds `5000`
- Expressions like `x * y` use the stored values

Pressing `R` to reset the buffer also clears all stored variables.

## Custom Conversions

nvumi supports user-defined unit conversions beyond what `numi-cli` provides. This was inspired by the [plugins](https://github.com/nikolaeu/numi/tree/master/plugins) that exist for the numi desktop app (those should be compatible with nvumi too).

- Define custom units with **aliases**, a **base unit group**, and a **conversion ratio**
- Custom conversions must share the same `base_unit` (e.g., `"speed"`, `"volume"`)
- Ratios are relative to the base unit

```lua
{
  opts = {
    custom_conversions = {
      {
        id = "kmh",
        phrases = "kmh, kmph, klicks, kilometers per hour",
        base_unit = "speed",
        format = "km/h",
        ratio = 1,
      },
      {
        id = "mph",
        phrases = "mph, miles per hour",
        base_unit = "speed",
        format = "mph",
        ratio = 1.609344, -- 1 mph = 1.609344 km/h
      },
    },
  }
}
```

| Input                  | Output        |
| ---------------------- | ------------- |
| `10 gallons in liters` | `37.8541 L`   |
| `5 kmh in mph`         | `3.10686 mph` |

## Custom Functions

nvumi supports user-defined functions with aliases. Functions receive arguments (numbers or strings, or nothing) and return computed results. You can include error messages that will surface if something goes wrong.

```lua
{
  opts = {
    custom_functions = {
      {
        def = { phrases = "square, sqr" },
        fn = function(args)
          if #args < 1 or type(args[1]) ~= "number" then
            return { error = "square requires a single numeric argument" }
          end
          return { result = args[1] * args[1] }
        end,
      },
      {
        def = { id = "greet", phrases = "hello, hi" },
        fn = function(args)
          local name = args[1] or "stranger"
          return { result = "Hello, " .. name .. "!" }
        end,
      },
      {
        def = { phrases = "coinflip, flip" },
        fn = function()
          return { result = (math.random() > 0.5) and "Heads" or "Tails" }
        end,
      },
    },
  }
}
```

| Input           | Output                                               |
| --------------- | ---------------------------------------------------- |
| `square(5)`     | `25`                                                 |
| `square("abc")` | `"Error: square requires a single numeric argument"` |
| `hello("Joe")`  | `"Hello, Joe!"`                                      |
| `flip()`        | `Heads` / `Tails`                                    |

## Inline `{}` Evaluations

Expressions inside `{}` are evaluated first and the result is substituted into the full line before processing. This is particularly useful with custom functions or conversions, where passing a raw expression as an argument would confuse the parser.

| Input                 | Step 1 - Evaluate `{}` | Step 2 - Final Output |
| --------------------- | ---------------------- | --------------------- |
| `log({10*10}, {5+5})` | `log(100, 10)`         | `2`                   |
| `{10+20} mph in kmh`  | `30 mph in kmh`        | `48.28032 km/h`       |

## Virtual Text Modes

nvumi supports two virtual text modes:

- **Inline** (default)
- **Newline**

<details>
  <summary>Inline</summary>
  <p>
    <img src="https://github.com/user-attachments/assets/dae054cc-bddb-49c2-802a-68bfc9108d49" alt="Inline Screenshot" />
  </p>
</details>

<details>
  <summary>Newline</summary>
  <p>
    <img src="https://github.com/user-attachments/assets/f7222430-4cb4-4eb7-a155-477d70dc39ff" alt="Newline Screenshot" />
  </p>
</details>

## Date Formatting

| **Format** | **Example Output**  |
| ---------- | ------------------- |
| `"iso"`    | `2025-02-21`        |
| `"us"`     | `02/21/2025`        |
| `"uk"`     | `21/02/2025`        |
| `"long"`   | `February 21, 2025` |

```lua
opts = {
  date_format = "iso", -- or: "uk", "us", "long"
}
```

## Extra Commands

| Command         | Description                                                   |
| --------------- | ------------------------------------------------------------- |
| `NvumiEvalLine` | Run nvumi on **any line** in any buffer.                      |
| `NvumiEvalBuf`  | Run nvumi on the **entire buffer** anywhere. Can be messy!    |
| `NvumiClear`    | **Clears** the buffer's virtual text.                         |

## `.nvumi` filetype

nvumi uses a custom filetype `.nvumi` so that the autocommands don't trigger on arbitrary buffers. As a side effect, you can create and save `.nvumi` files outside of the scratch buffer and they work exactly the same.

## Wiki

There is a [Wiki](https://github.com/josephburgess/nvumi/wiki) with more detail, including a [Recipes](https://github.com/josephburgess/nvumi/wiki/Recipes) page with example custom conversions and functions.

## Contributing

This is my first attempt at a Neovim plugin, so contributions are more than welcome. If you encounter issues or have ideas for improvements, please open an issue or submit a pull request on GitHub.

## License

MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgements

- **[numi](https://github.com/nikolaeu/numi):** The natural language calculator this plugin wraps.
- **[Snacks.nvim](https://github.com/folke/snacks.nvim):** The Lua runner built into snacks.Scratch inspired this idea. Snacks is no longer a dependency but still worth a shout out. Thanks @folke.
