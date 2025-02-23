# nvumi

**nvumi** is a Neovim plugin that integrates the [numi](https://github.com/nikolaeu/numi) natural language calculator with [Snacks.nvim's](https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md) scratch buffer. It lets you construct natural language expressions and see the results evaluated inline as you type.

<p align="center">
  <img src="https://github.com/user-attachments/assets/c0d0fd19-7acf-49db-96d2-0da9eda3b088" alt="Gif" />
</p>

## 🔧 Installation

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
    -- see below for more on custom conversions/functions
    custom_conversions = {},
    custom_functions = {}
  }
}
```

### Install `numi-cli`

You will also need **[numi-cli](https://github.com/nikolaeu/numi)**.

#### 🖥 MacOS

```sh
brew install nikolaeu/numi/numi-cli
```

#### 📦 Linux & Windows

```sh
curl -sSL https://s.numi.app/cli | sh
```

### Keybinding to open `nvumi`

nvumi does not have a default keybinding to open the scratch buffer. You can set one:

```lua
vim.keymap.set("n", "<leader>on", "<CMD>Nvumi<CR>", { desc = "[O]pen [N]vumi" })
```

## 🚀 Usage

1. Run `:Nvumi` to open a scratch buffer.
2. Type a natural language expression (`20 inches in cm`).
3. The result appears **inline** or on a **new line**, based on your settings.
4. Press `<CR>` to **refresh** calculations if you need.
5. Use `<leader>y` to **yank the current result** (or `<leader>Y` for all results).

## 📌 Variable Assignment

nvumi supports **variables**, allowing you to store values and reuse them later. Variable names must start with a letter or underscore, followed by letters, numbers, or underscores.

### **Example**

```text
x = 20 inches in cm
y = 5000
x * y
x + 5
y meters in kilometers
```

- `x` stores the result of `20 inches in cm`
- `y` holds `5000`
- You can use them in expressions like `x * y` (which equals `254000.00 cm`, btw)

### **Resetting Variables**

Pressing `<R>` to reset the buffer will also **clear all stored variables**.

## 🔄 Custom conversions

nvumi allows you to define **custom unit conversions** beyond what `numi-cli` provides. This feature was inspired by the [plugins](https://github.com/nikolaeu/numi/tree/master/plugins) that exist for the numi desktop app. These should be compatible with `nvumi`.

💡 **How It Works:**

- You can define **custom units** with **aliases**, a **base unit group**, and a **conversion ratio**.
- Custom conversions **must share the same `base_unit`** (e.g., `"speed"`, `"volume"`).
- When converting, **ratios are relative to the base unit**.

### **Example Configuration**

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

### **Examples**

| Input                  | Output        |
| ---------------------- | ------------- |
| `10 gallons in liters` | `37.8541 L`   |
| `5 kmh in mph`         | `3.10686 mph` |

## **🧮 Custom Functions**

nvumi supports **user-defined functions**.

💡 **How It Works:**

- Define **custom functions** with **aliases**.
- Functions receive **arguments** (numbers or strings, or nothing) and return computed results.
- You can include error messages that will surface if something isn't quite right.

### **Example Configuration**

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

### **Examples**

| Input           | Output                                               |
| --------------- | ---------------------------------------------------- |
| `square(5)`     | `25`                                                 |
| `square("abc")` | `"Error: square requires a single numeric argument"` |
| `hello("Joe")`  | `"Hello, Joe!"`                                      |
| `flip()`        | `Heads` / `Tails`                                    |

## 🎨 Virtual Text Locations

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

## 📅 Date Formatting

| **Format** | **Example Output**  |
| ---------- | ------------------- |
| `"iso"`    | `2025-02-21`        |
| `"us"`     | `02/21/2025`        |
| `"uk"`     | `21/02/2025`        |
| `"long"`   | `February 21, 2025` |

Set this in your config:

```lua
opts = {
  date_format = "iso", -- or: "uk", "us", "long"
}
```

## Extra commands

There are three extra (possibly useless) commands included with nvumi:

| Command         | Description                                                   |
| --------------- | ------------------------------------------------------------- |
| `NvumiEvalLine` | Run nvumi on **any line** in any buffer.                      |
| `NvumiEvalBuf`  | Run nvumi on the **entire buffer** anywhere. ⚠️ Can be messy! |
| `NvumiClear`    | **Clears** the buffer's virtual text.                         |

## 📁 `.nvumi` filetype

nvumi was built around a made-up filetype `.nvumi`. This was so that the autocommands used by the plugin under the hood would not start trying to evaluate random files.

The fun side-effect of this, however, is that you can create/save `.nvumi` files outside of the scratch buffer and they will function exactly the same!

## 📚 Wiki

This README hopefully had a good enough outline of current features and examples to get you started, however there is also a [Wiki](https://github.com/josephburgess/nvumi/wiki) being expanded with more in-depth info.

In particular it includes a [Recipes](https://github.com/josephburgess/nvumi/wiki/Recipes) page with some example custom conversions/functions.

## Contributing

This is my first attempt at a Neovim plugin, so contributions are more than welcome! If you encounter issues or have ideas for improvements, please open an issue or submit a pull request on GitHub.

## 💡 Roadmap & Planned Features

A few things I'm thinking about adding as I continue trying to expand my knowledge of `lua` and plugin development:

- [x] Variable Assignment
- [x] Custom prefixes/suffixes (`=`, `→`, `🚀`)
- [x] Auto-evaluate expressions while typing
- [x] Run on any buffer outside scratch
- [x] Custom date format
- [x] Yankable answers (per line/all at once)
- [x] **User-defined unit conversions**
- [x] User-defined maths functions ✅ _(latest)_

## 📜 License

MIT License. See [LICENSE](LICENSE) for details.

## 🙌 Acknowledgements

- **[Snacks.nvim](https://github.com/folke/snacks.nvim):**
  Thanks @folke for the incredible plugin. The `lua` code runner built into the Scratch buffer inspired this idea in the first place! Thanks also also for your super-human contributions to the community in general.
- **[numi](https://github.com/nikolaeu/numi):**
  Thanks for providing an amazing natural language calculator.
